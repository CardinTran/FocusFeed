import 'package:flutter/material.dart';
import 'package:focusfeed/core/theme/app_colors.dart';

// Slide 1 widgets — scrolling card mockup
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
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
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
        color: Colors.white.withOpacity(0.05),
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
        color: correct ? AppColors.redCoral.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: correct ? AppColors.redCoral : Colors.white24,
        ),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 9,
              color: correct ? AppColors.redCoral : Colors.white70)),
    );
  }
}

// Slide 2 widgets — card type grid
class TypeCard extends StatelessWidget {
  final String emoji;
  final String name;
  final String desc;
  final Color color;

  const TypeCard({
    super.key,
    required this.emoji,
    required this.name,
    required this.desc,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(height: 10),
          Text(name,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 4),
          Text(desc,
              style: const TextStyle(fontSize: 11, color: AppColors.gray, height: 1.5)),
        ],
      ),
    );
  }
}

// Slide 3 widgets — AI import steps
class AIStep extends StatelessWidget {
  final String emoji;
  final Color color;
  final String label;
  final String sub;

  const AIStep({
    super.key,
    required this.emoji,
    required this.color,
    required this.label,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                const SizedBox(height: 2),
                Text(sub,
                    style: const TextStyle(fontSize: 11, color: AppColors.gray)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MethodCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String sub;
  final bool highlighted;

  const MethodCard({
    super.key,
    required this.emoji,
    required this.label,
    required this.sub,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: highlighted
                ? AppColors.purple.withOpacity(0.4)
                : Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 3),
          Text(sub,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: AppColors.gray)),
        ],
      ),
    );
  }
}

// Slide 4 widgets — friends list
class FriendRow extends StatelessWidget {
  final String initials;
  final String name;
  final Color fromColor;
  final Color toColor;

  const FriendRow({
    super.key,
    required this.initials,
    required this.name,
    required this.fromColor,
    required this.toColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [fromColor, toColor],
              ),
            ),
            child: Center(
              child: Text(initials,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
          const SizedBox(width: 12),
          Text(name,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
        ],
      ),
    );
  }
}