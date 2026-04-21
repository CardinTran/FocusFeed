import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focusfeed/features/feed/feed_item.dart';
import 'package:focusfeed/features/feed/feed_policy.dart';
import 'package:focusfeed/features/feed/feed_ranker.dart';

void main() {
  group('FeedRanker', () {
    const ranker = FeedRanker();

    test('rankItems prioritizes active study content over learned content', () {
      final ranked = ranker.rankItems([
        _item(
          id: 'learned-card',
          learned: true,
          resurfaceAfter: DateTime.now().subtract(const Duration(hours: 6)),
          seenCount: 1,
          lastSeenAt: DateTime.now().subtract(const Duration(hours: 4)),
        ),
        _item(
          id: 'active-card',
          learned: false,
          seenCount: 0,
          lastSeenAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ]);

      expect(ranked.first.id, 'active-card');
      expect(ranked.last.id, 'learned-card');
    });

    test(
      'buildBatch injects eligible exploration content at the configured interval',
      () {
        final items = [
          _item(id: 'focus-1'),
          _item(id: 'focus-2', seenCount: 1),
          _item(id: 'focus-3', seenCount: 2),
          _item(id: 'focus-4', seenCount: 3),
          _item(id: 'focus-5', seenCount: 4),
          _item(
            id: 'explore-1',
            learned: true,
            resurfaceAfter: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ];

        final batch = ranker.buildBatch(
          items: items,
          recentlyQueuedIds: const [],
          random: Random(7),
          batchSize: 6,
        );

        expect(batch.length, 6);
        expect(batch[FeedPolicy.explorationInterval].id, 'explore-1');
      },
    );

    test('buildBatch avoids recently queued items when fresh items exist', () {
      final batch = ranker.buildBatch(
        items: [
          _item(id: 'recent-a'),
          _item(id: 'recent-b'),
          _item(id: 'fresh-a', lastSeenAt: DateTime.now()),
          _item(id: 'fresh-b', seenCount: 1),
        ],
        recentlyQueuedIds: const ['recent-a', 'recent-b'],
        random: Random(3),
        batchSize: 2,
      );

      final batchIds = batch.map((item) => item.id).toList();

      expect(batchIds, isNot(contains('recent-a')));
      expect(batchIds, isNot(contains('recent-b')));
      expect(batchIds, containsAll(['fresh-a', 'fresh-b']));
    });

    test(
      'buildBatch treats learned items with an old lastLearnedAt as exploration candidates',
      () {
        final batch = ranker.buildBatch(
          items: [
            _item(id: 'focus-1'),
            _item(id: 'focus-2'),
            _item(id: 'focus-3'),
            _item(id: 'focus-4'),
            _item(
              id: 'fallback-exploration',
              learned: true,
              lastLearnedAt: DateTime.now().subtract(
                FeedPolicy.learnedResurfaceDelay + const Duration(hours: 1),
              ),
            ),
          ],
          recentlyQueuedIds: const [],
          random: Random(9),
          batchSize: 6,
        );

        expect(batch.map((item) => item.id), contains('fallback-exploration'));
      },
    );
  });
}

/// Creates compact feed items for ranking tests.
///
/// The helper deliberately fills the presentation-oriented fields with stable
/// defaults so each test only needs to specify the ranking-related inputs it
/// cares about.
FeedItem _item({
  required String id,
  bool learned = false,
  bool saved = false,
  int seenCount = 0,
  DateTime? lastSeenAt,
  DateTime? lastLearnedAt,
  DateTime? resurfaceAfter,
}) {
  return FeedItem.flashcard(
    id: id,
    importId: 'import-1',
    category: 'Imported',
    categoryColor: Colors.deepPurple,
    categoryBg: const Color(0x1A855AFB),
    deckTitle: 'FLASHCARD',
    question: 'Question for $id',
    answer: 'Answer for $id',
    learned: learned,
    saved: saved,
    seenCount: seenCount,
    lastSeenAt: lastSeenAt,
    lastLearnedAt: lastLearnedAt,
    resurfaceAfter: resurfaceAfter,
  );
}
