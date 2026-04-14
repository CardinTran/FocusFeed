import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:focusfeed/features/auth/services/auth_service.dart';

import 'features/auth/screens/app_entry_screen.dart';
import 'features/auth/screens/create_account_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/intro/screens/intro_screen.dart';
import 'features/nav/main_nav_screen.dart';
import 'features/profile/screens/profile_setup_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AuthServices().initGoogleSignIn();
  runApp(const FocusFeed());
}

class FocusFeed extends StatelessWidget {
  const FocusFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Change back to AppEntryScreen after intro testing is complete.
      home: const IntroScreen(),
      routes: {
        '/auth-gate': (context) => const AppEntryScreen(),
        '/home': (context) => const MainNavScreen(),
        '/signup': (context) => const CreateAccountScreen(),
        '/login': (context) => const LoginScreen(),
        '/profile-setup': (context) => const ProfileSetupScreen(),
        '/intro': (context) => const IntroScreen(),
      },
    );
  }
}
