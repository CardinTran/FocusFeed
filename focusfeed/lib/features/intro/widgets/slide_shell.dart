import 'package:flutter/material.dart';
import 'package:focusfeed/core/theme/app_colors.dart';

class SlideShell extends StatelessWidget {
  final String tag;
  final String title;
  final String subtitle;
  final Widget content;

  const SlideShell({
    super.key,
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 120),
      child: Column(
        children: [
          Text(tag,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: AppColors.purpleLight)),
          const SizedBox(height: 10),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.2)),
          const SizedBox(height: 10),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.gray, height: 1.6)),
          const SizedBox(height: 24),
          Expanded(child: content),
        ],
      ),
    );
  }
}
