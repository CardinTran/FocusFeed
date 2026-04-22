import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focusfeed/features/feed/feed_item.dart';
import 'package:focusfeed/features/feed/widgets/feed_action_buttons.dart';
import 'package:focusfeed/features/import/import_repository.dart';

class ExplainerPostCard extends StatefulWidget {
  final FeedItem item;
  final VoidCallback onChanged;

  const ExplainerPostCard({super.key, required this.item, required this.onChanged});

  @override
  State<ExplainerPostCard> createState() => _ExplainerPostCardState();
}

class _ExplainerPostCardState extends State<ExplainerPostCard> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D4A),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 18, offset: Offset(0, 8)),
              ],
              border: Border(top: BorderSide(color: widget.item.categoryColor, width: 4)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'MICRO-EXPLAINER',
                        style: TextStyle(
                          color: widget.item.categoryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.lightbulb_outline, color: widget.item.categoryColor, size: 20),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    widget.item.title ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.item.description ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            BottomActionButton(
              icon: widget.item.learned ? Icons.check_circle : Icons.school_outlined,
              label: widget.item.learned ? 'Learned' : 'Studying',
              iconColor: widget.item.learned ? Colors.greenAccent : Colors.white,
              onTap: () async {
                final newValue = !widget.item.learned;
                setState(() => widget.item.learned = newValue);
                final user = FirebaseAuth.instance.currentUser;
                if (user == null || widget.item.importId == null) return;
                await ImportRepository().updateLearned(
                  userId: user.uid,
                  importId: widget.item.importId!,
                  cardId: widget.item.id,
                  learned: newValue,
                );
                widget.onChanged();
              },
            ),
            BottomActionButton(
              icon: widget.item.saved ? Icons.bookmark : Icons.bookmark_border,
              label: 'Save',
              iconColor: widget.item.saved ? const Color(0xFF855AFB) : Colors.white,
              onTap: () async {
                final newValue = !widget.item.saved;
                setState(() => widget.item.saved = newValue);
                final user = FirebaseAuth.instance.currentUser;
                if (user == null || widget.item.importId == null) return;
                await ImportRepository().updateSaved(
                  userId: user.uid,
                  importId: widget.item.importId!,
                  cardId: widget.item.id,
                  saved: newValue,
                );
                widget.onChanged();
              },
            ),
          ],
        ),
      ],
    );
  }
}
