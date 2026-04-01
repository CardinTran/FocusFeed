import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Handles all Firebase Authentication logic: email/password sign-up and
/// sign-in, Google OAuth sign-in, sign-out, and creating the user's
/// Firestore document on first login.
class AuthServices {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  /// Must be called once before using Google sign-in.
  Future<void> initGoogleSignIn() async {
    await _googleSignIn.initialize();
  }

  /// Creates a new account with email and password.
  /// Optionally sets [displayName] on the Firebase Auth profile.
  /// Returns null if sign-up fails.
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
          // reload() refreshes the local user object so displayName is up to date.
          await user.reload();
        }
        // Use auth.currentUser (post-reload) so the display name is included.
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

  /// Signs in an existing user with email and password.
  /// Returns null if sign-in fails.
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        // Safe to call on repeat logins — _createUserDocument is a no-op if
        // the document already exists.
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

  /// Signs in via Google OAuth. Shows the Google account picker, exchanges
  /// the ID token for a Firebase credential, then signs into Firebase.
  /// Returns null if the user cancels or an error occurs.
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

  /// Signs out of both Google and Firebase.
  /// Google is signed out first so its token is cleared before the Firebase
  /// session ends.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await auth.signOut();
  }

  /// The currently signed-in user, or null if no one is logged in.
  User? get currentUser => auth.currentUser;

  /// Stream that emits the current [User] on login and null on logout.
  /// Also emits immediately on subscription with the persisted session state.
  Stream<User?> get authStateChanges => auth.authStateChanges();

  /// Creates `users/{uid}` in Firestore the first time a user signs in.
  /// Skips silently if the document already exists, making it safe to call
  /// on every login.
  Future<void> _createUserDocument(User user) async {
    final userDoc = firestore.collection('users').doc(user.uid);
    final snapshot = await userDoc.get();

    if (!snapshot.exists) {
      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        // Lowercase copy used for case-insensitive name searches.
        'displayNameLower': user.displayName?.toLowerCase() ?? '',
        // Server timestamp avoids client clock drift issues.
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
