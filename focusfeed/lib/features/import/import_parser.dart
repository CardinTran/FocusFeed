import 'package:focusfeed/features/import/parsed_flashcard.dart';

class ImportParser {
  const ImportParser();

  List<ParsedFlashcard> parseFlashcards(String rawText) {
    final lines = rawText.split('\n');
    final cards = <ParsedFlashcard>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      final parts = trimmed.split('|');
      if (parts.length < 2) continue;

      final term = parts[0].trim();
      final answer = parts.sublist(1).join('|').trim();

      if (term.isEmpty || answer.isEmpty) continue;

      cards.add(ParsedFlashcard(term: term, answer: answer));
    }

    return cards;
  }
}
