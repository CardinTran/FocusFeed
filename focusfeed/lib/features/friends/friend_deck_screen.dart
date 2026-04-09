import 'package:flutter/material.dart';
import 'package:focusfeed/features/feed/feed_item.dart';

class FriendDeckScreen extends StatefulWidget {
  final String friendName;
  final List<FeedItem> cards;

  const FriendDeckScreen({
    super.key,
    required this.friendName,
    required this.cards,
  });

  @override
  State<FriendDeckScreen> createState() => _FriendDeckScreenState();
}

class _FriendDeckScreenState extends State<FriendDeckScreen> {
  static const Color _bg     = Color(0xFF0B0F2A);
  static const Color _card   = Color(0xFF151A3B);
  static const Color _accent = Color(0xFF855AFB);
  static const Color _border = Color(0x12FFFFFF);

  int _current = 0;
  bool _flipped = false;

  void _next() {
    if (_current < widget.cards.length - 1) {
      setState(() { _current++; _flipped = false; });
    }
  }

  void _prev() {
    if (_current > 0) {
      setState(() { _current--; _flipped = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.cards[_current];

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF12182F),
        title: Text("${widget.friendName}'s Deck",
            style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          // Progress
          Text(
            '${_current + 1} of ${widget.cards.length}',
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_current + 1) / widget.cards.length,
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation(_accent),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 32),

          // Flashcard — tap to flip
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _flipped = !_flipped),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  key: ValueKey(_flipped),
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: _flipped
                        ? _accent.withValues(alpha: 0.15)
                        : _card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _flipped
                          ? _accent.withValues(alpha: 0.4)
                          : _border,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _flipped ? 'Answer' : 'Question',
                        style: TextStyle(
                          color: _flipped ? _accent : Colors.white38,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _flipped
                            ? card.answer ?? ''
                            : card.question ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            height: 1.4),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Tap to flip',
                        style: const TextStyle(
                            color: Colors.white24, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Navigation buttons
          Row(children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white12),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _current > 0 ? _prev : null,
                child: const Text('Previous'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _current < widget.cards.length - 1 ? _next : null,
                child: const Text('Next',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}