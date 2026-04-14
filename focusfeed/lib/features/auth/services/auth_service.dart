import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Handles Firebase Authentication logic and creates the user's Firestore
/// document the first time they authenticate.
class AuthServices {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  /// Must be called once before using Google sign-in.
  Future<void> initGoogleSignIn() async {
    await _googleSignIn.initialize();
  }

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

      final user = credential.user;
      if (user != null) {
        final trimmedName = displayName?.trim();
        if (trimmedName != null && trimmedName.isNotEmpty) {
          await user.updateDisplayName(trimmedName);
          await user.reload();
        }
        await _createUserDocument(auth.currentUser ?? user);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Sign up failed: ${e.code} - ${e.message}');
      throw Exception(_mapAuthError(e));
    }
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        await _createUserDocument(user);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Login failed: ${e.code} - ${e.message}');
      throw Exception(_mapAuthError(e));
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.authenticate();
      final credential = GoogleAuthProvider.credential(
        idToken: googleUser.authentication.idToken,
      );

      final userCredential = await auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user != null) {
        await _createUserDocument(user);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Google sign-in failed: ${e.code} - ${e.message}');
      throw Exception(_mapAuthError(e));
    } catch (e) {
      debugPrint('Google sign-in failed: $e');
      throw Exception('Google sign-in failed. Please try again.');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      debugPrint('Password reset failed: ${e.code} - ${e.message}');
      throw Exception(_mapAuthError(e));
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('Google sign-out cleanup failed: $e');
    }

    await auth.signOut();
  }

  User? get currentUser => auth.currentUser;

  Stream<User?> get authStateChanges => auth.authStateChanges();

  Future<void> _createUserDocument(User user) async {
    final userDoc = firestore.collection('users').doc(user.uid);
    final snapshot = await userDoc.get();

    if (!snapshot.exists) {
      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'displayNameLower': user.displayName?.toLowerCase() ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
