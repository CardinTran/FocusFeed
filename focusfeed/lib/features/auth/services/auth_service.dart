import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthServices {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<void> initGoogleSignIn() async {
    await _googleSignIn.initialize();
  }

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
      debugPrint(e.message);
      return null;
    } catch (e) {
      debugPrint(e.toString());
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

      final user = credential.user;
      if (user != null) {
        await _createUserDocument(user);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      return null;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  // Google Sign in
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

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
      debugPrint(e.message);
      return null;
    } catch (e) {
      debugPrint(e.toString());
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

  Future<void> _createUserDocument(User user) async {
    final userDoc = firestore.collection('users').doc(user.uid);
    final snapshot = await userDoc.get();

    if (!snapshot.exists) {
      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
