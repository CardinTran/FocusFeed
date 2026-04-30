import 'package:flutter/material.dart';
import 'package:focusfeed/core/theme/app_colors.dart';

class SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? sublabel;
  final Widget? trailing;
  final bool isDanger;
  final bool isLast;
  final VoidCallback? onTap;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    this.sublabel,
    this.trailing,
    this.isDanger = false,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(bottom: BorderSide(color: AppColors.grayDark.withValues(alpha: 0.1))),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: (isDanger ? AppColors.redCoral : iconColor).withValues(alpha: 0.1),
              ),
              child: Icon(icon, size: 18, color: isDanger ? AppColors.redCoral : iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDanger ? AppColors.redCoral : AppColors.white,
                    ),
                  ),
                  if (sublabel != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      sublabel!,
                      style: const TextStyle(fontSize: 11, color: AppColors.grayDark),
                    ),
                  ],
                ],
              ),
            ),
            ?trailing,
            if (trailing == null && onTap != null)
              Icon(Icons.chevron_right, size: 16, color: AppColors.grayDark.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}
