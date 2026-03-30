import 'package:flutter/material.dart';
import 'package:focusfeed/features/screens/library/library_deck.dart';
import 'package:focusfeed/features/screens/library/widgets/deck_card.dart';

class DeckGrid extends StatelessWidget {
  final List<LibraryDeck> decks;
  final ValueChanged<LibraryDeck> onDeckTap;
  final ValueChanged<LibraryDeck> onDeleteTap;

  const DeckGrid({
    super.key,
    required this.decks,
    required this.onDeckTap,
    required this.onDeleteTap,
  });

  static const List<Color> _accentColors = [
    Color(0xFF5B5FFF),
    Color(0xFFF2A65A),
    Color(0xFF00D1B2),
    Color(0xFFFF6B6B),
    Color(0xFF8B6CFF),
    Color(0xFFFFC857),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: decks.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 18,
        mainAxisSpacing: 24,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final deck = decks[index];
        final color = _accentColors[index % _accentColors.length];

        return DeckCard(
          deck: deck,
          accentColor: color,
          onTap: () => onDeckTap(deck),
          onDelete: () => onDeleteTap(deck),
        );
      },
    );
  }
}
