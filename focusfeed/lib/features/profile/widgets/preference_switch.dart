import 'package:flutter/material.dart';
import 'package:focusfeed/core/theme/app_colors.dart';

/// A labeled toggle row with a [title], [subtitle], and a [Switch].
/// The parent owns the boolean state and passes it in via [value] and [onChanged].
class PreferenceSwitch extends StatelessWidget {
  const PreferenceSwitch({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.setupInput,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.purpleBright,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
