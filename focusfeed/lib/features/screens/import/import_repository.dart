import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:focusfeed/features/screens/feed/feed_item.dart';
import 'package:focusfeed/features/screens/import/parsed_flashcard.dart';

class ImportRepository {
  final FirebaseFirestore firestore;

  ImportRepository({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  Future<String> saveImport({
    required String userId,
    required String fileName,
    required String rawText,
    required List<ParsedFlashcard> cards,
  }) async {
    final importRef = await firestore.collection('imports').add({
      'userId': userId,
      'fileName': fileName,
      'rawText': rawText,
      'cardCount': cards.length,
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
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
    return importRef.id;
  }

  Future<List<FeedItem>> loadFeedItemsFromImport(String importId) async {
    final snapshot = await firestore
        .collection('imports')
        .doc(importId)
        .collection('cards')
        .orderBy('order')
        .get();

    return snapshot.docs.map<FeedItem>((doc) {
      final data = doc.data();

      return FeedItem.flashcard(
        category: 'Imported',
        categoryColor: const Color(0xFF855AFB),
        categoryBg: const Color(0x1A855AFB),
        deckTitle: data['deckTitle'] ?? 'FLASHCARD',
        question: data['term'] ?? '',
        answer: data['answer'] ?? '',
      );
    }).toList();
  }
}
