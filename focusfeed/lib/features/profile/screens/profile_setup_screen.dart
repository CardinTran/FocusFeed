import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focusfeed/core/theme/app_colors.dart';
import 'package:focusfeed/features/auth/screens/app_entry_screen.dart';
import 'package:focusfeed/features/auth/services/auth_service.dart';
import 'package:focusfeed/features/profile/services/profile_service.dart';
import 'package:focusfeed/features/profile/widgets/setup_step_school.dart';
import 'package:focusfeed/features/profile/widgets/setup_step_courses.dart';
import 'package:focusfeed/features/profile/widgets/setup_step_preferences.dart';

/// 3-step onboarding wizard shown to new users after their first login.
/// Collects school, courses, subjects, and app preferences, then saves
/// them to Firestore and navigates to the main app.
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  // Controllers
  final _pageController = PageController();
  final _schoolController = TextEditingController();

  // Services
  final _authService = AuthServices();
  final _profileService = ProfileService();

  // Wizard state
  final List<String> _selectedCourses = [];
  final List<String> _selectedSubjects = [];
  int _currentPage = 0;
  bool _notificationsEnabled = true;
  bool _autoGenerateFlashcards = true;

  // True while the Firestore save is in flight — disables buttons and
  // shows a spinner to prevent double-submission.
  bool _isSaving = false;

  @override
  void dispose() {
    _pageController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  /// Validates the current page then moves forward, or triggers save on
  /// the last page.
  void _nextPage() {
    if (_currentPage == 0 && _schoolController.text.trim().isEmpty) {
      _showMessage('Add your school to continue.');
      return;
    }

    if (_currentPage >= 2) {
      _saveSetup();
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  // ── Async operations ────────────────────────────────────────────────────────

  /// Saves all setup data to Firestore then navigates to the main app.
  /// Clears _isSaving in a finally block so the spinner always goes away.
  Future<void> _saveSetup() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      await _profileService.saveSetup(
        school: _schoolController.text,
        selectedCourses: _selectedCourses,
        selectedSubjects: _selectedSubjects,
        notificationsEnabled: _notificationsEnabled,
        autoGenerateFlashcards: _autoGenerateFlashcards,
      );

      if (!mounted) return;

      // Remove all routes so the user can't press Back into the wizard.
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } on FirebaseException catch (e) {
      _showMessage(e.code == 'permission-denied'
          ? 'Firestore blocked the save. Check your security rules.'
          : 'Save failed: ${e.code}');
    } catch (e) {
      _showMessage('Could not save your setup. ${e.runtimeType}');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Signs the user out and returns them to AppEntryScreen.
  /// Blocked while a save is in progress.
  Future<void> _logout() async {
    if (_isSaving) return;
    try {
      await _authService.signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AppEntryScreen()),
        (_) => false,
      );
    } catch (_) {
      _showMessage('Could not sign out right now.');
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  /// Adds [value] to [selections] if absent, removes it if present.
  void _toggleSelection(List<String> selections, String value) {
    setState(() {
      selections.contains(value)
          ? selections.remove(value)
          : selections.add(value);
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final rawName = FirebaseAuth.instance.currentUser?.displayName?.trim();
    final displayName = (rawName?.isNotEmpty ?? false) ? rawName! : 'there';

    return Scaffold(
      backgroundColor: AppColors.setupBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Log out button — top right
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout, color: Colors.white70, size: 18),
                  label: const Text(
                    'Log Out',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // Greeting
              Text(
                'Welcome, $displayName',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Set up your study feed in a few quick steps.',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 20),

              // Step progress bar — filled segments show completed/current steps
              Row(
                children: List.generate(3, (index) {
                  return Expanded(
                    child: Container(
                      height: 6,
                      margin: EdgeInsets.only(right: index == 2 ? 0 : 8),
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? AppColors.purpleBright
                            : Colors.white12,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Page content — swipe disabled so buttons enforce validation
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (value) =>
                      setState(() => _currentPage = value),
                  children: [
                    SetupStepSchool(controller: _schoolController),
                    SetupStepCourses(
                      selectedCourses: _selectedCourses,
                      onTap: (v) => _toggleSelection(_selectedCourses, v),
                    ),
                    SetupStepPreferences(
                      selectedSubjects: _selectedSubjects,
                      onSubjectTap: (v) =>
                          _toggleSelection(_selectedSubjects, v),
                      notificationsEnabled: _notificationsEnabled,
                      onNotificationsChanged: (v) =>
                          setState(() => _notificationsEnabled = v),
                      autoGenerateFlashcards: _autoGenerateFlashcards,
                      onAutoGenerateChanged: (v) =>
                          setState(() => _autoGenerateFlashcards = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Navigation buttons
              Row(
                children: [
                  // Back button — hidden on the first page
                  if (_currentPage > 0) ...[
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white24),
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _isSaving
                            ? null
                            : () => _pageController.previousPage(
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeOut,
                                ),
                        child: const Text(
                          'Back',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],

                  // Continue / Finish Setup button
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.purpleBright,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _isSaving ? null : _nextPage,
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _currentPage == 2 ? 'Finish Setup' : 'Continue',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
