import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focusfeed/features/auth/services/auth_service.dart';
import 'package:focusfeed/features/profile/services/profile_service.dart';
import 'settings_modals.dart';
import 'settings_widgets.dart';

/// Settings screen — displays and edits the current user's account details,
/// academic preferences, and app preferences.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _profileService = ProfileService();
  final _auth = AuthServices();

  /// True while the initial Firestore read is in flight. Shows a spinner
  /// instead of the ListView so stale placeholder values are never visible.
  bool _isLoading = true;

  // Account fields
  String username = "";
  String email = "";
  String school = "";

  // Academic preference fields
  List<String> selectedCourses = [];
  List<String> selectedSubjects = [];

  // App preference fields
  bool notificationsEnabled = true;
  bool autoGenerateFlashcards = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  /// Reads the user's Firestore document and populates local state.
  ///
  /// Falls back to [FirebaseAuth.currentUser] fields if the Firestore doc is
  /// missing a value (e.g. the user signed in via Google before completing
  /// profile setup). On any error, clears [_isLoading] so the screen still
  /// renders rather than spinning forever.
  Future<void> _loadProfile() async {
    try {
      final data = await _profileService.getProfile();
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (!mounted) return;
      setState(() {
        username = data?['displayName'] as String? ??
            firebaseUser?.displayName ??
            '';
        email = data?['email'] as String? ?? firebaseUser?.email ?? '';
        school = data?['school'] as String? ?? '';
        selectedCourses =
            List<String>.from(data?['selectedCourses'] as List? ?? []);
        selectedSubjects =
            List<String>.from(data?['selectedSubjects'] as List? ?? []);
        notificationsEnabled =
            data?['notificationsEnabled'] as bool? ?? true;
        autoGenerateFlashcards =
            data?['autoGenerateFlashcards'] as bool? ?? true;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
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
            // Update local state immediately for instant feedback, then
            // persist to Firestore without awaiting — a failed write here
            // is not worth blocking the toggle animation for.
            onChanged: (value) {
              setState(() => notificationsEnabled = value);
              _profileService.updateProfile({'notificationsEnabled': value});
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
            // Same fire-and-forget pattern as the notifications toggle above.
            onChanged: (value) {
              setState(() => autoGenerateFlashcards = value);
              _profileService.updateProfile({'autoGenerateFlashcards': value});
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

  // Dialog

  /// Updates the display name in both Firebase Auth and Firestore so both
  /// sources stay in sync. Firebase Auth is the source of truth for the
  /// logged-in user object; Firestore is queried by other features.
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
            onPressed: () async {
              final value = controller.text.trim();
              if (value.isEmpty) return;

              try {
                await FirebaseAuth.instance.currentUser
                    ?.updateDisplayName(value);
                await _profileService.updateProfile({'displayName': value});
                if (!mounted) return;
                setState(() => username = value);
                Navigator.pop(context);
                _showSnackBar("Username updated");
              } catch (_) {
                _showSnackBar("Failed to update username");
              }
            },
          ),
        ],
      ),
    );
  }

  /// Sends a verification email to the new address via [verifyBeforeUpdateEmail].
  /// Firebase Auth only swaps the email after the user clicks the link, so the
  /// Auth object still holds the old email until then. Firestore is updated
  /// optimistically so the UI reflects the intended new value immediately.
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
            onPressed: () async {
              final value = controller.text.trim();
              if (!value.contains("@")) {
                _showSnackBar("Invalid email");
                return;
              }

              try {
                await FirebaseAuth.instance.currentUser
                    ?.verifyBeforeUpdateEmail(value);
                await _profileService.updateProfile({'email': value});
                if (!mounted) return;
                setState(() => email = value);
                Navigator.pop(context);
                _showSnackBar(
                    "Verification email sent. Email updates after confirmation.");
              } on FirebaseAuthException catch (e) {
                _showSnackBar(e.code == 'requires-recent-login'
                    ? 'Please log out and log back in before changing your email.'
                    : 'Failed to update email: ${e.message}');
              } catch (_) {
                _showSnackBar("Failed to update email");
              }
            },
          ),
        ],
      ),
    );
  }

  /// Re-authenticates the user with their current password before calling
  /// [updatePassword]. Firebase requires re-authentication for sensitive
  /// operations when the session was established too long ago.
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
            onPressed: () async {
              if (newPass.text != confirm.text) {
                _showSnackBar("Passwords do not match");
                return;
              }
              if (newPass.text.length < 6) {
                _showSnackBar("Password must be at least 6 characters");
                return;
              }

              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user?.email != null) {
                  final cred = EmailAuthProvider.credential(
                    email: user!.email!,
                    password: current.text,
                  );
                  await user.reauthenticateWithCredential(cred);
                }
                await FirebaseAuth.instance.currentUser
                    ?.updatePassword(newPass.text);
                if (!mounted) return;
                Navigator.pop(context);
                _showSnackBar("Password updated");
              } on FirebaseAuthException catch (e) {
                _showSnackBar(e.code == 'wrong-password'
                    ? 'Current password is incorrect.'
                    : 'Failed to update password: ${e.message}');
              } catch (_) {
                _showSnackBar("Failed to update password");
              }
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
            onPressed: () async {
              final value = controller.text.trim();
              try {
                await _profileService.updateProfile({'school': value});
                if (!mounted) return;
                setState(() => school = value);
                Navigator.pop(context);
                _showSnackBar("School updated");
              } catch (_) {
                _showSnackBar("Failed to update school");
              }
            },
          ),
        ],
      ),
    );
  }

  /// Uses a local [tempSelected] copy so the modal can show checkbox state
  /// without touching [selectedCourses] until the user explicitly saves.
  /// [Navigator.of(context)] is captured before the await to avoid using a
  /// potentially stale BuildContext after the async gap.
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
                onPressed: () async {
                  final nav = Navigator.of(context);
                  try {
                    await _profileService
                        .updateProfile({'selectedCourses': tempSelected});
                    if (!mounted) return;
                    setState(() => selectedCourses = tempSelected);
                    nav.pop();
                    _showSnackBar("Courses updated");
                  } catch (_) {
                    _showSnackBar("Failed to update courses");
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  /// Same temp-copy + save pattern as [_openCoursesSheet], using [ChoiceChip]
  /// instead of checkboxes for a tag-style selection UI.
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
                onPressed: () async {
                  final nav = Navigator.of(context);
                  try {
                    await _profileService
                        .updateProfile({'selectedSubjects': tempSelected});
                    if (!mounted) return;
                    setState(() => selectedSubjects = tempSelected);
                    nav.pop();
                    _showSnackBar("Subjects updated");
                  } catch (_) {
                    _showSnackBar("Failed to update subjects");
                  }
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
      onLogout: () async {
        try {
          await _auth.signOut();
        } catch (_) {
          if (!mounted) return;
          _showSnackBar("Unable to log out. Please try again.");
        }
      },
    );
  }

  // ── Shared UI helpers ────────────────────────────────────────────────────────

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
