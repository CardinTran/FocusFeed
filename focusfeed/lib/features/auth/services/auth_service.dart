import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthServices {
  final auth = FirebaseAuth.instance;

  // Convert Firebase auth error codes into clear user-facing messages
  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'user-not-found':
        return 'No account found for that email.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }

  // Sign up with email/password and throw readable errors back to the UI
  Future<UserCredential> signUpWithEmail(
    String email,
    String password, {
    String? displayName,
  }) async {
    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final trimmedDisplayName = displayName?.trim();
      if (trimmedDisplayName != null && trimmedDisplayName.isNotEmpty) {
        await credential.user?.updateDisplayName(trimmedDisplayName);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Sign up failed: ${e.code} - ${e.message}');
      throw Exception(_mapAuthError(e));
    }
  }

  // Sign in with email/password and throw readable errors back to the UI
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Login failed: ${e.code} - ${e.message}');
      throw Exception(_mapAuthError(e));
    }
  }

  // Sign in with Google and surface cancellation/errors clearly to the UI
  Future<UserCredential> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled.');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      debugPrint('Google sign-in failed: ${e.code} - ${e.message}');
      throw Exception(_mapAuthError(e));
    } catch (e) {
      debugPrint('Google sign-in failed: $e');
      rethrow;
    }
  }

  // Send a password reset email to an existing account
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      debugPrint('Password reset failed: ${e.code} - ${e.message}');
      throw Exception(_mapAuthError(e));
    }
  }

  // Sign out of both Firebase and Google to fully clear the session
  Future<void> signOut() async {
    await auth.signOut();

    try {
      await GoogleSignIn().signOut();
    } catch (e) {
      debugPrint('Google sign-out cleanup failed: $e');
    }
  }
  // Who is logged in right now
  User? get currentUser => auth.currentUser;

  // A stream that fires whenever the authentication state changes
  Stream<User?> get authStateChanges => auth.authStateChanges();
}
