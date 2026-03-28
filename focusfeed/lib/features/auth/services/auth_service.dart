import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthServices {
  final auth = FirebaseAuth.instance;

  // Sign up with email/password
  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _createUserDocument(credential.user!);

      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      return null;
    }
  }

  // Sign in with email/password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _createUserDocument(credential.user!);

      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      return null;
    }
  }

  // Google Sign in
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return null;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await GoogleSignIn().signOut();
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
