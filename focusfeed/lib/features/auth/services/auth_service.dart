import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthServices {
  final auth = FirebaseAuth.instance;

  // Sign up with email/password
  Future<UserCredential?> signUpWithEmail(
    String email,
    String password, {
    String? displayName,
  }) async {
    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final trimmedName = displayName?.trim();
      if (trimmedName != null && trimmedName.isNotEmpty) {
        await credential.user?.updateDisplayName(trimmedName);
        await credential.user?.reload();
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      return null;
    }
  }

  // Sign in with email/password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      return null;
    }
  }

  // Google Sign in
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final result = await GoogleSignIn.instance.authenticate();
      final googleAuth = result.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      return await auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await auth.signOut();
  }

  // Who is logged in right now?
  User? get currentUser => auth.currentUser;

  // A stream that fires whenever login state changes
  Stream<User?> get authStateChanges => auth.authStateChanges();
}
