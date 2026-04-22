import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focusfeed/features/feed/feed_item.dart';
import 'package:focusfeed/features/feed/widgets/feed_action_buttons.dart';
import 'package:focusfeed/features/import/import_repository.dart';

class FlashcardPostCard extends StatefulWidget {
  final FeedItem item;
  final VoidCallback onChanged;

  const FlashcardPostCard({
    super.key,
    required this.item,
    required this.onChanged,
  });

  @override
  State<FlashcardPostCard> createState() => _FlashcardPostCardState();
}

class _FlashcardPostCardState extends State<FlashcardPostCard>
    with SingleTickerProviderStateMixin {
  bool _showAnswer = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(covariant FlashcardPostCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.item != widget.item) {
      _controller.reset();
      _showAnswer = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildCardFace(String text) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.bold,
          height: 1.25,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (_controller.isCompleted) {
                  _controller.reverse();
                  _showAnswer = false;
                } else {
                  _controller.forward();
                  _showAnswer = true;
                }
              });
            },
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1D4A),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
                border: Border(
                  top: BorderSide(color: widget.item.categoryColor, width: 4),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.item.deckTitle ?? "FLASHCARD",
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
                          child: Icon(
                            widget.item.deckIcon ?? Icons.style_outlined,
                            color: widget.item.categoryColor,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Center(
                      child: AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          final isFront = _animation.value < 0.5;
                          final angle = _animation.value * 3.1416;

                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(angle),
                            child: isFront
                                ? _buildCardFace(widget.item.question ?? "")
                                : Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.identity()
                                      ..rotateY(3.1416),
                                    child: _buildCardFace(
                                      widget.item.answer ?? "",
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 22),
                    Center(
                      child: Text(
                        _showAnswer
                            ? "Tap to show question"
                            : "Tap to reveal answer",
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            BottomActionButton(
              icon: widget.item.learned
                  ? Icons.check_circle
                  : Icons.school_outlined,
              label: widget.item.learned ? "Learned" : "Studying",
              iconColor: widget.item.learned
                  ? Colors.greenAccent
                  : Colors.white,
              onTap: () async {
                final newValue = !widget.item.learned;

                setState(() {
                  widget.item.learned = newValue;
                });

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
              label: "Save",
              iconColor: widget.item.saved
                  ? const Color.fromRGBO(133, 90, 251, 1)
                  : Colors.white,
              onTap: () async {
                final newValue = !widget.item.saved;

                setState(() {
                  widget.item.saved = newValue;
                });

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
