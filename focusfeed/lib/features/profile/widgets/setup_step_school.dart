import 'package:flutter/material.dart';
import 'package:focusfeed/features/profile/widgets/setup_card.dart';
import 'package:focusfeed/features/profile/widgets/themed_text_field.dart';

/// Setup wizard page 0 — asks the user which school they attend.
/// The [controller] is owned by the parent so it can read the value
/// during validation and save.
class SetupStepSchool extends StatelessWidget {
  const SetupStepSchool({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return SetupCard(
      title: 'Where are you studying?',
      subtitle: 'This helps us personalize the profile you build next.',
      child: ThemedTextField(
        controller: controller,
        label: 'School',
        icon: Icons.school_outlined,
      ),
    );
  }
}
