import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:focusfeed/features/auth/screens/app_entry_screen.dart';
import 'package:focusfeed/features/auth/services/auth_service.dart';
import 'package:focusfeed/features/friends/friends_screen.dart';
import 'package:focusfeed/features/settings/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color _bg     = Color(0xFF0B0F2A);
  static const Color _card   = Color(0xFF151A3B);
  static const Color _accent = Color(0xFF855AFB);
  static const Color _primary = Colors.white;
  static const Color _muted  = Color(0x70FFFFFF);
  static const Color _divider = Color(0x12FFFFFF);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? '';

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snap) {
        final data = snap.data?.data() as Map<String, dynamic>?;
        final name = data?['displayName'] as String? ?? 'No name set';
        final email = user?.email ?? '';
        final initials = name
            .split(' ')
            .where((w) => w.isNotEmpty)
            .take(2)
            .map((w) => w[0].toUpperCase())
            .join();

        return Scaffold(
          backgroundColor: _bg,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(children: [
                      const SizedBox(height: 16),
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: _accent,
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(name,
                          style: const TextStyle(
                              color: _primary,
                              fontSize: 20,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(email,
                          style: const TextStyle(color: _muted, fontSize: 13)),
                      const SizedBox(height: 28),
                    ]),
                  ),

                  _sectionLabel('Social'),
                  _menuCard([
                    _menuRow(
                      context,
                      icon: Icons.people_outline,
                      iconBg: _accent.withOpacity(0.15),
                      iconColor: _accent,
                      label: 'Friends',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const FriendsScreen())),
                    ),
                  ]),

                  const SizedBox(height: 16),

                  _sectionLabel('Preferences'),
                  _menuCard([
                    _menuRow(
                      context,
                      icon: Icons.settings_outlined,
                      iconBg: Colors.white.withOpacity(0.06),
                      iconColor: _muted,
                      label: 'Settings',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const SettingsScreen())),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0x25FFFFFF)),
                        foregroundColor: Colors.redAccent,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => _logout(context),
                      child: const Text('Log Out',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ); // end Scaffold
      }, // end FutureBuilder builder
    ); // end FutureBuilder
  } // end build

  Widget _sectionLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(label.toUpperCase(),
            style: const TextStyle(
                color: Color(0x40FFFFFF),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8)),
      );

  Widget _menuCard(List<Widget> rows) => Container(
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _divider),
        ),
        child: Column(children: rows),
      );

  Widget _menuRow(
    BuildContext context, {
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  color: iconBg, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: iconColor, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(color: Colors.white, fontSize: 14)),
            ),
            const Icon(Icons.chevron_right, color: Color(0x30FFFFFF), size: 18),
          ]),
        ),
      );

  Future<void> _logout(BuildContext context) async {
    await AuthServices().signOut();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AppEntryScreen()),
      (_) => false,
    );
  }
}