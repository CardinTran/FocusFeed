import 'package:flutter/material.dart';
import 'package:focusfeed/features/profile/widgets/setup_card.dart';
import 'package:focusfeed/features/profile/widgets/choice_wrap.dart';
import 'package:focusfeed/features/profile/widgets/preference_switch.dart';

/// Setup wizard page 2 — subject interests and app preference toggles.
class SetupStepPreferences extends StatelessWidget {
  const SetupStepPreferences({
    super.key,
    required this.selectedSubjects,
    required this.onSubjectTap,
    required this.notificationsEnabled,
    required this.onNotificationsChanged,
    required this.autoGenerateFlashcards,
    required this.onAutoGenerateChanged,
  });

  static const List<String> availableSubjects = [
    'Finance',
    'Economics',
    'Technology',
    'AI',
    'Biology',
    'Chemistry',
    'Physics',
    'History',
    'Literature',
    'Psychology',
    'Business',
    'Math',
  ];

  final List<String> selectedSubjects;
  final ValueChanged<String> onSubjectTap;
  final bool notificationsEnabled;
  final ValueChanged<bool> onNotificationsChanged;
  final bool autoGenerateFlashcards;
  final ValueChanged<bool> onAutoGenerateChanged;

  @override
  Widget build(BuildContext context) {
    return SetupCard(
      title: 'Finish your preferences',
      subtitle: 'Select topics and a couple of app defaults.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChoiceWrap(
            options: availableSubjects,
            selections: selectedSubjects,
            onTap: onSubjectTap,
          ),
          const SizedBox(height: 18),
          PreferenceSwitch(
            title: 'Notifications',
            subtitle: 'Enable reminders and updates',
            value: notificationsEnabled,
            onChanged: onNotificationsChanged,
          ),
          const SizedBox(height: 12),
          PreferenceSwitch(
            title: 'Auto-generate flashcards',
            subtitle: 'Create flashcards from imported study content',
            value: autoGenerateFlashcards,
            onChanged: onAutoGenerateChanged,
          ),
        ],
      ),
    );
  }
}
