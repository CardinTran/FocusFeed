import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focusfeed/features/feed/feed_item.dart';
import 'package:focusfeed/features/feed/widgets/feed_action_buttons.dart';
import 'package:focusfeed/features/import/import_repository.dart';

class ArticlePostCard extends StatefulWidget {
  final FeedItem item;
  final VoidCallback onChanged;

  const ArticlePostCard({
    super.key,
    required this.item,
    required this.onChanged,
  });

  @override
  State<ArticlePostCard> createState() => _ArticlePostCardState();
}

class _ArticlePostCardState extends State<ArticlePostCard> {
  bool _isUpdating = false;

  Future<void> _toggleLearned() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || widget.item.importId == null || _isUpdating) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      await ImportRepository().updateLearned(
        userId: user.uid,
        importId: widget.item.importId!,
        cardId: widget.item.id,
        learned: !widget.item.learned,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _toggleSaved() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || widget.item.importId == null || _isUpdating) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      await ImportRepository().updateSaved(
        userId: user.uid,
        importId: widget.item.importId!,
        cardId: widget.item.id,
        saved: !widget.item.saved,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

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
                onTap: _toggleLearned,
              ),
              const SizedBox(height: 18),
              RightSideActionButton(
                icon: item.saved ? Icons.bookmark : Icons.bookmark_border,
                label: "Save",
                iconColor: item.saved
                    ? const Color.fromRGBO(133, 90, 251, 1)
                    : Colors.white,
                onTap: _toggleSaved,
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
