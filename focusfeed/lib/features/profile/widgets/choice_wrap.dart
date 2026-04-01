import 'package:flutter/material.dart';
import 'package:focusfeed/core/theme/app_colors.dart';

/// Flow-layout grid of selectable chips.
/// Selected chips are highlighted purple. Tapping any chip calls [onTap]
/// with the chip's value — the parent owns and updates [selections].
class ChoiceWrap extends StatelessWidget {
  const ChoiceWrap({
    super.key,
    required this.options,
    required this.selections,
    required this.onTap,
  });

  final List<String> options;
  final List<String> selections;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) {
        final isSelected = selections.contains(option);
        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          // Discard the bool argument — we manage toggle state in the parent.
          onSelected: (_) => onTap(option),
          selectedColor: AppColors.purpleBright,
          backgroundColor: AppColors.setupInput,
          side: BorderSide(
            color: isSelected ? AppColors.purpleBright : Colors.white10,
          ),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }).toList(),
    );
  }
}
