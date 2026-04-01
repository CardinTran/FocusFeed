import 'package:flutter/material.dart';
import 'package:focusfeed/features/profile/widgets/setup_card.dart';
import 'package:focusfeed/features/profile/widgets/choice_wrap.dart';

/// Setup wizard page 1 — lets the user pick which courses to prioritize.
class SetupStepCourses extends StatelessWidget {
  const SetupStepCourses({
    super.key,
    required this.selectedCourses,
    required this.onTap,
  });

  static const List<String> availableCourses = [
    'Economics',
    'Calculus',
    'Statistics',
    'Psychology',
    'Accounting',
    'Computer Science',
    'Marketing',
    'Biology',
    'English',
  ];

  final List<String> selectedCourses;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return SetupCard(
      title: 'Pick your courses',
      subtitle: 'Choose the classes you want FocusFeed to prioritize.',
      child: ChoiceWrap(
        options: availableCourses,
        selections: selectedCourses,
        onTap: onTap,
      ),
    );
  }
}
