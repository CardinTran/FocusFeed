import 'package:flutter/material.dart';
import 'package:focusfeed/features/auth/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _showPassword = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final auth = AuthServices();

  @override
  void dispose(){
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F2A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back, color: Color.fromRGBO(133, 90, 251, 1), size: 18),
                      SizedBox(width: 4),
                      Text("Back", style: TextStyle(color: Color.fromRGBO(133, 90, 251, 1))),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Logo
                Center(
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Title
                const Center(
                  child: Text(
                    "FocusFeed",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(133, 90, 251, 1),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                const SizedBox(height: 36),

                // Email
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Email",
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon: const Icon(Icons.email_outlined, color: Colors.white38, size: 20),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color.fromRGBO(133, 90, 251, 0.4)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color.fromRGBO(133, 90, 251, 1)),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Password
                TextField(
                  controller: passwordController,
                  obscureText: !_showPassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Password",
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.white38, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility_off_outlined : Icons.remove_red_eye_outlined,
                        color: Colors.white38,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _showPassword = !_showPassword),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color.fromRGBO(133, 90, 251, 0.4)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color.fromRGBO(133, 90, 251, 1)),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Login Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(133, 90, 251, 1),
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async{
                    final result = await auth.signInWithEmail(
                      emailController.text.trim(),
                      passwordController.text,
                      );
                      if (result == null) return;
                      if (!context.mounted) return;
                      Navigator.pushReplacementNamed(context, '/home');
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),

                const SizedBox(height: 20),

                // Or continue with
                Row(
                  children: [
                    const Expanded(child: Divider(color: Colors.white24)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text("Or continue with", style: TextStyle(color: Colors.white38, fontSize: 13)),
                    ),
                    const Expanded(child: Divider(color: Colors.white24)),
                  ],
                ),

                const SizedBox(height: 16),

                // Google
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    minimumSize: const Size(double.infinity, 52),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async{
                    final result = await auth.signInWithGoogle();
                    if (result == null) return;
                    if (!context.mounted) return;
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  icon: const Text("G", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  label: const Text("Google", style: TextStyle(color: Colors.white)),
                ),

                const SizedBox(height: 20),

                // Don't have an account
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/signup'),
                  child: Center(
                    child: RichText(
                      text: const TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                        children: [
                          TextSpan(
                            text: "Sign Up",
                            style: TextStyle(color: Color.fromRGBO(133, 90, 251, 1), fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
