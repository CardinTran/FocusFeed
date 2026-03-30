import 'dart:math';
import 'package:flutter/material.dart';
import 'package:focusfeed/features/screens/feed/feed_item.dart';
import 'package:focusfeed/features/screens/feed/widgets/feed_post_card.dart';

class FeedScreen extends StatefulWidget {
  final List<FeedItem> items;
  final VoidCallback onUpdate;

  const FeedScreen({super.key, required this.items, required this.onUpdate});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final Random _random = Random();

  late List<FeedItem> _cycleItems;
  final List<FeedItem> _feedQueue = [];

  @override
  void initState() {
    super.initState();
    _cycleItems = [];
    _rebuildCycle();
    _fillQueue();
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

    _cycleItems = _cycleItems
        .map((item) => latestById[item.id] ?? item)
        .toList();

    if (oldWidget.items.length != widget.items.length) {
      _rebuildCycle();
      _fillQueue(reset: true);
    }
  }

  void _rebuildCycle() {
    _cycleItems = List<FeedItem>.from(widget.items);
    _cycleItems.shuffle(_random);
  }

  void _fillQueue({bool reset = false}) {
    if (reset) {
      _feedQueue.clear();
    }

    if (widget.items.isEmpty) return;

    const int batchSize = 20;

    for (int i = 0; i < batchSize; i++) {
      if (_cycleItems.isEmpty) {
        _rebuildCycle();
      }

      _feedQueue.add(_cycleItems.removeAt(0));
    }
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
              onPageChanged: (index) {
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
