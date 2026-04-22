import 'package:flutter/material.dart';

enum FeedItemType { article, flashcard, quiz, fillInBlank, explainer }

class FeedItem {
  final String id;
  final String? importId;
  final FeedItemType type;

  final String category;
  final Color categoryColor;
  final Color categoryBg;

  final String? title;
  final String? description;

  final String? deckTitle;
  final String? question;
  final String? answer;
  final IconData? deckIcon;

  final List<String>? options; // quiz: 4 answer choices
  final int? correctIndex; // quiz: which index options is correct
  final String? sentence; // fillInBlank

  bool learned;
  bool saved;

  FeedItem({
    required this.id,
    required this.type,
    required this.category,
    required this.categoryColor,
    required this.categoryBg,
    this.importId,
    this.title,
    this.description,
    this.deckTitle,
    this.question,
    this.answer,
    this.deckIcon,
    this.learned = false,
    this.saved = false,
    this.options,
    this.correctIndex,
    this.sentence,
  });

  factory FeedItem.flashcard({
    required String id,
    required String category,
    required Color categoryColor,
    required Color categoryBg,
    required String deckTitle,
    required String question,
    required String answer,
    String? importId,
    IconData? deckIcon,
    bool learned = false,
    bool saved = false,
  }) {
    return FeedItem(
      id: id,
      importId: importId,
      type: FeedItemType.flashcard,
      category: category,
      categoryColor: categoryColor,
      categoryBg: categoryBg,
      deckTitle: deckTitle,
      question: question,
      answer: answer,
      deckIcon: deckIcon,
      learned: learned,
      saved: saved,
    );
  }

  factory FeedItem.article({
    required String id,
    required String category,
    required Color categoryColor,
    required Color categoryBg,
    required String title,
    required String description,
    String? importId,
    bool learned = false,
    bool saved = false,
  }) {
    return FeedItem(
      id: id,
      importId: importId,
      type: FeedItemType.article,
      category: category,
      categoryColor: categoryColor,
      categoryBg: categoryBg,
      title: title,
      description: description,
      learned: learned,
      saved: saved,
    );
  }
  factory FeedItem.quiz({
    required String id,
    required String category,
    required Color categoryColor,
    required Color categoryBg,
    required String question,
    required List<String> options,
    required int correctIndex,
    String? importId,
    bool learned = false,
    bool saved = false,

  }) {
    return FeedItem(
    id: id,
    importId: importId,
    type: FeedItemType.quiz,
    category: category,
    categoryColor: categoryColor,
    categoryBg: categoryBg,
    deckTitle: 'QUICK QUIZ',
    question: question,
    options: options,
    correctIndex: correctIndex,
    learned: learned,
    saved: saved,
    );
  }
  factory FeedItem.fillInBlank({
    required String id,
    required String category,
    required Color categoryColor,
    required Color categoryBg,
    required String sentence,
    required String answer,
    String? importId,
    bool learned = false,
    bool saved = false,
  }) {
    return FeedItem(
      id: id,
      importId: importId,
      type: FeedItemType.fillInBlank,
      category: category,
      categoryColor: categoryColor,
      categoryBg: categoryBg,
      deckTitle: 'FILL IN THE BLANK',
      sentence: sentence,
      answer: answer,
      learned: learned,
      saved: saved,
    );
  }
  factory FeedItem.explainer({
    required String id,
    required String category,
    required Color categoryColor,
    required Color categoryBg,
    required String title,
    required String body,
    String? importId,
    bool learned = false,
    bool saved = false,
  }) {
    return FeedItem(
      id: id,
      importId: importId,
      type: FeedItemType.explainer,
      category: category,
      categoryColor: categoryColor,
      categoryBg: categoryBg,
      deckTitle: 'MICRO-EXPLAINER',
      title: title,
      description: body,
      learned: learned,
      saved: saved,
    );
  }
  
}
