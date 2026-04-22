import 'package:flutter/material.dart';
import 'package:focusfeed/core/theme/app_colors.dart';

/// Dark-styled text field for use in the setup wizard.
/// Shows a white70 label and prefix [icon], with a purple border on focus.
class ThemedTextField extends StatelessWidget {
  const ThemedTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: AppColors.setupInput,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.purpleBright, width: 1.4),
        ),
      ),
    );
  }
}
