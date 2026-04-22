import 'package:flutter/material.dart';
import 'friend_model.dart';
import 'friend_service.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  static const Color _bg     = Color(0xFF0B0F2A);
  static const Color _card   = Color(0xFF151A3B);
  static const Color _accent = Color(0xFF855AFB);
  static const Color _border = Color(0x12FFFFFF);

  final _service = FriendService();
  final _searchController = TextEditingController();

  List<UserResult> _searchResults = [];
  bool _searching = false;

  Future<void> _onSearchChanged(String query) async {
    if (query.length < 2) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _searching = true);
    final results = await _service.searchUsers(query);
    if (mounted) setState(() { _searchResults = results; _searching = false; });
  }

  Future<void> _sendRequest(UserResult user) async {
    final error = await _service.sendRequest(user.uid, user.displayName);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Request sent to ${user.displayName}!')),
    );
    if (error == null) {
      _searchController.clear();
      setState(() => _searchResults = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: const Color(0xFF12182F),
          title: const Text('Friends', style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            labelColor: _accent,
            unselectedLabelColor: Colors.white54,
            indicatorColor: _accent,
            tabs: [
              Tab(text: 'My Friends'),
              Tab(text: 'Requests'),
            ],
          ),
        ),
        body: Column(children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by username...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white38),
                suffixIcon: _searching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _accent,
                          ),
                        ),
                      )
                    : null,
                filled: true,
                fillColor: _card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _accent, width: 1.4),
                ),
                isDense: true,
              ),
            ),
          ),

          // Search results
          if (_searchResults.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: _card,
                border: Border.all(color: _border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _searchResults.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1, color: Color(0x12FFFFFF)),
                itemBuilder: (_, i) {
                  final user = _searchResults[i];
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      backgroundColor: _accent.withOpacity(0.2),
                      child: const Icon(Icons.person, size: 18, color: _accent),
                    ),
                    title: Text(user.displayName,
                        style: const TextStyle(color: Colors.white)),
                    trailing: TextButton(
                      onPressed: () => _sendRequest(user),
                      child: const Text('Add',
                          style: TextStyle(color: _accent)),
                    ),
                  );
                },
              ),
            ),

          // Tab views
          Expanded(
            child: TabBarView(children: [
              _buildFriendsList(),
              _buildPendingList(),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildFriendsList() {
    return StreamBuilder<List<Friend>>(
      stream: _service.friendsList(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _accent));
        }
        final friends = snap.data ?? [];
        if (friends.isEmpty) {
          return const Center(
            child: Text('No friends yet.',
                style: TextStyle(color: Colors.white54)));
        }
        return ListView.builder(
          itemCount: friends.length,
          itemBuilder: (_, i) {
            final f = friends[i];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: _accent.withOpacity(0.2),
                child: const Icon(Icons.person, color: _accent),
              ),
              title: Text(f.displayName,
                  style: const TextStyle(color: Colors.white)),
              trailing: IconButton(
                icon: const Icon(Icons.person_remove_outlined,
                    color: Colors.white38),
                onPressed: () => _service.removeFriend(f.uid),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPendingList() {
    return StreamBuilder<List<FriendRequest>>(
      stream: _service.pendingRequests(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _accent));
        }
        final requests = snap.data ?? [];
        if (requests.isEmpty) {
          return const Center(
            child: Text('No pending requests.',
                style: TextStyle(color: Colors.white54)));
        }
        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (_, i) {
            final r = requests[i];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: _accent.withOpacity(0.2),
                child: const Icon(Icons.person_add, color: _accent),
              ),
              title: Text(r.fromDisplayName,
                  style: const TextStyle(color: Colors.white)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline,
                        color: Colors.greenAccent),
                    onPressed: () => _service.acceptRequest(r),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel_outlined,
                        color: Colors.redAccent),
                    onPressed: () => _service.declineRequest(r.id),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}