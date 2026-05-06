// features/friends/friend_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// Result from user search
class UserResult {
  final String uid;
  final String displayName;
  final String username;

  const UserResult({
    required this.uid,
    required this.displayName,
    required this.username,
  });

  factory UserResult.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final username = data['username'] as String? ?? '';
    return UserResult(
      uid: doc.id,
      displayName:
          data['displayName'] as String? ??
          (username.isEmpty ? 'Unknown' : username),
      username: username,
    );
  }
}

class FriendRequest {
  final String id;
  final String fromUid;
  final String toUid;
  final String fromDisplayName;
  final String status;
  final DateTime? createdAt;

  const FriendRequest({
    required this.id,
    required this.fromUid,
    required this.toUid,
    required this.fromDisplayName,
    required this.status,
    this.createdAt,
  });

  factory FriendRequest.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FriendRequest(
      id: doc.id,
      fromUid: data['fromUid'] as String,
      toUid: data['toUid'] as String,
      fromDisplayName: data['fromDisplayName'] as String? ?? 'Unknown',
      status: data['status'] as String,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

class Friend {
  final String uid;
  final String displayName;
  final String username;
  final DateTime? addedAt;

  const Friend({
    required this.uid,
    required this.displayName,
    this.username = '',
    this.addedAt,
  });

  factory Friend.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final username = data['username'] as String? ?? '';
    return Friend(
      uid: data['uid'] as String,
      displayName:
          data['displayName'] as String? ??
          (username.isEmpty ? 'Unknown' : username),
      username: username,
      addedAt: (data['addedAt'] as Timestamp?)?.toDate(),
    );
  }
}
