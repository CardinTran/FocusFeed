import 'package:flutter/material.dart';
import 'package:focusfeed/features/feed/feed_item.dart';
import 'package:focusfeed/features/feed/widgets/article_post_card.dart';
import 'package:focusfeed/features/feed/widgets/flashcard_post_card.dart';

class FeedPostCard extends StatelessWidget {
  final FeedItem item;
  final VoidCallback onChanged;

  const FeedPostCard({super.key, required this.item, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 80, 16, 24),
      child: item.type == FeedItemType.flashcard
          ? FlashcardPostCard(item: item, onChanged: onChanged)
          : ArticlePostCard(item: item, onChanged: onChanged),
    );
  }
}
