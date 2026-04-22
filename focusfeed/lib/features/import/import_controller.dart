import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focusfeed/features/feed/feed_item.dart';
import 'package:focusfeed/features/import/ocr_import_service.dart';
import 'package:focusfeed/features/import/parsed_flashcard.dart';

import 'import_parser.dart';
import 'import_repository.dart';

class ImportResult {
  final List<FeedItem> items;
  final String fileName;
  final String message;

  const ImportResult({
    required this.items,
    required this.fileName,
    required this.message,
  });
}

class ImportController {
  final FirebaseAuth auth;
  final ImportParser parser;
  final ImportRepository repository;
  final OcrImportService ocrService;

  ImportController({
    FirebaseAuth? auth,
    ImportParser? parser,
    ImportRepository? repository,
    OcrImportService? ocrService,
  }) : auth = auth ?? FirebaseAuth.instance,
       parser = parser ?? const ImportParser(),
       repository = repository ?? ImportRepository(),
       ocrService = ocrService ?? OcrImportService();

  Future<ImportResult> pickAndImportFile() async {
    // Existing text-file import path. It still saves immediately because users
    // are expected to provide already structured text files.
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'csv'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      throw Exception('No file selected.');
    }

    final pickedFile = result.files.first;
    final bytes = pickedFile.bytes;

    if (bytes == null) {
      throw Exception('Could not read file data.');
    }

    final user = auth.currentUser;
    if (user == null) {
      throw Exception('You must be signed in.');
    }

    final rawText = utf8.decode(bytes);
    final parsedCards = parser.parseFlashcards(rawText);

    if (parsedCards.isEmpty) {
      throw Exception('No usable text found in the selected file.');
    }

    final importId = await repository.saveImport(
      userId: user.uid,
      fileName: pickedFile.name,
      rawText: rawText,
      cards: parsedCards,
    );

    final items = await repository.loadFeedItemsFromImport(
      userId: user.uid,
      importId: importId,
    );

    return ImportResult(
      items: items,
      fileName: pickedFile.name,
      message: 'Imported ${parsedCards.length} flashcards successfully.',
    );
  }

  Future<OcrPreviewResult?> pickImageForPreview({
    required OcrImageInput input,
  }) async {
    // OCR imports always stop at a draft preview. OCR output can be incomplete,
    // out of order, or noisy even when the source image looks well formatted.
    final draft = await ocrService.pickImageAndExtractText(input: input);
    if (draft == null) return null;

    final parsedCards = parser.parseFlashcards(draft.rawText);

    return OcrPreviewResult(
      fileName: draft.imageName,
      rawText: draft.rawText,
      cards: parsedCards,
    );
  }

  Future<ImportResult> saveOcrCards({
    required String fileName,
    required String rawText,
    required List<ParsedFlashcard> cards,
  }) async {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('You must be signed in.');
    }

    // Blank draft rows are ignored so users can add/remove freely in preview.
    final approvedCards = cards
        .where(
          (card) =>
              card.term.trim().isNotEmpty || card.answer.trim().isNotEmpty,
        )
        .map(
          (card) => ParsedFlashcard(
            term: card.term.trim(),
            answer: card.answer.trim(),
          ),
        )
        .toList();

    if (approvedCards.isEmpty) {
      throw Exception('Add at least one card before saving.');
    }

    final importId = await repository.saveImport(
      userId: user.uid,
      fileName: fileName,
      rawText: rawText,
      cards: approvedCards,
      // Store the source so later library/feed UI can distinguish OCR imports
      // from file imports if we want different labels or cleanup behavior.
      sourceType: 'image_ocr',
    );

    final items = await repository.loadFeedItemsFromImport(
      userId: user.uid,
      importId: importId,
    );

    return ImportResult(
      items: items,
      fileName: fileName,
      message: 'Saved ${approvedCards.length} OCR flashcards.',
    );
  }

  Future<void> dispose() => ocrService.dispose();
}

class OcrPreviewResult {
  final String fileName;
  final String rawText;
  final List<ParsedFlashcard> cards;

  const OcrPreviewResult({
    required this.fileName,
    required this.rawText,
    required this.cards,
  });
}
