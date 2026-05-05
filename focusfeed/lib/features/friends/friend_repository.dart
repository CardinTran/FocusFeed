import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'friend_model.dart';

class FriendRepository {
  final _db = FirebaseFirestore.instance;

  Future<List<UserResult>> searchUsers(String query) async {
    if (query.isEmpty) return [];
    final lower = query.toLowerCase();
    try {
      final snap = await _db
          .collection('users')
          .where('usernameLower', isGreaterThanOrEqualTo: lower)
          .where('usernameLower', isLessThan: '$lower\uf8ff')
          .limit(10)
          .get();
      return snap.docs.map(UserResult.fromDoc).toList();
    } catch (e) {
      debugPrint('SEARCH ERROR: $e');
      return [];
    }
  }

  // Fetches sender's name then stores it so receiver sees it correctly
  Future<void> sendRequest(
    String fromUid,
    String toUid,
    String toDisplayName,
  ) async {
    final fromDisplayName = await getDisplayName(fromUid);
    final fromUsername = await getUsername(fromUid);
    await _db.collection('friendRequests').add({
      'fromUid': fromUid,
      'toUid': toUid,
      'fromDisplayName': fromDisplayName,
      'fromUsername': fromUsername,
      'toDisplayName': toDisplayName,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> acceptRequest(
    String requestId,
    String fromUid,
    String fromDisplayName,
    String currentUid,
    String currentDisplayName,
  ) async {
    final batch = _db.batch();
    final ts = FieldValue.serverTimestamp();

    batch.update(_db.collection('friendRequests').doc(requestId), {
      'status': 'accepted',
    });
    batch.set(_db.doc('friends/$currentUid/friendsList/$fromUid'), {
      'uid': fromUid,
      'displayName': fromDisplayName,
      'addedAt': ts,
    });
    batch.set(_db.doc('friends/$fromUid/friendsList/$currentUid'), {
      'uid': currentUid,
      'displayName': currentDisplayName,
      'addedAt': ts,
    });

    await batch.commit();
  }

  Future<void> declineRequest(String requestId) async {
    await _db.collection('friendRequests').doc(requestId).update({
      'status': 'declined',
    });
  }

  Future<void> removeFriend(String currentUid, String friendUid) async {
    final batch = _db.batch();
    batch.delete(_db.doc('friends/$currentUid/friendsList/$friendUid'));
    batch.delete(_db.doc('friends/$friendUid/friendsList/$currentUid'));
    await batch.commit();
  }

  Stream<List<FriendRequest>> pendingRequests(String uid) {
    return _db
        .collection('friendRequests')
        .where('toUid', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((s) => s.docs.map(FriendRequest.fromDoc).toList());
  }

  Stream<List<Friend>> friendsList(String uid) {
    return _db
        .collection('friends')
        .doc(uid)
        .collection('friendsList')
        .snapshots()
        .map((s) => s.docs.map(Friend.fromDoc).toList());
  }

  Stream<UserResult?> userProfile(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserResult.fromDoc(doc);
    });
  }

  Future<bool> requestExists(String fromUid, String toUid) async {
    final snap = await _db
        .collection('friendRequests')
        .where('fromUid', isEqualTo: fromUid)
        .where('toUid', isEqualTo: toUid)
        .where('status', isEqualTo: 'pending')
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<String> getDisplayName(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    final data = doc.data();
    return data?['displayName'] as String? ??
        data?['username'] as String? ??
        'Unknown';
  }

  Future<String> getUsername(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data()?['username'] as String? ?? '';
  }
}
