import 'package:flutter/material.dart';
import 'package:focusfeed/features/feed/feed_controller.dart';
import 'package:focusfeed/features/feed/feed_item.dart';
import 'package:focusfeed/features/feed/widgets/article_post_card.dart';
import 'package:focusfeed/features/feed/widgets/flashcard_post_card.dart';

class SavedScreen extends StatefulWidget {
  final List<FeedItem> items;
  final FeedController controller;
  final VoidCallback onUpdate;

  const SavedScreen({
    super.key,
    required this.items,
    required this.controller,
    required this.onUpdate,
  });

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  late List<FeedItem> _savedItems;

  @override
  void initState() {
    super.initState();
    _syncSavedItems();
  }

  @override
  void didUpdateWidget(covariant SavedScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncSavedItems();
  }

  void _syncSavedItems() {
    _savedItems = widget.items.where((item) => item.saved).toList();
  }

  void _handleItemChanged(FeedItem item) {
    setState(() {
      if (!item.saved) {
        _savedItems.removeWhere((savedItem) => savedItem.id == item.id);
      }
    });

    widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F2A),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Saved",
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
                    child: const Icon(Icons.bookmark, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _savedItems.isEmpty
                  ? const Center(
                      child: Text(
                        "No saved content yet.",
                        style: TextStyle(color: Colors.white70, fontSize: 18),
                      ),
                    )
                  : PageView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: _savedItems.length,
                      itemBuilder: (context, index) {
                        final item = _savedItems[index];

                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                          child: item.type == FeedItemType.flashcard
                              ? FlashcardPostCard(
                                  item: item,
                                  controller: widget.controller,
                                  onChanged: () => _handleItemChanged(item),
                                )
                              : ArticlePostCard(
                                  item: item,
                                  controller: widget.controller,
                                  onChanged: () => _handleItemChanged(item),
                                ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
