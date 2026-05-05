import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:focusfeed/features/auth/services/username_policy.dart';
import 'package:focusfeed/features/auth/services/username_reservation_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Handles Firebase Authentication logic and creates the user's Firestore
/// document the first time they authenticate.
class AuthServices {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  late final UsernameReservationService _usernameReservations =
      UsernameReservationService(firestore: firestore);

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
    required String username,
  }) async {
    User? createdUser;
    try {
      final usernameError = UsernamePolicy.validate(username);
      if (usernameError != null) {
        throw Exception(usernameError);
      }

      final credential = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      createdUser = user;
      if (user != null) {
        final trimmedUsername = username.trim();
        await user.updateDisplayName(trimmedUsername);
        await user.reload();
        await _createEmailUserDocument(
          user: auth.currentUser ?? user,
          username: username,
        );
      }

      return credential;
    } on UsernameTakenException {
      await _deletePartiallyCreatedUser(createdUser);
      throw Exception('That username is already taken.');
    } on FirebaseAuthException catch (e) {
      debugPrint('Sign up failed: ${e.code} - ${e.message}');
      throw Exception(_mapAuthError(e));
    } on FirebaseException catch (e) {
      await _deletePartiallyCreatedUser(createdUser);
      debugPrint('Sign up profile setup failed: ${e.code} - ${e.message}');
      throw Exception('Could not finish account setup. Please try again.');
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

  Future<void> _createEmailUserDocument({
    required User user,
    required String username,
  }) async {
    final trimmedUsername = username.trim();
    final normalizedUsername = UsernamePolicy.normalize(username);
    final userDoc = firestore.collection('users').doc(user.uid);

    await firestore.runTransaction((transaction) async {
      await _usernameReservations.reserveUsernameInTransaction(
        transaction,
        uid: user.uid,
        username: username,
      );

      transaction.set(userDoc, {
        'uid': user.uid,
        'email': user.email,
        'displayName': trimmedUsername,
        'displayNameLower': normalizedUsername,
        'username': trimmedUsername,
        'usernameLower': normalizedUsername,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> _deletePartiallyCreatedUser(User? user) async {
    if (user == null) return;

    try {
      await user.delete();
    } catch (e) {
      debugPrint('Failed to clean up incomplete signup user: $e');
    } finally {
      await auth.signOut();
    }
  }
}
