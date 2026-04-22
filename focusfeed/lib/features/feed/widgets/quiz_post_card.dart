import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focusfeed/features/feed/feed_item.dart';
import 'package:focusfeed/features/feed/widgets/feed_action_buttons.dart';
import 'package:focusfeed/features/import/import_repository.dart';

class QuizPostCard extends StatefulWidget {
  final FeedItem item;
  final VoidCallback onChanged;

  const QuizPostCard({super.key, required this.item, required this.onChanged});

  @override
  State<QuizPostCard> createState() => _QuizPostCardState();
}

class _QuizPostCardState extends State<QuizPostCard> {
  int? _selectedIndex;

  bool get _hasAnswered => _selectedIndex != null;

  @override
  void didUpdateWidget(covariant QuizPostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item != widget.item) {
      _selectedIndex = null;
    }
  }

  Color _optionColor(int index) {
    if (!_hasAnswered) return const Color(0xFF1E2252);
    if (index == widget.item.correctIndex) return const Color(0xFF00B894);
    if (index == _selectedIndex) return const Color(0xFFFF6B6B);
    return const Color(0xFF1E2252);
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.item.options ?? [];

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
                        'QUICK QUIZ',
                        style: TextStyle(
                          color: widget.item.categoryColor,
                          fontSize: 20,
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
                        child: Icon(Icons.quiz_outlined, color: widget.item.categoryColor, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.item.question ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...List.generate(options.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: _hasAnswered ? null : () => setState(() => _selectedIndex = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          decoration: BoxDecoration(
                            color: _optionColor(i),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Text(
                            options[i],
                            style: const TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ),
                      ),
                    );
                  }),
                  if (_hasAnswered)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _selectedIndex == widget.item.correctIndex ? '✓ Correct!' : '✗ Incorrect',
                          style: TextStyle(
                            color: _selectedIndex == widget.item.correctIndex
                                ? const Color(0xFF00B894)
                                : const Color(0xFFFF6B6B),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
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
