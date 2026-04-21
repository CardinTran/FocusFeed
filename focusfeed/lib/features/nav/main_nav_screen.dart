import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focusfeed/features/feed/feed_controller.dart';
import 'package:focusfeed/features/feed/feed_item.dart';
import 'package:focusfeed/features/feed/feed_screen.dart';
import 'package:focusfeed/features/import/import_screen.dart';
import 'package:focusfeed/features/library/library_screen.dart';
import 'package:focusfeed/features/nav/nav_tab.dart';
import 'package:focusfeed/features/nav/widgets/custom_bottom_nav_bar.dart';
import 'package:focusfeed/features/saved/saved_screen.dart';
import 'package:focusfeed/features/profile/screens/profile_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  final FeedController _feedController = FeedController();
  NavTab _selectedTab = NavTab.feed;

  void _selectTab(NavTab tab) {
    if (_selectedTab == tab) return;
    setState(() => _selectedTab = tab);
  }

  Future<void> _openImportScreen() async {
    await Navigator.push<List<FeedItem>>(
      context,
      MaterialPageRoute(builder: (context) => const ImportScreen()),
    );
  }

  int get _selectedIndex {
    switch (_selectedTab) {
      case NavTab.feed:
        return 0;
      case NavTab.saved:
        return 1;
      case NavTab.library:
        return 2;
      case NavTab.profile:
        return 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B0F2A),
        body: SafeArea(
          child: Center(
            child: Text(
              'No authenticated user found.',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ),
        ),
      );
    }

    return StreamBuilder<List<FeedItem>>(
      stream: _feedController.streamFeedItems(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Color(0xFF0B0F2A),
            body: SafeArea(child: Center(child: CircularProgressIndicator())),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: const Color(0xFF0B0F2A),
            body: SafeArea(
              child: Center(
                child: Text(
                  'Failed to load feed: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final items = snapshot.data ?? [];

        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              FeedScreen(
                items: items,
                controller: _feedController,
                onUpdate: () {},
              ),
              SavedScreen(
                items: items,
                controller: _feedController,
                onUpdate: () {},
              ),
              const LibraryScreen(),
              const ProfileScreen(),
            ],
          ),
          bottomNavigationBar: CustomBottomNavBar(
            selectedTab: _selectedTab,
            onFeedTap: () => _selectTab(NavTab.feed),
            onSavedTap: () => _selectTab(NavTab.saved),
            onLibraryTap: () => _selectTab(NavTab.library),
            onProfileTap: () => _selectTab(NavTab.profile),
            onImportTap: _openImportScreen,
          ),
        );
      },
    );
  }
}
