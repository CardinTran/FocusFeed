import 'package:flutter/material.dart';
import 'package:focusfeed/features/feed/feed_controller.dart';
import 'package:focusfeed/features/feed/feed_item.dart';
import 'package:focusfeed/features/feed/widgets/article_post_card.dart';
import 'package:focusfeed/features/feed/widgets/explainer_post_card.dart';
import 'package:focusfeed/features/feed/widgets/fill_in_blank_post_card.dart';
import 'package:focusfeed/features/feed/widgets/flashcard_post_card.dart';
import 'package:focusfeed/features/feed/widgets/quiz_post_card.dart';

class FeedPostCard extends StatelessWidget {
  final FeedItem item;
  final FeedController controller;
  final VoidCallback onChanged;

  const FeedPostCard({
    super.key,
    required this.item,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 80, 16, 24),
      child: switch (item.type) {
        FeedItemType.flashcard => FlashcardPostCard(item: item, controller: controller, onChanged: onChanged),
        FeedItemType.quiz => QuizPostCard(item: item, onChanged: onChanged),
        FeedItemType.fillInBlank => FillInBlankPostCard(item: item, onChanged: onChanged),
        FeedItemType.explainer => ExplainerPostCard(item: item, onChanged: onChanged),
        _ => ArticlePostCard(item: item, controller: controller, onChanged: onChanged),
      },
    );
  }
}
