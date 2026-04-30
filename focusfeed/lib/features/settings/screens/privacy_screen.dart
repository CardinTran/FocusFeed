import 'package:flutter/material.dart';
import 'package:focusfeed/core/theme/app_colors.dart';
import 'package:focusfeed/features/settings/widgets/settings_card.dart';
import 'package:focusfeed/features/settings/widgets/settings_row.dart';
import 'package:focusfeed/features/settings/widgets/settings_section_title.dart';
import 'package:focusfeed/features/settings/widgets/settings_toggle.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool onlineStatus = false;
  bool analytics = false;
  bool crashReports = true;

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
          'Privacy',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.cardBackground,
              border: Border.all(color: AppColors.grayDark.withValues(alpha: 0.1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 12, top: 2),
                  child: const Icon(Icons.shield_outlined, size: 18, color: AppColors.purple),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Data is Yours',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'FocusFeed stores your study data only in your Firebase account. We never sell data or share it with third parties. You can export or delete everything at any time.',
                        style: TextStyle(fontSize: 12, color: AppColors.grayDark, height: 1.6),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SettingsSectionTitle('VISIBILITY'),
          SettingsCard(
            children: [
              SettingsRow(
                icon: Icons.visibility_outlined,
                iconColor: AppColors.purpleLight,
                label: 'Profile Visibility',
                sublabel: 'Friends only',
                onTap: () {},
              ),
              SettingsRow(
                icon: Icons.person_outline,
                iconColor: AppColors.purpleLight,
                label: 'Show Online Status',
                sublabel: "Let friends see when you're studying",
                trailing: SettingsToggle(
                  value: onlineStatus,
                  onChanged: (v) => setState(() => onlineStatus = v),
                ),
                isLast: true,
              ),
            ],
          ),

          const SettingsSectionTitle('DATA COLLECTION'),
          SettingsCard(
            children: [
              SettingsRow(
                icon: Icons.language_outlined,
                iconColor: AppColors.gray,
                label: 'Analytics',
                sublabel: 'Help us improve FocusFeed',
                trailing: SettingsToggle(
                  value: analytics,
                  onChanged: (v) => setState(() => analytics = v),
                ),
              ),
              SettingsRow(
                icon: Icons.info_outline,
                iconColor: AppColors.gray,
                label: 'Crash Reports',
                sublabel: 'Send anonymous crash data',
                trailing: SettingsToggle(
                  value: crashReports,
                  onChanged: (v) => setState(() => crashReports = v),
                ),
                isLast: true,
              ),
            ],
          ),

          const SettingsSectionTitle('YOUR DATA'),
          SettingsCard(
            children: [
              SettingsRow(
                icon: Icons.download_outlined,
                iconColor: AppColors.green,
                label: 'Download All Data',
                sublabel: 'Export decks, cards, and stats as JSON',
                onTap: () {},
              ),
              SettingsRow(
                icon: Icons.delete_outline,
                iconColor: AppColors.redCoral,
                label: 'Delete All Study Data',
                sublabel: 'Remove all decks and cards permanently',
                isDanger: true,
                onTap: () {},
              ),
              SettingsRow(
                icon: Icons.warning_amber_outlined,
                iconColor: AppColors.redCoral,
                label: 'Delete Account',
                sublabel: 'Erase account and all associated data',
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
