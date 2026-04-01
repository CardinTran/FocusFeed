import 'package:flutter/material.dart';
import 'package:focusfeed/features/auth/screens/welcome_screen.dart';
import 'package:focusfeed/features/auth/services/auth_service.dart';
import 'package:focusfeed/features/profile/screens/profile_setup_screen.dart';
import 'package:focusfeed/features/profile/services/profile_service.dart';
import 'package:focusfeed/features/nav/main_nav_screen.dart';

/// Root routing widget. Decides which screen to show based on auth and
/// profile state. Three possible outcomes:
///   - Not logged in → WelcomeScreen
///   - Logged in, setup incomplete → ProfileSetupScreen
///   - Logged in, setup complete → MainNavScreen
class AppEntryScreen extends StatelessWidget {
  const AppEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthServices();
    final profileService = ProfileService();

    // StreamBuilder listens to Firebase auth state in real time.
    // Rebuilds whenever the user signs in or out.
    return StreamBuilder(
      stream: auth.authStateChanges,
      builder: (context, snapshot) {
        // Still waiting for Firebase to confirm auth state.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        // No authenticated user — send to login/signup.
        if (snapshot.data == null) {
          return const WelcomeScreen();
        }

        // User is logged in. Check if they've finished profile setup.
        return FutureBuilder<bool>(
          future: profileService.hasCompletedSetup(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingScreen();
            }

            // Setup complete → main app. Otherwise → setup wizard.
            return profileSnapshot.data == true
                ? const MainNavScreen()
                : const ProfileSetupScreen();
          },
        );
      },
    );
  }
}

/// Shared full-screen loading spinner shown while waiting for Firebase.
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0B0F2A),
      body: Center(
        child: CircularProgressIndicator(
          color: Color.fromRGBO(133, 90, 251, 1),
        ),
      ),
    );
  }
}
