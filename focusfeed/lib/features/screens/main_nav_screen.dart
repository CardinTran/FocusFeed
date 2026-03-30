import 'package:flutter/material.dart';
import 'package:focusfeed/features/screens/feed_item.dart';
import 'package:focusfeed/features/screens/feed_screen.dart';
import 'package:focusfeed/features/screens/import_screen.dart';
import 'package:focusfeed/features/screens/saved_screen.dart';
import 'package:focusfeed/features/screens/settings/settings_screen.dart';
import 'package:focusfeed/features/screens/library_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _selectedIndex = 0;

  final List<FeedItem> _items = [
    FeedItem(
      title: "Poo Poo Pee Pee",
      description: "Restroom Time",
      category: "Flash",
      categoryColor: const Color.fromRGBO(133, 90, 251, 1),
      categoryBg: const Color(0xFF2D2060),
    ),
    FeedItem(
      title: "YERDDDD",
      description: "YUHHHHHH",
      category: "Quiz",
      categoryColor: Colors.redAccent,
      categoryBg: const Color(0xFF3D1515),
    ),
    FeedItem(
      title: "GYMMMM",
      description: "LEARN THE WAYS OF THE BIG BACK",
      category: "Learn",
      categoryColor: Colors.tealAccent,
      categoryBg: const Color(0xFF0D2E2A),
    ),
  ];

  void _refresh() {
    setState(() {});
  }

  void _openImportScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ImportScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      FeedScreen(items: _items, onUpdate: _refresh),
      SavedScreen(items: _items, onUpdate: _refresh),
      const LibraryScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: _CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onFeedTap: () => setState(() => _selectedIndex = 0),
        onSavedTap: () => setState(() => _selectedIndex = 1),
        onLibraryTap: () => setState(() => _selectedIndex = 2),
        onImportTap: _openImportScreen,
        onSettingsTap: () => setState(() => _selectedIndex = 3),
      ),
    );
  }
}

class _CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final VoidCallback onFeedTap;
  final VoidCallback onSavedTap;
  final VoidCallback onImportTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onLibraryTap;

  const _CustomBottomNavBar({
    required this.selectedIndex,
    required this.onFeedTap,
    required this.onSavedTap,
    required this.onImportTap,
    required this.onSettingsTap,
    required this.onLibraryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      decoration: const BoxDecoration(
        color: Color(0xFF12182F),
        border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Row(
              children: [
                Expanded(
                  child: _NavItem(
                    icon: Icons.home,
                    label: 'Feed',
                    isSelected: selectedIndex == 0,
                    onTap: onFeedTap,
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.bookmark,
                    label: 'Saved',
                    isSelected: selectedIndex == 1,
                    onTap: onSavedTap,
                  ),
                ),
                const SizedBox(width: 72),
                Expanded(
                  child: _NavItem(
                    icon: Icons.view_stream,
                    label: 'Decks',
                    isSelected: selectedIndex == 2,
                    onTap: onLibraryTap,
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.person,
                    label: 'Profile',
                    isSelected: selectedIndex == 3,
                    onTap: onSettingsTap,
                  ),
                ),
              ],
            ),
            Positioned(
              top: -18,
              child: GestureDetector(
                onTap: onImportTap,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromRGBO(133, 90, 251, 1),
                        Color(0xFFA78BFA),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: const Color(0xFF12182F),
                      width: 6,
                    ),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 34),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? const Color.fromRGBO(133, 90, 251, 1)
        : Colors.white60;

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
