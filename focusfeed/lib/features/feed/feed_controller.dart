import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:focusfeed/features/feed/feed_item.dart';
import 'package:focusfeed/features/feed/feed_policy.dart';
import 'package:focusfeed/features/feed/feed_ranker.dart';
import 'package:focusfeed/features/import/import_repository.dart';

/// Coordinates feed-specific behavior between the UI and persistence layers.
///
/// Widgets call into this controller instead of owning ranking or Firestore
/// update rules themselves. That keeps the presentation layer narrower and
/// makes the feed behavior easier to evolve over time.
class FeedController {
  FeedController({
    FirebaseAuth? auth,
    ImportRepository? repository,
    FeedRanker? ranker,
    Random? random,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _repository = repository ?? ImportRepository(),
       _ranker = ranker ?? const FeedRanker(),
       _random = random ?? Random();

  final FirebaseAuth _auth;
  final ImportRepository _repository;
  final FeedRanker _ranker;
  final Random _random;

  /// Returns the user's items in ranked order.
  ///
  /// The feed screen still performs local pagination, but it should always
  /// start from a priority-aware ordering rather than raw imported order.
  Stream<List<FeedItem>> streamFeedItems(String userId) {
    return _repository.streamAllFeedItemsForUser(userId).map(_ranker.rankItems);
  }

  /// Builds the next visible batch for the vertically paged feed.
  List<FeedItem> buildNextBatch({
    required List<FeedItem> items,
    required List<String> recentlyQueuedIds,
    int batchSize = FeedPolicy.batchSize,
  }) {
    return _ranker.buildBatch(
      items: items,
      recentlyQueuedIds: recentlyQueuedIds,
      random: _random,
      batchSize: batchSize,
    );
  }

  /// Records that a user actually reached a card in the feed.
  ///
  /// This signal is intentionally lightweight. It gives the ranking algorithm a
  /// recency counter without requiring a full answer-grading flow yet.
  Future<void> markSeen(FeedItem item) async {
    final user = _auth.currentUser;
    if (user == null || item.importId == null) {
      return;
    }

    await _repository.markSeen(
      userId: user.uid,
      importId: item.importId!,
      cardId: item.id,
    );
  }

  /// Toggles learned state and lets the repository maintain the cooldown data
  /// used for resurfacing learned cards later.
  Future<void> setLearned(FeedItem item, bool learned) async {
    final user = _auth.currentUser;
    if (user == null || item.importId == null) {
      return;
    }

    await _repository.updateLearned(
      userId: user.uid,
      importId: item.importId!,
      cardId: item.id,
      learned: learned,
    );
  }

  /// Persists the saved flag for a feed item.
  Future<void> setSaved(FeedItem item, bool saved) async {
    final user = _auth.currentUser;
    if (user == null || item.importId == null) {
      return;
    }

    await _repository.updateSaved(
      userId: user.uid,
      importId: item.importId!,
      cardId: item.id,
      saved: saved,
    );
  }
}
