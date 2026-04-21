/// Centralized tuning values for the adaptive feed.
///
/// Keeping these values in a dedicated file gives the project one obvious place
/// to adjust the algorithm without digging through widgets or Firestore code.
class FeedPolicy {
  /// Number of cards to append each time the feed queue needs more content.
  static const int batchSize = 20;

  /// Number of already-queued items the ranker should treat as "recent" and
  /// avoid repeating when enough alternatives exist.
  static const int recentQueueWindow = 12;

  /// Every Nth slot is allowed to try an exploration item first.
  ///
  /// A value of 5 means the feed is still strongly focused on active study
  /// content while periodically resurfacing learned items.
  static const int explorationInterval = 5;

  /// How long a learned card should stay out of the main feed before it is
  /// eligible to reappear as an exploration candidate.
  static const Duration learnedResurfaceDelay = Duration(days: 3);

  /// Small boost for items the user has not seen in a while.
  static const Duration staleItemThreshold = Duration(days: 2);
}
