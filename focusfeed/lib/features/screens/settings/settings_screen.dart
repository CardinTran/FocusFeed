import 'package:flutter/material.dart';
import 'package:focusfeed/features/auth/services/auth_service.dart';
import 'settings_modals.dart';
import 'settings_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final auth = AuthServices();
  String username = "Cardini Panini";
  String email = "Cardini@gmail.com";
  String passwordMasked = "••••••••";
  String school = "Louisiana State University";

  List<String> selectedCourses = ["Computer Science"];
  List<String> selectedSubjects = ["AI", "Technology"];

  bool notificationsEnabled = true;
  bool autoGenerateFlashcards = true;

  final List<String> availableCourses = [
    "Economics",
    "Calculus",
    "Statistics",
    "Psychology",
    "Accounting",
    "Computer Science",
    "Marketing",
    "Biology",
    "English",
  ];

  final List<String> availableSubjects = [
    "Finance",
    "Economics",
    "Technology",
    "AI",
    "Biology",
    "Chemistry",
    "Physics",
    "History",
    "Literature",
    "Psychology",
    "Business",
    "Math",
  ];

  static const Color _bg = Color(0xFF0B0F2A);
  static const Color _card = Color(0xFF151A3B);
  static const Color _accent = Color(0xFF6C63FF);
  static const Color _textPrimary = Colors.white;
  static const Color _textSecondary = Colors.white70;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: const Text('Settings', style: TextStyle(color: _textPrimary)),
        iconTheme: const IconThemeData(color: _textPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SettingsSectionTitle(title: "Account", textColor: _textPrimary),
          SettingsTile(
            icon: Icons.person_outline,
            title: "Username",
            subtitle: username,
            onTap: _openUsernameDialog,
            cardColor: _card,
            textPrimary: _textPrimary,
            textSecondary: _textSecondary,
          ),
          SettingsTile(
            icon: Icons.email_outlined,
            title: "Email",
            subtitle: email,
            onTap: _openEmailDialog,
            cardColor: _card,
            textPrimary: _textPrimary,
            textSecondary: _textSecondary,
          ),
          SettingsTile(
            icon: Icons.lock_outline,
            title: "Password",
            subtitle: "Change your password",
            onTap: _openPasswordDialog,
            cardColor: _card,
            textPrimary: _textPrimary,
            textSecondary: _textSecondary,
          ),
          SettingsTile(
            icon: Icons.logout,
            title: "Log Out",
            subtitle: "Sign out of your account",
            onTap: _handleLogoutTap,
            cardColor: _card,
            textPrimary: _textPrimary,
            textSecondary: _textSecondary,
          ),

          const SizedBox(height: 24),

          const SettingsSectionTitle(
            title: "Academic Preferences",
            textColor: _textPrimary,
          ),
          SettingsTile(
            icon: Icons.school_outlined,
            title: "School",
            subtitle: school,
            onTap: _openSchoolDialog,
            cardColor: _card,
            textPrimary: _textPrimary,
            textSecondary: _textSecondary,
          ),
          SettingsTile(
            icon: Icons.menu_book_outlined,
            title: "Courses",
            subtitle: selectedCourses.isEmpty
                ? "Choose your current courses"
                : selectedCourses.join(", "),
            onTap: _openCoursesSheet,
            cardColor: _card,
            textPrimary: _textPrimary,
            textSecondary: _textSecondary,
          ),
          SettingsTile(
            icon: Icons.interests_outlined,
            title: "Subjects of Interest",
            subtitle: selectedSubjects.isEmpty
                ? "Personalize your content feed"
                : selectedSubjects.join(", "),
            onTap: _openSubjectsSheet,
            cardColor: _card,
            textPrimary: _textPrimary,
            textSecondary: _textSecondary,
          ),

          const SizedBox(height: 24),

          const SettingsSectionTitle(
            title: "App Preferences",
            textColor: _textPrimary,
          ),
          SettingsSwitchTile(
            title: "Notifications",
            subtitle: "Enable reminders and updates",
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() {
                notificationsEnabled = value;
              });
              _showSnackBar(
                value ? "Notifications enabled" : "Notifications disabled",
              );
            },
            cardColor: _card,
            accentColor: _accent,
            textPrimary: _textPrimary,
            textSecondary: _textSecondary,
          ),
          const SizedBox(height: 12),
          SettingsSwitchTile(
            title: "Auto-generate flashcards",
            subtitle: "Create flashcards from imported study content",
            value: autoGenerateFlashcards,
            onChanged: (value) {
              setState(() {
                autoGenerateFlashcards = value;
              });
              _showSnackBar(
                value
                    ? "Auto-generate flashcards enabled"
                    : "Auto-generate flashcards disabled",
              );
            },
            cardColor: _card,
            accentColor: _accent,
            textPrimary: _textPrimary,
            textSecondary: _textSecondary,
          ),

          const SizedBox(height: 24),

          const SettingsSectionTitle(
            title: "Privacy & Support",
            textColor: _textPrimary,
          ),
          SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: "Privacy",
            subtitle: "View privacy settings",
            onTap: () {
              _showSimpleInfoSheet(
                title: "Privacy",
                message:
                    "Privacy in Progress. Actually you don't need any privacy! GIVE ME ALL YOUR MONEY AND INFORMATIONS.",
              );
            },
            cardColor: _card,
            textPrimary: _textPrimary,
            textSecondary: _textSecondary,
          ),
          SettingsTile(
            icon: Icons.bug_report_outlined,
            title: "Report a Bug",
            subtitle: "Help us improve the app",
            onTap: () {
              _showSimpleInfoSheet(
                title: "Report a Bug",
                message: "Bug Form in Progress. Actually maybe you're the bug!",
              );
            },
            cardColor: _card,
            textPrimary: _textPrimary,
            textSecondary: _textSecondary,
          ),
          SettingsTile(
            icon: Icons.info_outline,
            title: "About",
            subtitle: "App version and information",
            onTap: () {
              _showSimpleInfoSheet(
                title: "About",
                message:
                    "FocusFeed v1.0.0\nA personalized learning feed for students.",
              );
            },
            cardColor: _card,
            textPrimary: _textPrimary,
            textSecondary: _textSecondary,
          ),
        ],
      ),
    );
  }

  void _openUsernameDialog() {
    final controller = TextEditingController(text: username);

    showCenteredInputDialog(
      context: context,
      title: "Change Username",
      cardColor: _card,
      textPrimary: _textPrimary,
      child: Column(
        children: [
          _themedTextField(
            controller: controller,
            label: "Username",
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 20),
          _primaryButton(
            label: "Save",
            onPressed: () {
              if (controller.text.trim().isEmpty) return;

              setState(() {
                username = controller.text.trim();
              });

              Navigator.pop(context);
              _showSnackBar("Username updated");
            },
          ),
        ],
      ),
    );
  }

  void _openEmailDialog() {
    final controller = TextEditingController(text: email);

    showCenteredInputDialog(
      context: context,
      title: "Update Email",
      cardColor: _card,
      textPrimary: _textPrimary,
      child: Column(
        children: [
          _themedTextField(
            controller: controller,
            label: "Email",
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          _primaryButton(
            label: "Save",
            onPressed: () {
              final value = controller.text.trim();

              if (!value.contains("@")) {
                _showSnackBar("Invalid email");
                return;
              }

              setState(() {
                email = value;
              });

              Navigator.pop(context);
              _showSnackBar("Email updated");
            },
          ),
        ],
      ),
    );
  }

  void _openPasswordDialog() {
    final current = TextEditingController();
    final newPass = TextEditingController();
    final confirm = TextEditingController();

    showCenteredInputDialog(
      context: context,
      title: "Change Password",
      cardColor: _card,
      textPrimary: _textPrimary,
      child: Column(
        children: [
          _themedTextField(
            controller: current,
            label: "Current Password",
            icon: Icons.lock_outline,
            obscureText: true,
          ),
          const SizedBox(height: 12),
          _themedTextField(
            controller: newPass,
            label: "New Password",
            icon: Icons.lock_reset_outlined,
            obscureText: true,
          ),
          const SizedBox(height: 12),
          _themedTextField(
            controller: confirm,
            label: "Confirm Password",
            icon: Icons.verified_user_outlined,
            obscureText: true,
          ),
          const SizedBox(height: 20),
          _primaryButton(
            label: "Save",
            onPressed: () {
              if (newPass.text != confirm.text) {
                _showSnackBar("Passwords do not match");
                return;
              }

              Navigator.pop(context);
              _showSnackBar("Password updated");
            },
          ),
        ],
      ),
    );
  }

  void _openSchoolDialog() {
    final controller = TextEditingController(text: school);

    showCenteredInputDialog(
      context: context,
      title: "Set School",
      cardColor: _card,
      textPrimary: _textPrimary,
      child: Column(
        children: [
          _themedTextField(
            controller: controller,
            label: "School",
            icon: Icons.school_outlined,
          ),
          const SizedBox(height: 20),
          _primaryButton(
            label: "Save",
            onPressed: () {
              setState(() {
                school = controller.text.trim();
              });

              Navigator.pop(context);
              _showSnackBar("School updated");
            },
          ),
        ],
      ),
    );
  }

  void _openCoursesSheet() {
    List<String> tempSelected = List.from(selectedCourses);

    showThemedBottomSheet(
      context: context,
      title: "Choose Courses",
      backgroundColor: _bg,
      textPrimary: _textPrimary,
      child: StatefulBuilder(
        builder: (context, setModalState) {
          return Column(
            children: [
              ...availableCourses.map((course) {
                final isSelected = tempSelected.contains(course);

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? _accent : Colors.white10,
                      width: 1.2,
                    ),
                  ),
                  child: CheckboxListTile(
                    value: isSelected,
                    onChanged: (value) {
                      setModalState(() {
                        if (value == true) {
                          tempSelected.add(course);
                        } else {
                          tempSelected.remove(course);
                        }
                      });
                    },
                    title: Text(
                      course,
                      style: const TextStyle(color: _textPrimary),
                    ),
                    activeColor: _accent,
                    checkColor: Colors.white,
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                );
              }),
              const SizedBox(height: 16),
              _primaryButton(
                label: "Save Courses",
                onPressed: () {
                  setState(() {
                    selectedCourses = tempSelected;
                  });

                  Navigator.pop(context);
                  _showSnackBar("Courses updated");
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _openSubjectsSheet() {
    List<String> tempSelected = List.from(selectedSubjects);

    showThemedBottomSheet(
      context: context,
      title: "Subjects of Interest",
      backgroundColor: _bg,
      textPrimary: _textPrimary,
      child: StatefulBuilder(
        builder: (context, setModalState) {
          return Column(
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: availableSubjects.map((subject) {
                  final isSelected = tempSelected.contains(subject);

                  return ChoiceChip(
                    label: Text(subject),
                    selected: isSelected,
                    onSelected: (selected) {
                      setModalState(() {
                        if (selected) {
                          tempSelected.add(subject);
                        } else {
                          tempSelected.remove(subject);
                        }
                      });
                    },
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                    selectedColor: _accent,
                    backgroundColor: _card,
                    side: BorderSide(
                      color: isSelected ? _accent : Colors.white10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              _primaryButton(
                label: "Save Subjects",
                onPressed: () {
                  setState(() {
                    selectedSubjects = tempSelected;
                  });

                  Navigator.pop(context);
                  _showSnackBar("Subjects updated");
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSimpleInfoSheet({required String title, required String message}) {
    showThemedBottomSheet(
      context: context,
      title: title,
      backgroundColor: _bg,
      textPrimary: _textPrimary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: const TextStyle(
              color: _textSecondary,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          _primaryButton(
            label: "Close",
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _handleLogoutTap() {
    showLogoutDialog(
      context: context,
      cardColor: _card,
      accentColor: _accent,
      textPrimary: _textPrimary,
      textSecondary: _textSecondary,
      onLogout: () {
        auth
            .signOut()
            .then((_) {
              if (!mounted) return;
              _showSnackBar("Logged out");
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/auth-gate',
                (route) => false,
              );
            })
            .catchError((_) {
              if (!mounted) return;
              _showSnackBar("Could not log out. Please try again.");
            });
      },
    );
  }

  Widget _themedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: _textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _textSecondary),
        prefixIcon: Icon(icon, color: _textSecondary),
        filled: true,
        fillColor: _card,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _accent, width: 1.4),
        ),
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _card,
        content: Text(message, style: const TextStyle(color: _textPrimary)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
