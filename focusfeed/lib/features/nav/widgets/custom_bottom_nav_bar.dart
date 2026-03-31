import 'package:flutter/material.dart';
import 'package:focusfeed/features/nav/nav_tab.dart';
import 'import_fab_button.dart';
import 'nav_item.dart';

class CustomBottomNavBar extends StatelessWidget {
  final NavTab selectedTab;
  final VoidCallback onFeedTap;
  final VoidCallback onSavedTap;
  final VoidCallback onLibraryTap;
  final VoidCallback onProfileTap;
  final VoidCallback onImportTap;

  const CustomBottomNavBar({
    super.key,
    required this.selectedTab,
    required this.onFeedTap,
    required this.onSavedTap,
    required this.onLibraryTap,
    required this.onProfileTap,
    required this.onImportTap,
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
                  child: NavItem(
                    icon: Icons.home,
                    label: 'Feed',
                    isSelected: selectedTab == NavTab.feed,
                    onTap: onFeedTap,
                  ),
                ),
                Expanded(
                  child: NavItem(
                    icon: Icons.bookmark,
                    label: 'Saved',
                    isSelected: selectedTab == NavTab.saved,
                    onTap: onSavedTap,
                  ),
                ),
                const SizedBox(width: 72),
                Expanded(
                  child: NavItem(
                    icon: Icons.folder,
                    label: 'Library',
                    isSelected: selectedTab == NavTab.library,
                    onTap: onLibraryTap,
                  ),
                ),
                Expanded(
                  child: NavItem(
                    icon: Icons.person_outline,
                    label: 'Profile',
                    isSelected: selectedTab == NavTab.profile,
                    onTap: onProfileTap,
                  ),
                ),
              ],
            ),
            Positioned(top: -18, child: ImportFabButton(onTap: onImportTap)),
          ],
        ),
      ),
    );
  }
}