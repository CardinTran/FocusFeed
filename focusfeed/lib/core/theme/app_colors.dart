import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const Color purple = Color(0xFF6C5CE7);
  static const Color purpleLight = Color(0xFFA29BFE);
  static const Color purpleBackground = Color(0xFF1E1B4B);

  // Backgrounds
  static const Color dark = Color(0xFF0F0F23);
  static const Color navy = Color(0xFF1A1A3E);
  static const Color cardBackground = Color(0xFF1E1E3A);
  static const Color offWhite = Color(0xFFF8F9FC);
  static const Color white = Color(0xFFFFFFFF);

  // Semantic
  static const Color green = Color(0xFF00B894);
  static const Color redCoral = Color(0xFFFF6B6B);
  static const Color gold = Color(0xFFFDCB6E);

  // Text
  static const Color gray = Color(0xFF94A3B8);
  static const Color grayDark = Color(0xFF64748B);
  static const Color grayLight = Color(0xFFE2E8F0);

  // Card type accent colors
  static const Color cardFlashcard = purple;
  static const Color cardQuiz = redCoral;
  static const Color cardFillInBlank = gold;
  static const Color cardExplainer = green;
  static const Color cardProgress = purpleLight;
  static const Color cardChallenge = redCoral;

  // Onboarding / profile setup flow colors
  // These are specific to the setup wizard screens and differ slightly
  // from the main app dark palette to create a distinct onboarding feel.

  /// Deep dark navy used as the full-screen background in the setup flow.
  static const Color setupBackground = Color(0xFF0B0F2A);

  /// Slightly lighter navy used as the card/panel surface in the setup flow.
  static const Color setupCard = Color(0xFF151A3B);

  /// Dark fill color used inside text fields and unselected chips in the setup flow.
  static const Color setupInput = Color(0xFF0F1433);

  /// Brighter purple accent used for buttons, selected chips, and active borders
  /// in the auth and setup screens. Distinct from [purple] (#6C5CE7).
  static const Color purpleBright = Color(0xFF855AFB);
}
