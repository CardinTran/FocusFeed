import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/auth/screens/app_entry_screen.dart';
import 'features/auth/screens/create_account_screen.dart';
import 'features/screens/profile/screens/profile_setup_screen.dart';
import 'features/screens/main_nav_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const FocusFeed());
}

class FocusFeed extends StatelessWidget {
  const FocusFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AppEntryScreen(),
      routes: {
        '/home': (context) => const MainNavScreen(),
        '/signup': (context) => const CreateAccountScreen(),
        '/profile-setup': (context) => const ProfileSetupScreen(),
      },
    );
  }
}
