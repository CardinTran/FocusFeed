import 'package:flutter/material.dart';

enum FeedItemType { article, flashcard }

class FeedItem {
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

  bool learned;
  bool bookmarked;

  FeedItem({
    required this.type,
    required this.category,
    required this.categoryColor,
    required this.categoryBg,
    this.title,
    this.description,
    this.deckTitle,
    this.question,
    this.answer,
    this.deckIcon,
    this.learned = false,
    this.bookmarked = false,
  });

  factory FeedItem.flashcard({
    required String category,
    required Color categoryColor,
    required Color categoryBg,
    required String deckTitle,
    required String question,
    required String answer,
    IconData? deckIcon,
    bool learned = false,
    bool bookmarked = false,
  }) {
    return FeedItem(
      type: FeedItemType.flashcard,
      category: category,
      categoryColor: categoryColor,
      categoryBg: categoryBg,
      deckTitle: deckTitle,
      question: question,
      answer: answer,
      deckIcon: deckIcon,
      learned: learned,
      bookmarked: bookmarked,
    );
  }

  factory FeedItem.article({
    required String category,
    required Color categoryColor,
    required Color categoryBg,
    required String title,
    required String description,
    bool learned = false,
    bool bookmarked = false,
  }) {
    return FeedItem(
      type: FeedItemType.article,
      category: category,
      categoryColor: categoryColor,
      categoryBg: categoryBg,
      title: title,
      description: description,
      learned: learned,
      bookmarked: bookmarked,
    );
  }
}
