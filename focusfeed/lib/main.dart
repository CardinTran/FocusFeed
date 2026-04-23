import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'features/auth/screens/create_account_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/welcome_screen.dart';
import 'features/auth/services/auth_service.dart';
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
      home: const IntroScreen(),
      routes: {
        '/auth-gate': (context) => const _AuthGate(),
        '/home': (context) => const MainNavScreen(),
        '/signup': (context) => const CreateAccountScreen(),
        '/login': (context) => const LoginScreen(),
        '/profile-setup': (context) => const ProfileSetupScreen(),
        '/intro': (context) => const IntroScreen(),
      },
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = AuthServices();

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

        if (snapshot.hasData) {
          return const MainNavScreen();
        }

        return const WelcomeScreen();
      },
    );
  }
}
