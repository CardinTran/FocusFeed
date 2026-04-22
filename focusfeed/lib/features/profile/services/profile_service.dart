import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Handles Firestore reads and writes for the user's profile document.
/// Supports dependency injection so Firebase can be mocked in tests.
class ProfileService {
  ProfileService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  /// Returns the signed-in user, or throws [StateError] if no one is logged in.
  User get _currentUser {
    final user = _auth.currentUser;
    if (user == null) throw StateError('No authenticated user found.');
    return user;
  }

  /// Reference to `users/{uid}` — always reflects the current user's UID.
  DocumentReference<Map<String, dynamic>> get _profileDoc =>
      _firestore.collection('users').doc(_currentUser.uid);

  /// Returns the full `users/{uid}` document as a raw map, or `null` if the
  /// document does not exist (e.g. the user was created before Firestore
  /// writes were added).
  Future<Map<String, dynamic>?> getProfile() async {
    final snapshot = await _profileDoc.get();
    if (!snapshot.exists) return null;
    return snapshot.data();
  }

  /// Merges [data] into `users/{uid}` without overwriting unrelated fields.
  /// Always stamps `updatedAt` with a server timestamp so the last-modified
  /// time is always accurate regardless of client clock drift.
  Future<void> updateProfile(Map<String, dynamic> data) async {
    await _profileDoc.set(
      {...data, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  /// Returns `true` if `users/{uid}` has `setupComplete == true`.
  /// Used by [AppEntryScreen] to decide whether to show the onboarding wizard
  /// or the main app on login.
  Future<bool> hasCompletedSetup() async {
    final snapshot = await _profileDoc.get();
    if (!snapshot.exists) return false;
    return snapshot.data()?['setupComplete'] == true;
  }

  /// Writes the user's onboarding choices to Firestore and marks setup complete.
  /// Uses merge:true so existing fields (like uid, createdAt) are not overwritten.
  Future<void> saveSetup({
    required String school,
    required List<String> selectedCourses,
    required List<String> selectedSubjects,
    required bool notificationsEnabled,
    required bool autoGenerateFlashcards,
  }) async {
    final user = _currentUser;

    await _profileDoc.set({
      'displayName': user.displayName,
      'email': user.email,
      'school': school.trim(),
      'selectedCourses': selectedCourses,
      'selectedSubjects': selectedSubjects,
      'notificationsEnabled': notificationsEnabled,
      'autoGenerateFlashcards': autoGenerateFlashcards,
      'setupComplete': true,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
