import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  ProfileService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  User get _currentUser {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No authenticated user found.');
    }
    return user;
  }

  DocumentReference<Map<String, dynamic>> get _profileDoc =>
      _firestore.collection('users').doc(_currentUser.uid);

  Future<bool> hasCompletedSetup() async {
    final snapshot = await _profileDoc.get();
    if (!snapshot.exists) {
      return false;
    }

    final data = snapshot.data();
    return data?['setupComplete'] == true;
  }

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
