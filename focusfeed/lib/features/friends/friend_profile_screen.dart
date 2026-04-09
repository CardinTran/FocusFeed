import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:focusfeed/features/import/import_repository.dart';
import 'package:focusfeed/features/feed/feed_item.dart';
import 'friend_model.dart';
import 'friend_deck_screen.dart';

class FriendProfileScreen extends StatelessWidget {
  final Friend friend;

  const FriendProfileScreen({super.key, required this.friend});

  static const Color _bg     = Color(0xFF0B0F2A);
  static const Color _card   = Color(0xFF151A3B);
  static const Color _accent = Color(0xFF855AFB);
  static const Color _border = Color(0x12FFFFFF);

  @override
  Widget build(BuildContext context) {
    final initials = friend.displayName
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF12182F),
        title: Text(friend.displayName,
            style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(friend.uid)
            .get(),
        builder: (context, snap) {
          final data = snap.data?.data() as Map<String, dynamic>?;
          final school = data?['school'] as String? ?? '';
          final courses = List<String>.from(data?['selectedCourses'] ?? []);
          final subjects = List<String>.from(data?['selectedSubjects'] ?? []);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar + name
                Center(
                  child: Column(children: [
                    const SizedBox(height: 8),
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: _accent,
                      child: Text(initials,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 12),
                    Text(friend.displayName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600)),
                    if (school.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(school,
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 13)),
                    ],
                    const SizedBox(height: 24),
                  ]),
                ),

                // Courses
                if (courses.isNotEmpty) ...[
                  _sectionLabel('Courses'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: courses.map((c) => _chip(c)).toList(),
                  ),
                  const SizedBox(height: 20),
                ],

                // Subjects
                if (subjects.isNotEmpty) ...[
                  _sectionLabel('Subjects'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: subjects.map((s) => _chip(s)).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Study content
                _sectionLabel('Study Content'),
                const SizedBox(height: 12),
                StreamBuilder<List<FeedItem>>(
                  stream: ImportRepository()
                      .streamAllFeedItemsForUser(friend.uid),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(color: _accent));
                    }
                    final items = snap.data ?? [];
                    if (items.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text('No study content yet.',
                              style: TextStyle(color: Colors.white54)),
                        ),
                      );
                    }

                    // Group by importId
                    final Map<String, List<FeedItem>> grouped = {};
                    for (final item in items) {
                      final key = item.importId ?? 'unknown';
                      grouped.putIfAbsent(key, () => []).add(item);
                    }

                    return Column(
                      children: grouped.entries.map((entry) {
                        final cards = entry.value;
                        final deckTitle = cards.first.deckTitle ?? 'Deck';
                        return _deckCard(context, entry.key, cards);
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(
        label.toUpperCase(),
        style: const TextStyle(
            color: Color(0x40FFFFFF),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8),
      );

  Widget _chip(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _accent.withValues(alpha: 0.3)),
        ),
        child: Text(label,
            style: const TextStyle(
                color: _accent, fontSize: 13, fontWeight: FontWeight.w500)),
      );

  Widget _deckCard(
      BuildContext context, String importId, List<FeedItem> cards) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FriendDeckScreen(
            friendName: friend.displayName,
            cards: cards,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.style_outlined, color: _accent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Flashcard Deck',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('${cards.length} cards',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
        ]),
      ),
    );
  }
}