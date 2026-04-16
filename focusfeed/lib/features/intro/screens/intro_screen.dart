import 'package:flutter/material.dart';
import 'package:focusfeed/core/theme/app_colors.dart';
import 'package:focusfeed/features/auth/screens/app_entry_screen.dart';
import '../widgets/slide_scroll_mockup.dart';
import '../widgets/slide_card_grid.dart';
import '../widgets/slide_ai_import.dart';
import '../widgets/slide_friends.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  static const _totalPages = 4;

  void _next() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AppEntryScreen()),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildDots() => Positioned(
        bottom: 110,
        left: 0,
        right: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _totalPages,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == _currentPage ? 24 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == _currentPage ? AppColors.purple : Colors.white24,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      );

  Widget _buildCTAButton() => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: _next,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _currentPage == _totalPages - 1 ? 'Get Started' : 'Next',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentPage = i),
              children: const [
                SlideScrollMockup(),
                SlideCardGrid(),
                SlideAIImport(),
                SlideFriends(),
              ],
            ),
            _buildDots(),
            _buildCTAButton(),
          ],
        ),
      ),
    );
  }
}
