import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focusfeed/features/feed/feed_item.dart';

import 'card_generator_service.dart';
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
  final CardGeneratorService generator;

  ImportController({
    FirebaseAuth? auth,
    ImportParser? parser,
    ImportRepository? repository,
    CardGeneratorService? generator,
  }) : auth = auth ?? FirebaseAuth.instance,
       parser = parser ?? const ImportParser(),
       repository = repository ?? ImportRepository(),
       generator = generator ?? const CardGeneratorService();

  Future<ImportResult> pickAndImportFile() async {
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
      throw Exception('No valid flashcards found. Use format: term|answer');
    }

    final generatedCards = generator.generate(parsedCards);

    final importId = await repository.saveImport(
      userId: user.uid,
      fileName: pickedFile.name,
      rawText: rawText,
      cards: generatedCards,
    );

    final items = await repository.loadFeedItemsFromImport(
      userId: user.uid,
      importId: importId,
    );

    return ImportResult(
      items: items,
      fileName: pickedFile.name,
      message: 'Imported ${generatedCards.length} cards successfully.',
    );
  }
}
