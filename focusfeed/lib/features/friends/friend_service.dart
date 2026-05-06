// features/friends/friend_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'friend_model.dart';
import 'friend_repository.dart';

class FriendService {
  final _repo = FriendRepository();
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  // Send with duplicate + self-add guard
  Future<String?> sendRequest(String toUid, String toDisplayName) async {
    if (toUid == _uid) return 'You cannot add yourself.';

    final exists = await _repo.requestExists(_uid, toUid);
    if (exists) return 'Friend request already sent.';

    await _repo.sendRequest(_uid, toUid, toDisplayName);
    return null; // null = success
  }

  // Accept incoming request
  Future<void> acceptRequest(FriendRequest request) async {
    final myName = await _repo.getDisplayName(_uid);
    final fromName = request.fromDisplayName.isNotEmpty
        ? request.fromDisplayName
        : await _repo.getDisplayName(request.fromUid);
    await _repo.acceptRequest(
      request.id,
      request.fromUid,
      fromName,
      _uid,
      myName,
    );
  }

  // Decline incoming request
  Future<void> declineRequest(String requestId) async {
    await _repo.declineRequest(requestId);
  }

  // Remove an existing friend
  Future<void> removeFriend(String friendUid) async {
    await _repo.removeFriend(_uid, friendUid);
  }

  Future<List<UserResult>> searchUsers(String query) async {
    return _repo.searchUsers(query);
  }

  Stream<UserResult?> userProfile(String uid) => _repo.userProfile(uid);

  // Live stream of pending requests
  Stream<List<FriendRequest>> pendingRequests() => _repo.pendingRequests(_uid);

  // Live stream of friends list
  Stream<List<Friend>> friendsList() => _repo.friendsList(_uid);
}
