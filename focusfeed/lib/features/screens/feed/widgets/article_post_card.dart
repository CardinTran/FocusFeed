import 'package:flutter/material.dart';
import 'package:focusfeed/features/screens/feed/feed_item.dart';
import 'package:focusfeed/features/screens/feed/widgets/feed_action_buttons.dart';

class ArticlePostCard extends StatelessWidget {
  final FeedItem item;
  final VoidCallback onChanged;

  const ArticlePostCard({
    super.key,
    required this.item,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF151936),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        Positioned(
          right: 14,
          bottom: 155,
          child: Column(
            children: [
              RightSideActionButton(
                icon: item.learned ? Icons.check_circle : Icons.school_outlined,
                label: item.learned ? "Learned" : "Studying",
                iconColor: item.learned ? Colors.greenAccent : Colors.white,
                onTap: () {
                  item.learned = !item.learned;
                  onChanged();
                },
              ),
              const SizedBox(height: 18),
              RightSideActionButton(
                icon: item.bookmarked ? Icons.bookmark : Icons.bookmark_border,
                label: "Save",
                iconColor: item.bookmarked
                    ? const Color.fromRGBO(133, 90, 251, 1)
                    : Colors.white,
                onTap: () {
                  item.bookmarked = !item.bookmarked;
                  onChanged();
                },
              ),
            ],
          ),
        ),
        Positioned(
          left: 16,
          right: 90,
          bottom: 28,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: item.categoryBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.category,
                  style: TextStyle(
                    color: item.categoryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                item.title ?? "",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                item.description ?? "",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
