import 'package:flutter/material.dart';
import 'package:focusfeed/core/theme/app_colors.dart';
import 'slide_shell.dart';

const _steps = [
  ('📄', AppColors.purple, 'Import your notes', 'Paste text, upload a doc, or type freehand'),
  ('✨', AppColors.gold, 'AI generates cards', 'Flashcards, quizzes & explainers auto-created'),
  ('🚀', AppColors.green, 'Start studying instantly', 'Edit, remix, or share your deck'),
];

double _stagger(double v, double start, double end) =>
    Curves.easeOutCubic.transform(((v - start) / (end - start)).clamp(0.0, 1.0));

class SlideAIImport extends StatefulWidget {
  const SlideAIImport({super.key});

  @override
  State<SlideAIImport> createState() => _SlideAIImportState();
}

class _SlideAIImportState extends State<SlideAIImport>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
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
      tag: 'INSTANT SETUP',
      title: 'Your notes → ready decks',
      subtitle: 'Paste your notes and AI generates an\nentire deck in seconds.',
      content: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Column(
              children: List.generate(_steps.length, (i) {
                return AnimatedBuilder(
                  animation: _ctrl,
                  builder: (_, _) {
                    final t = _stagger(_ctrl.value, i * 0.2, i * 0.2 + 0.5);
                    return Opacity(
                      opacity: t,
                      child: Transform.translate(
                        offset: Offset(-16 * (1 - t), 0),
                        child: Column(
                          children: [
                            _AIStep(
                              emoji: _steps[i].$1,
                              color: _steps[i].$2,
                              label: _steps[i].$3,
                              sub: _steps[i].$4,
                            ),
                            if (i < _steps.length - 1)
                              const Divider(color: Colors.white10, height: 1),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: _MethodCard(
                  emoji: '📚',
                  label: 'Build manually',
                  sub: 'Create cards one by one',
                  highlighted: false,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const _MethodCard(
                      emoji: '🤖',
                      label: 'Generate with AI',
                      sub: 'Paste notes, done',
                      highlighted: true,
                    ),
                    Positioned(
                      top: -10,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                              color: AppColors.purple,
                              borderRadius: BorderRadius.circular(6)),
                          child: const Text('AI POWERED',
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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

class _AIStep extends StatelessWidget {
  final String emoji;
  final Color color;
  final String label;
  final String sub;

  const _AIStep({
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
          _EmojiIcon(emoji, color),
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
                    style:
                        const TextStyle(fontSize: 11, color: AppColors.gray)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String sub;
  final bool highlighted;

  const _MethodCard({
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
                ? AppColors.purple.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          const SizedBox(height: 3),
          Text(sub,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: AppColors.gray)),
        ],
      ),
    );
  }
}
