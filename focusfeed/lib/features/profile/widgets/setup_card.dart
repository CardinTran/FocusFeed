import 'package:flutter/material.dart';
import 'package:focusfeed/core/theme/app_colors.dart';

/// Dark rounded card container used on every page of the setup wizard.
/// Renders a [title], [subtitle], and a scrollable [child] content area.
class SetupCard extends StatelessWidget {
  const SetupCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.setupCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          // Expanded + SingleChildScrollView lets the content grow and
          // scroll without overflowing the card on smaller screens.
          Expanded(child: SingleChildScrollView(child: child)),
        ],
      ),
    );
  }
}
