import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:focusfeed/features/feed/feed_item.dart';
import 'package:focusfeed/features/feed/feed_policy.dart';
import 'package:focusfeed/features/import/generated_card.dart';

class ImportRepository {
  final FirebaseFirestore firestore;

  ImportRepository({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  Future<String> saveImport({
    required String userId,
    required String fileName,
    required String rawText,
    required List<GeneratedCard> cards,
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
        'cardType': card.cardType,
        'content': card.content,
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

  FeedItem _docToFeedItem(Map<String, dynamic> data, String docId, String importId) {
    final cardType = data['cardType'] as String? ?? 'flashcard';
    final content = (data['content'] as Map<String, dynamic>?) ?? {};
    final isSaved = data['isSaved'] as bool? ?? false;
    final isLearned = data['isLearned'] as bool? ?? false;

    switch (cardType) {
      case 'quiz':
        return FeedItem.quiz(
          id: docId,
          importId: importId,
          category: 'Imported',
          categoryColor: const Color(0xFFFF6B6B),
          categoryBg: const Color(0x1AFF6B6B),
          question: content['question'] as String? ?? '',
          options: List<String>.from(content['options'] as List? ?? []),
          correctIndex: content['correctIndex'] as int? ?? 0,
          saved: isSaved,
          learned: isLearned,
        );
      case 'fillInBlank':
        return FeedItem.fillInBlank(
          id: docId,
          importId: importId,
          category: 'Imported',
          categoryColor: const Color(0xFFFDCB6E),
          categoryBg: const Color(0x1AFDCB6E),
          sentence: content['sentence'] as String? ?? '',
          answer: content['answer'] as String? ?? '',
          saved: isSaved,
          learned: isLearned,
        );
      case 'explainer':
        return FeedItem.explainer(
          id: docId,
          importId: importId,
          category: 'Imported',
          categoryColor: const Color(0xFF00B894),
          categoryBg: const Color(0x1A00B894),
          title: content['title'] as String? ?? '',
          body: content['body'] as String? ?? '',
          saved: isSaved,
          learned: isLearned,
        );
      default: // flashcard
        return FeedItem.flashcard(
          id: docId,
          importId: importId,
          category: 'Imported',
          categoryColor: const Color(0xFF855AFB),
          categoryBg: const Color(0x1A855AFB),
          deckTitle: 'FLASHCARD',
          question: content['front'] as String? ?? '',
          answer: content['back'] as String? ?? '',
          saved: isSaved,
          learned: isLearned,
        );
    }
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

    return snapshot.docs
        .map((doc) => _docToFeedItem(doc.data(), doc.id, importId))
        .toList();
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
              allItems.add(_docToFeedItem(doc.data(), doc.id, importDoc.id));
            }
          }

          return allItems;
        });
  }


}
