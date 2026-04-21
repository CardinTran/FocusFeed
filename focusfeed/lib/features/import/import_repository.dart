import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:focusfeed/features/feed/feed_item.dart';
import 'package:focusfeed/features/feed/feed_policy.dart';
import 'package:focusfeed/features/import/parsed_flashcard.dart';

class ImportRepository {
  final FirebaseFirestore firestore;

  ImportRepository({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  Future<String> saveImport({
    required String userId,
    required String fileName,
    required String rawText,
    required List<ParsedFlashcard> cards,
    String sourceType = 'file',
  }) async {
    final importRef = await firestore
        .collection('users')
        .doc(userId)
        .collection('imports')
        .add({
          'fileName': fileName,
          'rawText': rawText,
          'cardCount': cards.length,
          'sourceType': sourceType,
          'createdAt': FieldValue.serverTimestamp(),
        });

    final batch = firestore.batch();

    for (int i = 0; i < cards.length; i++) {
      final card = cards[i];
      final cardRef = importRef.collection('cards').doc();

      batch.set(cardRef, {
        'term': card.term,
        'answer': card.answer,
        'order': i,
        'isSaved': false,
        'isLearned': false,
        'seenCount': 0,
        'lastSeenAt': null,
        'lastLearnedAt': null,
        'resurfaceAfter': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
    return importRef.id;
  }

  Future<void> deleteImport({
    required String userId,
    required String importId,
  }) async {
    final importRef = firestore
        .collection('users')
        .doc(userId)
        .collection('imports')
        .doc(importId);

    final cardsSnapshot = await importRef.collection('cards').get();

    final batch = firestore.batch();

    for (final doc in cardsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    batch.delete(importRef);

    await batch.commit();
  }

  Future<void> updateSaved({
    required String userId,
    required String importId,
    required String cardId,
    required bool saved,
  }) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('imports')
        .doc(importId)
        .collection('cards')
        .doc(cardId)
        .update({'isSaved': saved});
  }

  /// Records that the user reached a card in the feed.
  ///
  /// The adaptive ranker uses this lightweight signal to avoid over-serving the
  /// same cards in a short window.
  Future<void> markSeen({
    required String userId,
    required String importId,
    required String cardId,
  }) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('imports')
        .doc(importId)
        .collection('cards')
        .doc(cardId)
        .update({
          'seenCount': FieldValue.increment(1),
          'lastSeenAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> updateLearned({
    required String userId,
    required String importId,
    required String cardId,
    required bool learned,
  }) async {
    final learnedAt = DateTime.now();
    final resurfaceAfter = learnedAt.add(FeedPolicy.learnedResurfaceDelay);

    await firestore
        .collection('users')
        .doc(userId)
        .collection('imports')
        .doc(importId)
        .collection('cards')
        .doc(cardId)
        .update({
          'isLearned': learned,
          'lastLearnedAt': learned ? Timestamp.fromDate(learnedAt) : null,
          'resurfaceAfter': learned ? Timestamp.fromDate(resurfaceAfter) : null,
        });
  }

  Future<List<FeedItem>> loadFeedItemsFromImport({
    required String userId,
    required String importId,
  }) async {
    final snapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('imports')
        .doc(importId)
        .collection('cards')
        .orderBy('order')
        .get();

    return snapshot.docs.map<FeedItem>((doc) {
      final data = doc.data();

      return FeedItem.flashcard(
        id: doc.id,
        importId: importId,
        category: 'Imported',
        categoryColor: const Color(0xFF855AFB),
        categoryBg: const Color(0x1A855AFB),
        deckTitle: 'FLASHCARD',
        question: data['term'] ?? '',
        answer: data['answer'] ?? '',
        seenCount: (data['seenCount'] as num?)?.toInt() ?? 0,
        lastSeenAt: _readTimestamp(data['lastSeenAt']),
        lastLearnedAt: _readTimestamp(data['lastLearnedAt']),
        resurfaceAfter: _readTimestamp(data['resurfaceAfter']),
        saved: data['isSaved'] ?? false,
        learned: data['isLearned'] ?? false,
      );
    }).toList();
  }

  Stream<List<FeedItem>> streamAllFeedItemsForUser(String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('imports')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((importsSnapshot) async {
          final List<FeedItem> allItems = [];

          for (final importDoc in importsSnapshot.docs) {
            final cardsSnapshot = await importDoc.reference
                .collection('cards')
                .orderBy('order')
                .get();

            for (final doc in cardsSnapshot.docs) {
              final data = doc.data();

              allItems.add(
                FeedItem.flashcard(
                  id: doc.id,
                  importId: importDoc.id,
                  category: 'Imported',
                  categoryColor: const Color(0xFF855AFB),
                  categoryBg: const Color(0x1A855AFB),
                  deckTitle: 'FLASHCARD',
                  question: data['term'] ?? '',
                  answer: data['answer'] ?? '',
                  seenCount: (data['seenCount'] as num?)?.toInt() ?? 0,
                  lastSeenAt: _readTimestamp(data['lastSeenAt']),
                  lastLearnedAt: _readTimestamp(data['lastLearnedAt']),
                  resurfaceAfter: _readTimestamp(data['resurfaceAfter']),
                  saved: data['isSaved'] ?? false,
                  learned: data['isLearned'] ?? false,
                ),
              );
            }
          }

          return allItems;
        });
  }

  /// Safely reads a Firestore timestamp field and converts it to a Dart
  /// `DateTime`.
  DateTime? _readTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    return null;
  }
}
