import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:focusfeed/features/library/library_deck.dart';

class LibraryRepository {
  final FirebaseFirestore firestore;

  LibraryRepository({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<LibraryDeck>> streamDecksForUser(String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('imports')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => LibraryDeck.fromFirestore(doc))
              .toList();
        });
  }
}
