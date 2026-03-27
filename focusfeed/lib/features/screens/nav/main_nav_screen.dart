import 'package:flutter/material.dart';
import 'package:focusfeed/features/screens/feed/feed_item.dart';
import 'package:focusfeed/features/screens/feed/feed_screen.dart';
import 'package:focusfeed/features/screens/import/import_screen.dart';
import 'package:focusfeed/features/screens/library/library_screen.dart';
import 'package:focusfeed/features/screens/nav/nav_tab.dart';
import 'package:focusfeed/features/screens/nav/widgets/custom_bottom_nav_bar.dart';
import 'package:focusfeed/features/screens/saved/saved_screen.dart';
import 'package:focusfeed/features/screens/settings/settings_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  NavTab _selectedTab = NavTab.feed;

  final List<FeedItem> _items = [
    FeedItem.flashcard(
      category: "Bathroom",
      categoryColor: const Color(0xFF7B61FF),
      categoryBg: const Color(0x337B61FF),
      deckTitle: "FLASHCARD",
      question: "Poo Poo Pee Pee?",
      answer: "Restroom Time",
      deckIcon: Icons.layers_outlined,
    ),
    FeedItem.flashcard(
      category: "Funny",
      categoryColor: const Color(0xFFFF9F6E),
      categoryBg: const Color(0x33FF9F6E),
      deckTitle: "FLASHCARD",
      question: "YERDDDD",
      answer: "YUHHHHHH",
      deckIcon: Icons.layers_outlined,
    ),
    FeedItem.flashcard(
      category: "Gym",
      categoryColor: const Color(0xFFFF6B81),
      categoryBg: const Color(0x33FF6B81),
      deckTitle: "FLASHCARD",
      question: "GYMMMM",
      answer: "LEARN THE WAYS OF THE BIG BACK",
      deckIcon: Icons.layers_outlined,
    ),
  ];

  void _refresh() {
    setState(() {});
  }

  void _selectTab(NavTab tab) {
    setState(() {
      _selectedTab = tab;
    });
  }

  Future<void> _openImportScreen() async {
    final importedItems = await Navigator.push<List<FeedItem>>(
      context,
      MaterialPageRoute(builder: (context) => const ImportScreen()),
    );

    if (!mounted) return;

    if (importedItems != null && importedItems.isNotEmpty) {
      setState(() {
        _items.addAll(importedItems);
      });
    }
  }

  Widget _buildCurrentScreen() {
    switch (_selectedTab) {
      case NavTab.feed:
        return FeedScreen(items: _items, onUpdate: _refresh);
      case NavTab.saved:
        return SavedScreen(items: _items, onUpdate: _refresh);
      case NavTab.library:
        return const LibraryScreen();
      case NavTab.settings:
        return const SettingsScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildCurrentScreen(),
      bottomNavigationBar: CustomBottomNavBar(
        selectedTab: _selectedTab,
        onFeedTap: () => _selectTab(NavTab.feed),
        onSavedTap: () => _selectTab(NavTab.saved),
        onLibraryTap: () => _selectTab(NavTab.library),
        onSettingsTap: () => _selectTab(NavTab.settings),
        onImportTap: _openImportScreen,
      ),
    );
  }
}
