import 'package:flutter/material.dart';

enum FeedItemType { article, flashcard }

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
  final int seenCount;
  final DateTime? lastSeenAt;
  final DateTime? lastLearnedAt;
  final DateTime? resurfaceAfter;

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
    this.seenCount = 0,
    this.lastSeenAt,
    this.lastLearnedAt,
    this.resurfaceAfter,
    this.learned = false,
    this.saved = false,
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
    int seenCount = 0,
    DateTime? lastSeenAt,
    DateTime? lastLearnedAt,
    DateTime? resurfaceAfter,
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
      seenCount: seenCount,
      lastSeenAt: lastSeenAt,
      lastLearnedAt: lastLearnedAt,
      resurfaceAfter: resurfaceAfter,
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
    int seenCount = 0,
    DateTime? lastSeenAt,
    DateTime? lastLearnedAt,
    DateTime? resurfaceAfter,
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
      seenCount: seenCount,
      lastSeenAt: lastSeenAt,
      lastLearnedAt: lastLearnedAt,
      resurfaceAfter: resurfaceAfter,
      learned: learned,
      saved: saved,
    );
  }

  /// Creates a copy with selected fields replaced.
  ///
  /// This is useful when the UI needs to refresh queue items from newer stream
  /// data without reconstructing every call site by hand.
  FeedItem copyWith({
    String? id,
    String? importId,
    FeedItemType? type,
    String? category,
    Color? categoryColor,
    Color? categoryBg,
    String? title,
    String? description,
    String? deckTitle,
    String? question,
    String? answer,
    IconData? deckIcon,
    int? seenCount,
    DateTime? lastSeenAt,
    DateTime? lastLearnedAt,
    DateTime? resurfaceAfter,
    bool? learned,
    bool? saved,
  }) {
    return FeedItem(
      id: id ?? this.id,
      importId: importId ?? this.importId,
      type: type ?? this.type,
      category: category ?? this.category,
      categoryColor: categoryColor ?? this.categoryColor,
      categoryBg: categoryBg ?? this.categoryBg,
      title: title ?? this.title,
      description: description ?? this.description,
      deckTitle: deckTitle ?? this.deckTitle,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      deckIcon: deckIcon ?? this.deckIcon,
      seenCount: seenCount ?? this.seenCount,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      lastLearnedAt: lastLearnedAt ?? this.lastLearnedAt,
      resurfaceAfter: resurfaceAfter ?? this.resurfaceAfter,
      learned: learned ?? this.learned,
      saved: saved ?? this.saved,
    );
  }
}
