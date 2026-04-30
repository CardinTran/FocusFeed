import 'package:flutter/material.dart';
import 'package:focusfeed/core/theme/app_colors.dart';
import 'package:focusfeed/features/profile/services/profile_service.dart';
import 'package:focusfeed/features/settings/screens/sessions_screen.dart';
import 'package:focusfeed/features/settings/widgets/settings_card.dart';
import 'package:focusfeed/features/settings/widgets/settings_row.dart';
import 'package:focusfeed/features/settings/widgets/settings_section_title.dart';
import 'package:focusfeed/features/settings/widgets/settings_toggle.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _profileService = ProfileService();

  bool biometric = true;
  bool twoFactor = false;
  bool autoLock = true;
  bool loginAlerts = true;

  @override
  void initState() {
    super.initState();
    _loadTwoFactor();
  }

  Future<void> _loadTwoFactor() async {
    final data = await _profileService.getProfile();
    if (!mounted) return;
    setState(() {
      twoFactor = data?['twoFactorEnabled'] as bool? ?? false;
    });
  }

  int get _enabledCount => [biometric, twoFactor, autoLock, loginAlerts].where((b) => b).length;

  String get _grade {
    if (_enabledCount == 4) return 'A+';
    if (_enabledCount >= 3) return 'A';
    if (_enabledCount >= 2) return 'B';
    return 'C';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.purple, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Security',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.green.withValues(alpha: 0.08),
              border: Border.all(color: AppColors.green.withValues(alpha: 0.15)),
            ),
            child: Column(
              children: [
                Text(
                  _grade,
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: AppColors.green),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Security Score',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.green),
                ),
                const SizedBox(height: 6),
                Text(
                  '$_enabledCount/4 protections enabled',
                  style: TextStyle(fontSize: 11, color: AppColors.grayDark),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: _enabledCount / 4,
                    minHeight: 4,
                    backgroundColor: AppColors.grayDark.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation(AppColors.green),
                  ),
                ),
              ],
            ),
          ),

          const SettingsSectionTitle('AUTHENTICATION'),
          SettingsCard(
            children: [
              SettingsRow(
                icon: Icons.fingerprint,
                iconColor: AppColors.green,
                label: 'Biometric Login',
                sublabel: 'Face ID / fingerprint unlock',
                trailing: SettingsToggle(
                  value: biometric,
                  onChanged: (v) => setState(() => biometric = v),
                  color: AppColors.green,
                ),
              ),
              SettingsRow(
                icon: Icons.shield_outlined,
                iconColor: AppColors.green,
                label: 'Two-Factor Authentication',
                sublabel: twoFactor ? 'Enabled via authenticator app' : 'Add extra login protection',
                trailing: SettingsToggle(
                  value: twoFactor,
                  onChanged: (v) {
                    setState(() => twoFactor = v);
                    _profileService.updateProfile({'twoFactorEnabled': v});
                  },
                  color: AppColors.green,
                ),
              ),
              SettingsRow(
                icon: Icons.lock_outline,
                iconColor: AppColors.green,
                label: 'Auto-Lock App',
                sublabel: 'Lock after 5 minutes inactive',
                trailing: SettingsToggle(
                  value: autoLock,
                  onChanged: (v) => setState(() => autoLock = v),
                  color: AppColors.green,
                ),
                isLast: true,
              ),
            ],
          ),

          const SettingsSectionTitle('MONITORING'),
          SettingsCard(
            children: [
              SettingsRow(
                icon: Icons.notifications_outlined,
                iconColor: AppColors.gold,
                label: 'Login Alerts',
                sublabel: 'Get notified of new sign-ins',
                trailing: SettingsToggle(
                  value: loginAlerts,
                  onChanged: (v) => setState(() => loginAlerts = v),
                  color: AppColors.gold,
                ),
              ),
              SettingsRow(
                icon: Icons.smartphone_outlined,
                iconColor: AppColors.gold,
                label: 'Active Sessions',
                sublabel: '2 devices currently signed in',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SessionsScreen()),
                ),
                isLast: true,
              ),
            ],
          ),

          const SettingsSectionTitle('PASSWORD'),
          SettingsCard(
            children: [
              SettingsRow(
                icon: Icons.key_outlined,
                iconColor: AppColors.purple,
                label: 'Change Password',
                sublabel: 'Last changed 14 days ago',
                onTap: () {},
              ),
              SettingsRow(
                icon: Icons.timer_outlined,
                iconColor: AppColors.purple,
                label: 'Password Expiry',
                sublabel: 'Remind every 90 days',
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
