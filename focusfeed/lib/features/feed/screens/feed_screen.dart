import 'package:flutter/material.dart';
import 'package:focusfeed/features/auth/services/auth_service.dart';
import 'package:focusfeed/features/auth/screens/welcome_screen.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthServices();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F2A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome to FocusFeed!",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await auth.signOut();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                    (route) => false,
                  );
                }
              },
              child: const Text("Log Out"),
            ),
          ],
        ),
      ),
    );
  }
}
