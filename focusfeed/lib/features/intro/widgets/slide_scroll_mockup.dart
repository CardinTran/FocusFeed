import 'package:flutter/material.dart';
import 'package:focusfeed/core/theme/app_colors.dart';
import 'mini_card.dart';
import 'slide_shell.dart';

class SlideScrollMockup extends StatefulWidget {
  const SlideScrollMockup({super.key});

  @override
  State<SlideScrollMockup> createState() => _SlideScrollMockupState();
}

class _SlideScrollMockupState extends State<SlideScrollMockup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideShell(
      tag: 'STUDY DIFFERENTLY',
      title: 'Learn like you scroll',
      subtitle:
          'Swipe through flashcards, quizzes, and\nexplainers — just like your feed.',
      content: Center(
        child: Container(
          width: 210,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          clipBehavior: Clip.hardEdge,
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, _) {
              final offset = _ctrl.value * 400;
              return Stack(
                children: [
                  MiniCard(
                    top: 0 - offset,
                    accent: AppColors.purple,
                    label: 'FLASHCARD',
                    labelIcon: Icons.credit_card,
                    question: 'What is photosynthesis?',
                    extra: const MiniFlipHint(),
                  ),
                  MiniCard(
                    top: 400 - offset,
                    accent: AppColors.redCoral,
                    label: 'QUICK QUIZ',
                    labelIcon: Icons.help_outline,
                    question: 'Which organelle produces ATP?',
                    extra: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MiniOption('A. Nucleus', false),
                        SizedBox(height: 4),
                        MiniOption('B. Mitochondria', false),
                        SizedBox(height: 4),
                        MiniOption('C. Ribosome', false),
                        SizedBox(height: 4),
                        MiniOption('D. Vacuole', false),
                      ],
                    ),
                  ),
                  MiniCard(
                    top: 800 - offset,
                    accent: AppColors.gold,
                    label: 'FILL IN BLANK',
                    labelIcon: Icons.edit_outlined,
                    question: "DNA is stored in the cell's _____.",
                    extra: const MiniFillInput(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
