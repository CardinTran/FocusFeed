import 'package:flutter/material.dart';
import 'package:focusfeed/core/theme/app_colors.dart';
import 'package:focusfeed/features/settings/widgets/settings_card.dart';
import 'package:focusfeed/features/settings/widgets/settings_section_title.dart';

class SessionsScreen extends StatelessWidget {
  const SessionsScreen({super.key});

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
          'Active Sessions',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          const SettingsSectionTitle('CURRENT SESSION'),
          SettingsCard(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.green.withValues(alpha: 0.1),
                      ),
                      child: const Icon(Icons.smartphone, size: 18, color: AppColors.green),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Samsung Galaxy S24',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.white)),
                          SizedBox(height: 2),
                          Text('Baton Rouge, LA · Active now',
                              style: TextStyle(fontSize: 11, color: AppColors.grayDark)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: AppColors.green.withValues(alpha: 0.1),
                      ),
                      child: const Text('THIS DEVICE',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.green)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SettingsSectionTitle('OTHER SESSIONS'),
          SettingsCard(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.grayDark.withValues(alpha: 0.1),
                      ),
                      child: const Icon(Icons.language, size: 18, color: AppColors.grayDark),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Chrome on MacBook Pro',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.white)),
                          SizedBox(height: 2),
                          Text('Baton Rouge, LA · 2 hours ago',
                              style: TextStyle(fontSize: 11, color: AppColors.grayDark)),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.redCoral.withValues(alpha: 0.3)),
                        backgroundColor: AppColors.redCoral.withValues(alpha: 0.08),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Revoke',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.redCoral)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.redCoral.withValues(alpha: 0.3)),
                    backgroundColor: AppColors.redCoral.withValues(alpha: 0.05),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Sign Out All Other Devices',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.redCoral),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
