import 'dart:math';

import 'package:focusfeed/features/feed/feed_item.dart';
import 'package:focusfeed/features/feed/feed_policy.dart';

/// Pure ranking logic for the adaptive study feed.
///
/// This class deliberately contains no Firebase or Flutter dependencies so the
/// behavior is easy to reason about and can be unit tested later.
class FeedRanker {
  const FeedRanker();

  /// Produces a stable "best first" ordering for the current item set.
  ///
  /// This method is useful when a screen wants the current ranked order without
  /// also building a paginated batch.
  List<FeedItem> rankItems(List<FeedItem> items) {
    final ranked = List<FeedItem>.from(items);
    ranked.sort(_compareByPriority);
    return ranked;
  }

  /// Builds the next queue batch using an exploration/exploitation strategy.
  ///
  /// The algorithm prefers active study items, but it periodically injects
  /// eligible learned items whose cooldown has expired.
  List<FeedItem> buildBatch({
    required List<FeedItem> items,
    required List<String> recentlyQueuedIds,
    required Random random,
    int batchSize = FeedPolicy.batchSize,
  }) {
    if (items.isEmpty) {
      return const [];
    }

    final now = DateTime.now();
    final recentIdSet = recentlyQueuedIds
        .take(FeedPolicy.recentQueueWindow)
        .toSet();

    final focusPool =
        items.where((item) => !_isExplorationCandidate(item, now)).toList()
          ..sort(_compareByPriority);

    final explorationPool =
        items.where((item) => _isExplorationCandidate(item, now)).toList()
          ..sort(_compareByPriority);

    // Prioritize items that were not already placed in the most recent portion
    // of the queue. If the pool becomes too small, the ranker gracefully falls
    // back to repeated items instead of leaving the feed empty.
    final filteredFocus = _preferFreshItems(focusPool, recentIdSet);
    final filteredExploration = _preferFreshItems(explorationPool, recentIdSet);

    final focusQueue = filteredFocus.isNotEmpty ? filteredFocus : focusPool;
    final explorationQueue = filteredExploration.isNotEmpty
        ? filteredExploration
        : explorationPool;

    if (focusQueue.isEmpty && explorationQueue.isEmpty) {
      return const [];
    }

    final batch = <FeedItem>[];
    var focusIndex = 0;
    var explorationIndex = 0;

    for (int slot = 0; slot < batchSize; slot++) {
      final shouldExplore =
          explorationQueue.isNotEmpty &&
          slot > 0 &&
          slot % FeedPolicy.explorationInterval == 0;

      if (shouldExplore && explorationIndex < explorationQueue.length) {
        batch.add(explorationQueue[explorationIndex++]);
        continue;
      }

      if (focusIndex < focusQueue.length) {
        batch.add(focusQueue[focusIndex++]);
        continue;
      }

      if (explorationIndex < explorationQueue.length) {
        batch.add(explorationQueue[explorationIndex++]);
        continue;
      }

      // Once all unique candidates are exhausted, recycle from the ranked
      // pools. The fallback remains weighted toward focus items.
      final fallbackPool = focusQueue.isNotEmpty
          ? focusQueue
          : explorationQueue;
      batch.add(fallbackPool[random.nextInt(fallbackPool.length)]);
    }

    return batch;
  }

  bool _isExplorationCandidate(FeedItem item, DateTime now) {
    if (!item.learned) {
      return false;
    }

    final resurfaceAt = item.resurfaceAfter;
    if (resurfaceAt != null) {
      return !resurfaceAt.isAfter(now);
    }

    // Older data may not have a stored resurface timestamp. In that case we
    // fall back to the learned timestamp plus the default cooldown.
    if (item.lastLearnedAt != null) {
      final fallbackResurface = item.lastLearnedAt!.add(
        FeedPolicy.learnedResurfaceDelay,
      );
      return !fallbackResurface.isAfter(now);
    }

    return false;
  }

  List<FeedItem> _preferFreshItems(
    List<FeedItem> items,
    Set<String> recentIdSet,
  ) {
    final freshItems = items
        .where((item) => !recentIdSet.contains(item.id))
        .toList();
    return freshItems;
  }

  int _compareByPriority(FeedItem a, FeedItem b) {
    final scoreDelta = _priorityScore(b).compareTo(_priorityScore(a));
    if (scoreDelta != 0) {
      return scoreDelta;
    }

    // Use the content id as a deterministic tiebreaker so sort order remains
    // stable across rebuilds when two items score the same.
    return a.id.compareTo(b.id);
  }

  double _priorityScore(FeedItem item) {
    double score = item.learned ? 8 : 100;

    // The fewer times a card has been seen, the more the algorithm should favor
    // it as active study material.
    score -= item.seenCount * 4;

    final now = DateTime.now();
    final lastSeenAt = item.lastSeenAt;
    if (lastSeenAt == null) {
      score += 20;
    } else {
      final age = now.difference(lastSeenAt);
      score += min(age.inHours.toDouble(), 48);

      if (age >= FeedPolicy.staleItemThreshold) {
        score += 12;
      }
    }

    // Learned cards stay eligible, but they are intentionally much less
    // attractive than active cards unless exploration explicitly selects them.
    if (item.learned && item.resurfaceAfter != null) {
      final overdueHours = now.difference(item.resurfaceAfter!).inHours;
      score += max(0, overdueHours).toDouble().clamp(0, 24);
    }

    return score;
  }
}
