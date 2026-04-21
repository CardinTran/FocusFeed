import 'package:flutter/material.dart';
import 'package:focusfeed/core/theme/app_colors.dart';

class MiniCard extends StatelessWidget {
  final double top;
  final Color accent;
  final String label;
  final IconData labelIcon;
  final String question;
  final Widget extra;

  const MiniCard({
    super.key,
    required this.top,
    required this.accent,
    required this.label,
    required this.labelIcon,
    required this.question,
    required this.extra,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: 0,
      right: 0,
      child: Container(
        height: 400,
        color: AppColors.cardBackground,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 3, color: accent),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(label,
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                              color: accent)),
                      Icon(labelIcon, color: accent, size: 14),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      question,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 20),
                  extra,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MiniFlipHint extends StatelessWidget {
  const MiniFlipHint({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.rotate_left, color: Colors.white38, size: 11),
          SizedBox(width: 4),
          Text('Tap to reveal answer',
              style: TextStyle(fontSize: 9, color: Colors.white38)),
        ],
      ),
    );
  }
}

class MiniFillInput extends StatelessWidget {
  const MiniFillInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: const Text('Type your answer...',
          style: TextStyle(fontSize: 9, color: Colors.white38)),
    );
  }
}

class MiniOption extends StatelessWidget {
  final String text;
  final bool correct;

  const MiniOption(this.text, this.correct, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: correct
            ? AppColors.redCoral.withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: correct ? AppColors.redCoral : Colors.white24),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 9,
              color: correct ? AppColors.redCoral : Colors.white70)),
    );
  }
}
