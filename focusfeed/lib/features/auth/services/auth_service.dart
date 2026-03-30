import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthServices {
  final auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

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

  // Call this once during app startup before Google sign-in is used
  Future<void> initGoogleSignIn() async {
    await _googleSignIn.initialize();
  }

  // Google Sign in
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final credential = GoogleAuthProvider.credential(
        idToken: googleUser.authentication.idToken,
      );

      return await auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      return null;
    }
  }


  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await auth.signOut();
  }


  // Who is logged in right now?
  User? get currentUser => auth.currentUser;

  // A stream that fires whenever login state changes
  Stream<User?> get authStateChanges => auth.authStateChanges();

  final firestore = FirebaseFirestore.instance;

  Future<void> _createUserDocument(User user) async {
    final userDoc = firestore.collection('users').doc(user.uid);

    final snapshot = await userDoc.get();

    if (!snapshot.exists) {
      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
