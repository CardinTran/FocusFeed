import 'dart:math';
import 'package:focusfeed/features/import/generated_card.dart';
import 'package:focusfeed/features/import/parsed_flashcard.dart';

class CardGeneratorService {
  const CardGeneratorService();

  List<GeneratedCard> generate(List<ParsedFlashcard> parsed){
    if (parsed.length < 4){ // Not enough cards to mix types
      return parsed.map((c) => GeneratedCard( // Make everything flashcards
        cardType: 'flashcard',
        content: {'front': c.term, 'back': c.answer},
        )).toList();
    }
    final result = <GeneratedCard>[]; // Rotate through 4 types in order then shuffle
    final types = ['flashcard', 'quiz', 'fillinBlank', 'explainer'];

    for(int i = 0; i < parsed.length; i++){
      final card = parsed[i];
      final type = types[i % 4];

      switch (type){
        case 'flashcard':
        result.add(GeneratedCard(
          cardType: 'flashcard',
          content: {'front': card.term, 'back': card.answer},
        ));
        break;

        case 'quiz':
        final distractors = _pickDistractors(parsed, i);
        final allOptions = [card.answer, ...distractors]..shuffle();
        final correctIndex = allOptions.indexOf(card.answer);
        result.add(GeneratedCard(
          cardType: 'quiz', 
          content: {
            'question': card.term,
            'options': allOptions,
            'correctIndex': correctIndex,
          },
          ));
        break;
        case 'fillInBlank':
          result.add(GeneratedCard(
            cardType: 'fillInBlank',
            content: {
              'sentence': '${card.term}: ___',
              'answer': card.answer,
            },
          ));
          break;

        case 'explainer':
          result.add(GeneratedCard(
            cardType: 'explainer',
            content: {
              'title': card.term,
              'body': card.answer,
            },
          ));
          break;
      }
    }
    return result;
  }
  // Picks 3 answer strings from OTHER cards to use as wrong answers in a quiz
  List<String> _pickDistractors(List<ParsedFlashcard> all, int excludeIndex){
    final rng = Random();
    final candidates = <String>[];

    for(int i = 0; i < all.length; i++){
      if (i != excludeIndex) candidates.add(all[i].answer);
    }
    candidates.shuffle(rng);
    return candidates.take(3).toList();
  }
}