import 'package:flutter/material.dart';
import 'package:focusfeed/features/auth/screens/welcome_screen.dart';
import 'package:focusfeed/features/auth/services/auth_service.dart';
import 'package:focusfeed/features/profile/screens/profile_setup_screen.dart';
import 'package:focusfeed/features/profile/services/profile_service.dart';
import 'package:focusfeed/features/nav/main_nav_screen.dart';

class AppEntryScreen extends StatelessWidget {
  const AppEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthServices();
    final profileService = ProfileService();

    return StreamBuilder(
      stream: auth.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0B0F2A),
            body: Center(
              child: CircularProgressIndicator(
                color: Color.fromRGBO(133, 90, 251, 1),
              ),
            ),
          );
        }

        if (snapshot.data == null) {
          return const WelcomeScreen();
        }

        return FutureBuilder<bool>(
          future: profileService.hasCompletedSetup(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: Color(0xFF0B0F2A),
                body: Center(
                  child: CircularProgressIndicator(
                    color: Color.fromRGBO(133, 90, 251, 1),
                  ),
                ),
              );
            }

            if (profileSnapshot.data == true) {
              return const MainNavScreen();
            }

            return const ProfileSetupScreen();
          },
        );
      },
    );
  }
}
