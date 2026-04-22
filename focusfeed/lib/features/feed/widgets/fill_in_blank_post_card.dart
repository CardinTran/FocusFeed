import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focusfeed/features/feed/feed_item.dart';
import 'package:focusfeed/features/feed/widgets/feed_action_buttons.dart';
import 'package:focusfeed/features/import/import_repository.dart';

class FillInBlankPostCard extends StatefulWidget {
  final FeedItem item;
  final VoidCallback onChanged;

  const FillInBlankPostCard({super.key, required this.item, required this.onChanged});

  @override
  State<FillInBlankPostCard> createState() => _FillInBlankPostCardState();
}

class _FillInBlankPostCardState extends State<FillInBlankPostCard> {
  final _textController = TextEditingController();
  bool? _isCorrect;

  @override
  void didUpdateWidget(covariant FillInBlankPostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item != widget.item) {
      _textController.clear();
      _isCorrect = null;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submit() {
    final input = _textController.text.trim().toLowerCase();
    final answer = (widget.item.answer ?? '').trim().toLowerCase();
    setState(() => _isCorrect = input == answer);
  }

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
                        'FILL IN THE BLANK',
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
                        child: Icon(Icons.edit_outlined, color: widget.item.categoryColor, size: 20),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    widget.item.sentence ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (_isCorrect == null) ...[
                    TextField(
                      controller: _textController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Type your answer...',
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: const Color(0xFF12182F),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.item.categoryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Check',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ] else ...[
                    Center(
                      child: Column(
                        children: [
                          Text(
                            _isCorrect! ? '✓ Correct!' : '✗ Incorrect',
                            style: TextStyle(
                              color: _isCorrect! ? const Color(0xFF00B894) : const Color(0xFFFF6B6B),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (!_isCorrect!) ...[
                            const SizedBox(height: 10),
                            Text(
                              'Answer: ${widget.item.answer}',
                              style: const TextStyle(color: Colors.white70, fontSize: 15),
                            ),
                          ],
                          const SizedBox(height: 14),
                          TextButton(
                            onPressed: () => setState(() {
                              _textController.clear();
                              _isCorrect = null;
                            }),
                            child: const Text('Try again', style: TextStyle(color: Colors.white54)),
                          ),
                        ],
                      ),
                    ),
                  ],
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
