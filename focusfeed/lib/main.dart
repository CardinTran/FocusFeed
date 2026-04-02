import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:focusfeed/features/auth/services/auth_service.dart';
import 'firebase_options.dart';
import 'features/auth/screens/app_entry_screen.dart';
import 'features/auth/screens/create_account_screen.dart';
import 'features/profile/screens/profile_setup_screen.dart';
import 'features/nav/main_nav_screen.dart';
import 'features/intro/screens/intro_screen.dart';

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
      //change back to "home: const AppEntryScreen()," after testing intro
      //also make so that intro only shows on first launch or when user logs out
      home: const IntroScreen(),
      routes: {
        '/home': (context) => const MainNavScreen(),
        '/signup': (context) => const CreateAccountScreen(),
        '/profile-setup': (context) => const ProfileSetupScreen(),
        '/intro': (context) => const IntroScreen(),
      },
    );
  }
}
