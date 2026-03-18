import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/auth/screens/welcome_screen.dart';
import 'features/auth/screens/create_account_screen.dart';
import 'features/feed/screens/feed_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const FocusFeed());
}

class FocusFeed extends StatelessWidget {
  const FocusFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const WelcomeScreen(),
      routes: {
        '/home': (context) => const FeedScreen(),
        '/signup': (context) => const CreateAccountScreen(),
      },
    );
  }
}
