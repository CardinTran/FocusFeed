import 'package:flutter/material.dart';
import 'package:focusfeed/features/feed/feed_controller.dart';
import 'package:focusfeed/features/feed/feed_item.dart';
import 'package:focusfeed/features/feed/widgets/feed_post_card.dart';

class FeedScreen extends StatefulWidget {
  final List<FeedItem> items;
  final FeedController controller;
  final VoidCallback onUpdate;

  const FeedScreen({
    super.key,
    required this.items,
    required this.controller,
    required this.onUpdate,
  });

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final List<FeedItem> _feedQueue = [];
  int _lastSeenIndex = -1;

  @override
  void initState() {
    super.initState();
    _fillQueue();

    // The first card is visible immediately, so the feed records it after the
    // first frame instead of waiting for the first swipe event.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recordVisibleItem(0);
    });
  }

  @override
  void didUpdateWidget(covariant FeedScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    final latestById = {for (final item in widget.items) item.id: item};

    for (int i = 0; i < _feedQueue.length; i++) {
      final current = _feedQueue[i];
      final updated = latestById[current.id];

      if (updated != null) {
        _feedQueue[i] = updated;
      }
    }

    for (int i = _feedQueue.length - 1; i >= 0; i--) {
      final item = _feedQueue[i];
      final updated = latestById[item.id];

      // If an item no longer exists in the source stream, remove it from the
      // local queue so pagination does not hold onto stale content.
      if (updated == null) {
        _feedQueue.removeAt(i);
        continue;
      }

      _feedQueue[i] = updated;
    }

    if (_feedQueue.isEmpty && widget.items.isNotEmpty) {
      _fillQueue();
    }
  }

  void _fillQueue({bool reset = false}) {
    if (reset) {
      _feedQueue.clear();
    }

    if (widget.items.isEmpty) return;

    final recentIds = _feedQueue.reversed.map((item) => item.id).toList();
    final nextBatch = widget.controller.buildNextBatch(
      items: widget.items,
      recentlyQueuedIds: recentIds,
    );

    _feedQueue.addAll(nextBatch);
  }

  Future<void> _recordVisibleItem(int index) async {
    if (index < 0 || index >= _feedQueue.length) {
      return;
    }

    if (_lastSeenIndex == index) {
      return;
    }

    _lastSeenIndex = index;
    await widget.controller.markSeen(_feedQueue[index]);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B0F2A),
        body: SafeArea(
          child: Center(
            child: Text(
              'No flashcards yet',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F2A),
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: _feedQueue.length,
              onPageChanged: (index) async {
                await _recordVisibleItem(index);

                if (index >= _feedQueue.length - 5) {
                  setState(() {
                    _fillQueue();
                  });
                }
              },
              itemBuilder: (context, index) {
                final item = _feedQueue[index];
                return FeedPostCard(
                  key: ValueKey('${item.question}-${item.answer}-$index'),
                  item: item,
                  controller: widget.controller,
                  onChanged: widget.onUpdate,
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "FocusFeed",
                    style: TextStyle(
                      color: Color.fromRGBO(133, 90, 251, 1),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.search, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
