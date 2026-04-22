import 'package:flutter/material.dart';
import 'package:focusfeed/core/theme/app_colors.dart';
import 'slide_shell.dart';

const _friends = [
  ('JK', 'Jordan K.', AppColors.purple, AppColors.purpleLight),
  ('AM', 'Aisha M.', AppColors.green, Color(0xFF55EFC4)),
  ('TR', 'Tyler R.', AppColors.gold, Color(0xFFE17055)),
];

double _stagger(double v, double start, double end) =>
    Curves.easeOutCubic.transform(((v - start) / (end - start)).clamp(0.0, 1.0));

class SlideFriends extends StatefulWidget {
  const SlideFriends({super.key});

  @override
  State<SlideFriends> createState() => _SlideFriendsState();
}

class _SlideFriendsState extends State<SlideFriends>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
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
      tag: 'BETTER TOGETHER',
      title: 'Study with friends',
      subtitle: 'Share decks, challenge each other,\nand stay accountable.',
      content: Column(
        children: List.generate(_friends.length, (i) {
          return AnimatedBuilder(
            animation: _ctrl,
            builder: (_, _) {
              final t = _stagger(_ctrl.value, i * 0.15, i * 0.15 + 0.5);
              return Opacity(
                opacity: t,
                child: Transform.scale(
                  scale: 0.95 + 0.05 * t,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _FriendRow(
                      initials: _friends[i].$1,
                      name: _friends[i].$2,
                      fromColor: _friends[i].$3,
                      toColor: _friends[i].$4,
                    ),
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

class _FriendRow extends StatelessWidget {
  final String initials;
  final String name;
  final Color fromColor;
  final Color toColor;

  const _FriendRow({
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
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [fromColor, toColor],
              ),
            ),
            child: Text(initials,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
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
