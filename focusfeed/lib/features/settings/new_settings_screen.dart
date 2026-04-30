import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focusfeed/core/theme/app_colors.dart';
import 'package:focusfeed/features/auth/services/auth_service.dart';
import 'package:focusfeed/features/profile/services/profile_service.dart';
import 'package:focusfeed/features/profile/widgets/choice_wrap.dart';
import 'package:focusfeed/features/profile/widgets/setup_step_courses.dart';
import 'package:focusfeed/features/profile/widgets/setup_step_preferences.dart';
import 'package:focusfeed/features/settings/screens/privacy_screen.dart';
import 'package:focusfeed/features/settings/screens/security_screen.dart';
import 'package:focusfeed/features/settings/widgets/settings_card.dart';
import 'package:focusfeed/features/settings/widgets/settings_row.dart';
import 'package:focusfeed/features/settings/widgets/settings_section_title.dart';
import 'package:focusfeed/features/settings/widgets/settings_toggle.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _profileService = ProfileService();
  final _authService = AuthServices();

  bool _isLoading = true;
  String _username = '';
  String _email = '';
  String _school = '';
  List<String> _selectedCourses = [];
  List<String> _selectedSubjects = [];
  bool _darkMode = true;
  bool _notificationsEnabled = true;
  bool _autoGenerateFlashcards = true;
  bool _twoFactorEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await _profileService.getProfile();
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (!mounted) return;
      setState(() {
        _username = data?['displayName'] as String? ?? firebaseUser?.displayName ?? '';
        _email = firebaseUser?.email ?? data?['email'] as String? ?? '';
        _school = data?['school'] as String? ?? '';
        _selectedCourses = List<String>.from(data?['selectedCourses'] as List? ?? []);
        _selectedSubjects = List<String>.from(data?['selectedSubjects'] as List? ?? []);
        _notificationsEnabled = data?['notificationsEnabled'] as bool? ?? true;
        _autoGenerateFlashcards = data?['autoGenerateFlashcards'] as bool? ?? true;
        _twoFactorEnabled = data?['twoFactorEnabled'] as bool? ?? false;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _persistToggle(String key, bool value) {
    _profileService.updateProfile({key: value});
  }

  void _handleLogOut() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Log Out', style: TextStyle(color: AppColors.white)),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: AppColors.grayDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grayDark)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.redCoral,
              foregroundColor: AppColors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _authService.signOut();
                if (!mounted) return;
                Navigator.pushNamedAndRemoveUntil(context, '/auth-gate', (_) => false);
              } catch (_) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Unable to log out. Please try again.')),
                );
              }
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _openSchoolDialog() {
    final controller = TextEditingController(text: _school);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('School', style: TextStyle(color: AppColors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.white),
          decoration: InputDecoration(
            hintText: 'e.g. LSU',
            hintStyle: const TextStyle(color: AppColors.grayDark),
            filled: true,
            fillColor: AppColors.dark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grayDark)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              foregroundColor: AppColors.white,
            ),
            onPressed: () async {
              final value = controller.text.trim();
              Navigator.pop(ctx);
              await _profileService.updateProfile({'school': value});
              if (!mounted) return;
              setState(() => _school = value);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _openCoursesSheet() {
    List<String> temp = List.from(_selectedCourses);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Courses',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.white)),
                const SizedBox(height: 4),
                const Text('Choose the classes you want FocusFeed to prioritize.',
                    style: TextStyle(fontSize: 13, color: AppColors.grayDark)),
                const SizedBox(height: 16),
                ChoiceWrap(
                  options: SetupStepCourses.availableCourses,
                  selections: temp,
                  onTap: (v) => setSheet(() => temp.contains(v) ? temp.remove(v) : temp.add(v)),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await _profileService.updateProfile({'selectedCourses': temp});
                      if (!mounted) return;
                      setState(() => _selectedCourses = temp);
                    },
                    child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openSubjectsSheet() {
    List<String> temp = List.from(_selectedSubjects);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Subjects of Interest',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.white)),
                const SizedBox(height: 4),
                const Text('Topics that will shape your content feed.',
                    style: TextStyle(fontSize: 13, color: AppColors.grayDark)),
                const SizedBox(height: 16),
                ChoiceWrap(
                  options: SetupStepPreferences.availableSubjects,
                  selections: temp,
                  onTap: (v) => setSheet(() => temp.contains(v) ? temp.remove(v) : temp.add(v)),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await _profileService.updateProfile({'selectedSubjects': temp});
                      if (!mounted) return;
                      setState(() => _selectedSubjects = temp);
                    },
                    child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final initial = _username.isNotEmpty ? _username[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.purple.withValues(alpha: 0.2),
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.purpleLight,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _username.isEmpty ? 'User' : _username,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _email,
                  style: const TextStyle(fontSize: 12, color: AppColors.grayDark),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: (_twoFactorEnabled ? AppColors.green : AppColors.redCoral).withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              _twoFactorEnabled ? 'Verified' : 'Unverified',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _twoFactorEnabled ? AppColors.green : AppColors.redCoral,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.white,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.purple))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              children: [
                _buildProfileHeader(),

                const SettingsSectionTitle('ACCOUNT'),
                SettingsCard(
                  children: [
                    SettingsRow(
                      icon: Icons.person_outline,
                      iconColor: AppColors.purple,
                      label: 'Edit Profile',
                      sublabel: 'Name, school, courses',
                      onTap: () {},
                    ),
                    SettingsRow(
                      icon: Icons.email_outlined,
                      iconColor: AppColors.purple,
                      label: 'Email Address',
                      sublabel: _email.isEmpty ? 'No email set' : _email,
                      onTap: () {},
                    ),
                    SettingsRow(
                      icon: Icons.key_outlined,
                      iconColor: AppColors.purple,
                      label: 'Change Password',
                      sublabel: 'Update your password',
                      onTap: () {},
                      isLast: true,
                    ),
                  ],
                ),

                const SettingsSectionTitle('ACADEMIC PREFERENCES'),
                SettingsCard(
                  children: [
                    SettingsRow(
                      icon: Icons.school_outlined,
                      iconColor: AppColors.purpleLight,
                      label: 'School',
                      sublabel: _school.isEmpty ? 'Add your school' : _school,
                      onTap: _openSchoolDialog,
                    ),
                    SettingsRow(
                      icon: Icons.menu_book_outlined,
                      iconColor: AppColors.purpleLight,
                      label: 'Courses',
                      sublabel: _selectedCourses.isEmpty
                          ? 'Choose your current courses'
                          : _selectedCourses.join(', '),
                      onTap: _openCoursesSheet,
                    ),
                    SettingsRow(
                      icon: Icons.interests_outlined,
                      iconColor: AppColors.purpleLight,
                      label: 'Subjects of Interest',
                      sublabel: _selectedSubjects.isEmpty
                          ? 'Personalize your content feed'
                          : _selectedSubjects.join(', '),
                      onTap: _openSubjectsSheet,
                      isLast: true,
                    ),
                  ],
                ),

                const SettingsSectionTitle('SECURITY'),
                SettingsCard(
                  children: [
                    SettingsRow(
                      icon: Icons.shield_outlined,
                      iconColor: AppColors.green,
                      label: 'Security & Login',
                      sublabel: '2FA, biometrics, sessions',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SecurityScreen()),
                      ).then((_) => _loadProfile()),
                    ),
                    SettingsRow(
                      icon: Icons.visibility_outlined,
                      iconColor: AppColors.green,
                      label: 'Privacy',
                      sublabel: 'Data sharing, visibility',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PrivacyScreen()),
                      ),
                      isLast: true,
                    ),
                  ],
                ),

                const SettingsSectionTitle('PREFERENCES'),
                SettingsCard(
                  children: [
                    SettingsRow(
                      icon: Icons.dark_mode_outlined,
                      iconColor: AppColors.purpleLight,
                      label: 'Dark Mode',
                      trailing: SettingsToggle(
                        value: _darkMode,
                        onChanged: (v) => setState(() => _darkMode = v),
                      ),
                    ),
                    SettingsRow(
                      icon: Icons.notifications_outlined,
                      iconColor: AppColors.gold,
                      label: 'Study Reminders',
                      sublabel: _notificationsEnabled ? 'Daily at 8:00 PM' : 'Reminders off',
                      trailing: SettingsToggle(
                        value: _notificationsEnabled,
                        onChanged: (v) {
                          setState(() => _notificationsEnabled = v);
                          _persistToggle('notificationsEnabled', v);
                        },
                        color: AppColors.gold,
                      ),
                    ),
                    SettingsRow(
                      icon: Icons.auto_awesome_outlined,
                      iconColor: AppColors.purpleLight,
                      label: 'Auto-generate Flashcards',
                      sublabel: 'Create cards from imported content',
                      trailing: SettingsToggle(
                        value: _autoGenerateFlashcards,
                        onChanged: (v) {
                          setState(() => _autoGenerateFlashcards = v);
                          _persistToggle('autoGenerateFlashcards', v);
                        },
                      ),
                    ),
                    SettingsRow(
                      icon: Icons.timer_outlined,
                      iconColor: AppColors.purpleLight,
                      label: 'Session Length',
                      sublabel: '20 cards per session',
                      onTap: () {},
                    ),
                    SettingsRow(
                      icon: Icons.language_outlined,
                      iconColor: AppColors.purpleLight,
                      label: 'Language',
                      sublabel: 'English',
                      onTap: () {},
                      isLast: true,
                    ),
                  ],
                ),

                const SettingsSectionTitle('DATA & STORAGE'),
                SettingsCard(
                  children: [
                    SettingsRow(
                      icon: Icons.download_outlined,
                      iconColor: AppColors.gray,
                      label: 'Export My Data',
                      sublabel: 'Download all decks and cards',
                      onTap: () {},
                    ),
                    SettingsRow(
                      icon: Icons.delete_outline,
                      iconColor: AppColors.redCoral,
                      label: 'Clear Local Cache',
                      sublabel: 'Free up storage space',
                      onTap: () {},
                      isLast: true,
                    ),
                  ],
                ),

                const SettingsSectionTitle('SUPPORT'),
                SettingsCard(
                  children: [
                    SettingsRow(
                      icon: Icons.help_outline,
                      iconColor: AppColors.gray,
                      label: 'Help Center',
                      onTap: () {},
                    ),
                    SettingsRow(
                      icon: Icons.info_outline,
                      iconColor: AppColors.gray,
                      label: 'About FocusFeed',
                      sublabel: 'Version 1.0.0',
                      onTap: () {},
                      isLast: true,
                    ),
                  ],
                ),

                const SettingsSectionTitle('DANGER ZONE'),
                SettingsCard(
                  children: [
                    SettingsRow(
                      icon: Icons.logout,
                      iconColor: AppColors.redCoral,
                      label: 'Log Out',
                      isDanger: true,
                      onTap: _handleLogOut,
                    ),
                    SettingsRow(
                      icon: Icons.warning_amber_outlined,
                      iconColor: AppColors.redCoral,
                      label: 'Delete Account',
                      sublabel: 'Permanently remove all data',
                      isDanger: true,
                      onTap: () {},
                      isLast: true,
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
    );
  }
}
