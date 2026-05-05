import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:focusfeed/features/auth/services/username_policy.dart';

class UsernameTakenException implements Exception {}

class UsernameReservationService {
  UsernameReservationService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> reserveUsername({
    required String uid,
    required String username,
  }) async {
    await _firestore.runTransaction((transaction) {
      return reserveUsernameInTransaction(
        transaction,
        uid: uid,
        username: username,
      );
    });
  }

  Future<void> reserveUsernameInTransaction(
    Transaction transaction, {
    required String uid,
    required String username,
  }) async {
    final usernameError = UsernamePolicy.validate(username);
    if (usernameError != null) {
      throw ArgumentError(usernameError);
    }

    final normalizedUsername = UsernamePolicy.normalize(username);
    final usernameDoc = _firestore
        .collection('usernames')
        .doc(normalizedUsername);
    final usernameSnapshot = await transaction.get(usernameDoc);

    if (usernameSnapshot.exists) {
      throw UsernameTakenException();
    }

    transaction.set(usernameDoc, {
      'uid': uid,
      'username': username.trim(),
      'usernameLower': normalizedUsername,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
