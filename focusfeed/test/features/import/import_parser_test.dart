import 'package:flutter_test/flutter_test.dart';
import 'package:focusfeed/features/import/import_parser.dart';

void main() {
  group('ImportParser', () {
    test('splits OCR lines with supported separators', () {
      const parser = ImportParser();

      final cards = parser.parseFlashcards(
        'Term: Answer\nFront - Back\nA|B\nPrompt -> Response',
      );

      expect(cards, hasLength(4));
      expect(cards[0].term, 'Term');
      expect(cards[0].answer, 'Answer');
      expect(cards[1].term, 'Front');
      expect(cards[1].answer, 'Back');
      expect(cards[2].term, 'A');
      expect(cards[2].answer, 'B');
      expect(cards[3].term, 'Prompt');
      expect(cards[3].answer, 'Response');
    });

    test('keeps noisy unstructured OCR lines as front-only cards', () {
      const parser = ImportParser();

      final cards = parser.parseFlashcards('Photosynthesis\n\nCell membrane');

      expect(cards, hasLength(2));
      expect(cards[0].term, 'Photosynthesis');
      expect(cards[0].answer, isEmpty);
      expect(cards[1].term, 'Cell membrane');
      expect(cards[1].answer, isEmpty);
    });
  });
}
