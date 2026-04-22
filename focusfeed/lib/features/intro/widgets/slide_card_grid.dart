import 'package:flutter/material.dart';
import 'package:focusfeed/core/theme/app_colors.dart';
import 'slide_shell.dart';

const _types = [
  ('🃏', 'Flashcard', 'Tap to flip. Classic active recall.', AppColors.purple),
  ('⚡', 'Quick Quiz', '4-option MCQ. Instant feedback.', AppColors.redCoral),
  ('✏️', 'Fill in Blank', 'Type the missing word or phrase.', AppColors.gold),
  ('💡', 'Explainer', 'Bite-sized concept breakdowns.', AppColors.green),
];

double _stagger(double v, double start, double end) =>
    Curves.easeOutCubic.transform(((v - start) / (end - start)).clamp(0.0, 1.0));

class SlideCardGrid extends StatefulWidget {
  const SlideCardGrid({super.key});

  @override
  State<SlideCardGrid> createState() => _SlideCardGridState();
}

class _SlideCardGridState extends State<SlideCardGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideShell(
      tag: '4 WAYS TO STUDY',
      title: 'Every style, one feed',
      subtitle: 'Mix and match study modes so you never get bored.',
      content: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(_types.length, (i) {
          return AnimatedBuilder(
            animation: _ctrl,
            builder: (_, _) {
              final t = _stagger(_ctrl.value, i * 0.15, i * 0.15 + 0.5);
              return Opacity(
                opacity: t,
                child: Transform.translate(
                  offset: Offset(0, 24 * (1 - t)),
                  child: _TypeCard(
                    emoji: _types[i].$1,
                    name: _types[i].$2,
                    desc: _types[i].$3,
                    color: _types[i].$4,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

class _EmojiIcon extends StatelessWidget {
  final String emoji;
  final Color color;
  const _EmojiIcon(this.emoji, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 18)),
    );
  }
}

class _TypeCard extends StatelessWidget {
  final String emoji;
  final String name;
  final String desc;
  final Color color;

  const _TypeCard({
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
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _EmojiIcon(emoji, color),
          const SizedBox(height: 10),
          Text(name,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 4),
          Text(desc,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.gray, height: 1.5)),
        ],
      ),
    );
  }
}
