import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F2A),
        elevation: 0,
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle("Account"),
          _settingsTile(
            icon: Icons.person_outline,
            title: "Username",
            subtitle: "Change your display name",
            onTap: () {},
          ),
          _settingsTile(
            icon: Icons.email_outlined,
            title: "Email",
            subtitle: "Update your email address",
            onTap: () {},
          ),
          _settingsTile(
            icon: Icons.lock_outline,
            title: "Password",
            subtitle: "Change your password",
            onTap: () {},
          ),
          _settingsTile(
            icon: Icons.logout,
            title: "Log Out",
            subtitle: "Sign out of your account",
            onTap: () {},
          ),

          const SizedBox(height: 24),

          _sectionTitle("Academic Preferences"),
          _settingsTile(
            icon: Icons.school_outlined,
            title: "School",
            subtitle: "Set your school or university",
            onTap: () {},
          ),
          _settingsTile(
            icon: Icons.menu_book_outlined,
            title: "Courses",
            subtitle: "Choose your current courses",
            onTap: () {},
          ),
          _settingsTile(
            icon: Icons.interests_outlined,
            title: "Subjects of Interest",
            subtitle: "Personalize your content feed",
            onTap: () {},
          ),

          const SizedBox(height: 24),

          _sectionTitle("App Preferences"),
          SwitchListTile(
            value: true,
            onChanged: (value) {},
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0x66FFFFFF),
            tileColor: const Color(0xFF151A3B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            title: const Text(
              "Notifications",
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              "Enable reminders and updates",
              style: TextStyle(color: Colors.white70),
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: true,
            onChanged: (value) {},
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0x66FFFFFF),
            tileColor: const Color(0xFF151A3B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            title: const Text(
              "Auto-generate flashcards",
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              "Create flashcards from imported study content",
              style: TextStyle(color: Colors.white70),
            ),
          ),

          const SizedBox(height: 24),

          _sectionTitle("Privacy & Support"),
          _settingsTile(
            icon: Icons.privacy_tip_outlined,
            title: "Privacy",
            subtitle: "View privacy settings",
            onTap: () {},
          ),
          _settingsTile(
            icon: Icons.bug_report_outlined,
            title: "Report a Bug",
            subtitle: "Help us improve the app",
            onTap: () {},
          ),
          _settingsTile(
            icon: Icons.info_outline,
            title: "About",
            subtitle: "App version and information",
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        tileColor: const Color(0xFF151A3B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white70),
        onTap: onTap,
      ),
    );
  }
}
