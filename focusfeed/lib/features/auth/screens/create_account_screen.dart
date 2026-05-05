import 'package:flutter/material.dart';
import 'package:focusfeed/features/auth/screens/app_entry_screen.dart';
import 'package:focusfeed/features/auth/services/auth_service.dart';
import 'package:focusfeed/features/auth/services/username_policy.dart';
import 'package:focusfeed/features/profile/screens/profile_setup_screen.dart';

/// Sign-up screen. Collects username, email, password, and confirm password,
/// validates them inline, then calls [AuthServices.signUpWithEmail].
/// On success navigates to [ProfileSetupScreen] to complete onboarding.
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  static const bool _googleSignInEnabled = true;

  final _formKey = GlobalKey<FormState>();
  final _confirmPasswordFieldKey = GlobalKey<FormFieldState<String>>();
  bool _isLoading = false;
  String? _authError;
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  late final auth = AuthServices();

  bool _showPassword = false;
  bool _showConfirmPassword = false;

  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  String? validateUsername(String? value) => UsernamePolicy.validate(value);

  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return "Email cannot be empty";
    }
    if (!isValidEmail(email)) {
      return "Please enter a valid email address";
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password cannot be empty";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Confirm Password cannot be empty";
    }
    if (passwordController.text != value) {
      return "Passwords do not match";
    }
    return null;
  }

  Future<void> _handleCreateAccount() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid || _isLoading) return;

    setState(() {
      _isLoading = true;
      _authError = null;
    });

    try {
      await auth.signUpWithEmail(
        emailController.text.trim(),
        passwordController.text,
        username: usernameController.text,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _authError = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _authError = null;
    });

    try {
      await auth.signInWithGoogle();

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AppEntryScreen()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _authError = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back,
                          color: Color.fromRGBO(133, 90, 251, 1),
                          size: 18,
                        ),
                        SizedBox(width: 4),
                        Text(
                          "Back",
                          style: TextStyle(
                            color: Color.fromRGBO(133, 90, 251, 1),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Logo
                  Center(
                    child: Image.asset(
                      'web/ff-logo-transparent.png',
                      width: 80,
                      height: 80,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Title
                  const Center(
                    child: Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(133, 90, 251, 1),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Username
                  _InputField(
                    hint: "Username",
                    icon: Icons.alternate_email,
                    controller: usernameController,
                    validator: validateUsername,
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: 14),

                  // Email
                  _InputField(
                    hint: "Email",
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    controller: emailController,
                    validator: validateEmail,
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: 14),

                  // Password
                  _InputField(
                    hint: "Password",
                    icon: Icons.lock_outline,
                    obscure: !_showPassword,
                    controller: passwordController,
                    validator: validatePassword,
                    textInputAction: TextInputAction.next,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword
                            ? Icons.visibility_off_outlined
                            : Icons.remove_red_eye_outlined,
                        color: Colors.white38,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _showPassword = !_showPassword),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Confirm Password
                  _InputField(
                    fieldKey: _confirmPasswordFieldKey,
                    hint: "Confirm Password",
                    icon: Icons.lock_outline,
                    obscure: !_showConfirmPassword,
                    controller: confirmPasswordController,
                    validator: validateConfirmPassword,
                    textInputAction: TextInputAction.done,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.remove_red_eye_outlined,
                        color: Colors.white38,
                        size: 20,
                      ),
                      onPressed: () => setState(
                        () => _showConfirmPassword = !_showConfirmPassword,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (_authError != null) ...[
                    Text(
                      _authError!,
                      style: const TextStyle(color: Color(0xFFFF8A80)),
                    ),
                    const SizedBox(height: 12),
                  ],

                  const SizedBox(height: 8),

                  // Create Account Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(133, 90, 251, 1),
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading ? null : _handleCreateAccount,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Create Account",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),

                  const SizedBox(height: 20),

                  if (_googleSignInEnabled) ...[
                    // Or continue with
                    Row(
                      children: [
                        const Expanded(child: Divider(color: Colors.white24)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            "Or continue with",
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: Colors.white24)),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Google Button
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        minimumSize: const Size(double.infinity, 52),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isLoading ? null : _handleGoogleSignIn,
                      icon: const Text(
                        "G",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      label: const Text(
                        "Google",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],

                  // Already have an account
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Center(
                      child: RichText(
                        text: const TextSpan(
                          text: "Already have an account? ",
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                          children: [
                            TextSpan(
                              text: "Login",
                              style: TextStyle(
                                color: Color.fromRGBO(133, 90, 251, 1),
                                fontWeight: FontWeight.bold,
                              ),
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
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final Key? fieldKey;
  final TextEditingController? controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;

  const _InputField({
    this.fieldKey,
    required this.hint,
    required this.icon,
    this.controller,
    this.obscure = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      textInputAction: textInputAction,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        suffixIcon: suffixIcon,
        errorStyle: const TextStyle(color: Color(0xFFFF8A80)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color.fromRGBO(133, 90, 251, 0.4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color.fromRGBO(133, 90, 251, 1)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF8A80)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF8A80), width: 1.5),
        ),
      ),
    );
  }
}
