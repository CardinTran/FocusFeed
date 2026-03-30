import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focusfeed/features/auth/screens/app_entry_screen.dart';
import 'package:focusfeed/features/auth/services/auth_service.dart';
import 'package:focusfeed/features/screens/profile/services/profile_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  static const Color _bg = Color(0xFF0B0F2A);
  static const Color _card = Color(0xFF151A3B);
  static const Color _accent = Color.fromRGBO(133, 90, 251, 1);
  static const Color _textPrimary = Colors.white;
  static const Color _textSecondary = Colors.white70;

  final _pageController = PageController();
  final _schoolController = TextEditingController();
  final _authService = AuthServices();
  final _profileService = ProfileService();

  final List<String> _availableCourses = const [
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

  final List<String> _availableSubjects = const [
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

  final List<String> _selectedCourses = [];
  final List<String> _selectedSubjects = [];

  int _currentPage = 0;
  bool _notificationsEnabled = true;
  bool _autoGenerateFlashcards = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _pageController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

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

  Future<void> _saveSetup() async {
    if (_isSaving) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _profileService.saveSetup(
        school: _schoolController.text,
        selectedCourses: _selectedCourses,
        selectedSubjects: _selectedSubjects,
        notificationsEnabled: _notificationsEnabled,
        autoGenerateFlashcards: _autoGenerateFlashcards,
      );

      if (!mounted) {
        return;
      }

      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        _showMessage(
          'Firestore blocked the save. Publish rules that allow users to write their own profile.',
        );
      } else {
        _showMessage('Save failed: ${e.code}');
      }
    } catch (e) {
      _showMessage('Could not save your setup. ${e.runtimeType}');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _logout() async {
    if (_isSaving) {
      return;
    }

    try {
      await _authService.signOut();
      if (!mounted) {
        return;
      }
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AppEntryScreen()),
        (_) => false,
      );
    } catch (_) {
      _showMessage('Could not sign out right now.');
    }
  }

  void _toggleSelection(List<String> selections, String value) {
    setState(() {
      if (selections.contains(value)) {
        selections.remove(value);
      } else {
        selections.add(value);
      }
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final rawDisplayName = user?.displayName?.trim();
    final displayName = rawDisplayName != null && rawDisplayName.isNotEmpty
        ? rawDisplayName
        : 'there';

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _logout,
                  icon: const Icon(
                    Icons.logout,
                    color: _textSecondary,
                    size: 18,
                  ),
                  label: const Text(
                    'Log Out',
                    style: TextStyle(
                      color: _textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Text(
                'Welcome, $displayName',
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Set up your study feed in a few quick steps.',
                style: TextStyle(color: _textSecondary, fontSize: 15),
              ),
              const SizedBox(height: 20),
              Row(
                children: List.generate(
                  3,
                  (index) => Expanded(
                    child: Container(
                      height: 6,
                      margin: EdgeInsets.only(right: index == 2 ? 0 : 8),
                      decoration: BoxDecoration(
                        color: index <= _currentPage ? _accent : Colors.white12,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (value) =>
                      setState(() => _currentPage = value),
                  children: [
                    _SetupCard(
                      title: 'Where are you studying?',
                      subtitle:
                          'This helps us personalize the profile you build next.',
                      child: _ThemedTextField(
                        controller: _schoolController,
                        label: 'School',
                        icon: Icons.school_outlined,
                      ),
                    ),
                    _SetupCard(
                      title: 'Pick your courses',
                      subtitle:
                          'Choose the classes you want FocusFeed to prioritize.',
                      child: _ChoiceWrap(
                        options: _availableCourses,
                        selections: _selectedCourses,
                        onTap: (value) =>
                            _toggleSelection(_selectedCourses, value),
                      ),
                    ),
                    _SetupCard(
                      title: 'Finish your preferences',
                      subtitle: 'Select topics and a couple of app defaults.',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ChoiceWrap(
                            options: _availableSubjects,
                            selections: _selectedSubjects,
                            onTap: (value) =>
                                _toggleSelection(_selectedSubjects, value),
                          ),
                          const SizedBox(height: 18),
                          _PreferenceSwitch(
                            title: 'Notifications',
                            subtitle: 'Enable reminders and updates',
                            value: _notificationsEnabled,
                            onChanged: (value) =>
                                setState(() => _notificationsEnabled = value),
                          ),
                          const SizedBox(height: 12),
                          _PreferenceSwitch(
                            title: 'Auto-generate flashcards',
                            subtitle:
                                'Create flashcards from imported study content',
                            value: _autoGenerateFlashcards,
                            onChanged: (value) =>
                                setState(() => _autoGenerateFlashcards = value),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  if (_currentPage > 0)
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
                            : () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeOut,
                                );
                              },
                        child: const Text(
                          'Back',
                          style: TextStyle(color: _textPrimary),
                        ),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
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

class _SetupCard extends StatelessWidget {
  const _SetupCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _ProfileSetupScreenState._card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _ProfileSetupScreenState._textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: _ProfileSetupScreenState._textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(child: SingleChildScrollView(child: child)),
        ],
      ),
    );
  }
}

class _ThemedTextField extends StatelessWidget {
  const _ThemedTextField({
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
      style: const TextStyle(color: _ProfileSetupScreenState._textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: _ProfileSetupScreenState._textSecondary,
        ),
        prefixIcon: Icon(icon, color: _ProfileSetupScreenState._textSecondary),
        filled: true,
        fillColor: const Color(0xFF0F1433),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: _ProfileSetupScreenState._accent,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

class _ChoiceWrap extends StatelessWidget {
  const _ChoiceWrap({
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
          onSelected: (_) => onTap(option),
          selectedColor: _ProfileSetupScreenState._accent,
          backgroundColor: const Color(0xFF0F1433),
          side: BorderSide(
            color: isSelected
                ? _ProfileSetupScreenState._accent
                : Colors.white10,
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

class _PreferenceSwitch extends StatelessWidget {
  const _PreferenceSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1433),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _ProfileSetupScreenState._textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _ProfileSetupScreenState._textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: _ProfileSetupScreenState._accent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
