import 'package:cloud_firestore/cloud_firestore.dart';

class LibraryDeck {
  final String importId;
  final String title;
  final int cardCount;
  final DateTime? createdAt;

  const LibraryDeck({
    required this.importId,
    required this.title,
    required this.cardCount,
    required this.createdAt,
  });

  factory LibraryDeck.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return LibraryDeck(
      importId: doc.id,
      title: (data['fileName'] as String?)?.trim().isNotEmpty == true
          ? data['fileName'] as String
          : 'Untitled Deck',
      cardCount: (data['cardCount'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
