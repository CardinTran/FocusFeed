import 'package:focusfeed/features/import/parsed_flashcard.dart';

class ImportParser {
  const ImportParser();

  List<ParsedFlashcard> parseFlashcards(String rawText) {
    // The first OCR splitter is deliberately conservative: one visual line
    // becomes one draft card unless a simple separator is found.
    final lines = rawText.replaceAll('\r\n', '\n').split('\n');
    final cards = <ParsedFlashcard>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      final separator = _findSeparator(trimmed);

      // If no separator exists, keep the whole line as the front. The user can
      // fill the back on the mandatory preview screen.
      final term = separator == null
          ? trimmed
          : trimmed.substring(0, separator.index).trim();
      final answer = separator == null
          ? ''
          : trimmed.substring(separator.index + separator.length).trim();

      if (term.isEmpty && answer.isEmpty) continue;

      cards.add(ParsedFlashcard(term: term, answer: answer));
    }

    return cards;
  }

  _Separator? _findSeparator(String line) {
    // Check the strongest/least ambiguous separators first. A plain dash is
    // only accepted when surrounded by spaces to avoid splitting hyphenated
    // words from OCR output.
    final pipeIndex = line.indexOf('|');
    if (pipeIndex > 0) return _Separator(pipeIndex, 1);

    final arrowIndex = line.indexOf('->');
    if (arrowIndex > 0) return _Separator(arrowIndex, 2);

    final colonIndex = line.indexOf(':');
    if (colonIndex > 0) return _Separator(colonIndex, 1);

    final emDashIndex = line.indexOf(' — ');
    if (emDashIndex > 0) return _Separator(emDashIndex, 3);

    final enDashIndex = line.indexOf(' – ');
    if (enDashIndex > 0) return _Separator(enDashIndex, 3);

    final spacedDashIndex = line.indexOf(' - ');
    if (spacedDashIndex > 0) return _Separator(spacedDashIndex, 3);

    final tabIndex = line.indexOf('\t');
    if (tabIndex > 0) return _Separator(tabIndex, 1);

    return null;
  }
}

class _Separator {
  final int index;
  final int length;

  const _Separator(this.index, this.length);
}
