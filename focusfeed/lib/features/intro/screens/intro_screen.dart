import 'package:flutter/material.dart';
import 'package:focusfeed/core/theme/app_colors.dart';
import 'package:focusfeed/features/auth/screens/app_entry_screen.dart';
import '../widgets/intro_widgets.dart';


// Main Screen
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
      _finish();
    }
  }

  void _finish() => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AppEntryScreen()),
      );

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
                _Slide1ScrollToLearn(),
                _Slide2CardTypes(),
                _Slide3AIImport(),
                _Slide4Friends(),
              ],
            ),
            Positioned(
              bottom: 110,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_totalPages, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _currentPage ? 24 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _currentPage ? AppColors.purple : Colors.white24,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
            Positioned(
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
            ),
          ],
        ),
      ),
    );
  }
}


// Shared slide shell
class _SlideShell extends StatelessWidget {
  final String tag;
  final String title;
  final String subtitle;
  final Widget content;

  const _SlideShell({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 120),
      child: Column(
        children: [
          Text(tag,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: AppColors.purpleLight)),
          const SizedBox(height: 10),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.2)),
          const SizedBox(height: 10),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.gray, height: 1.6)),
          const SizedBox(height: 24),
          Expanded(child: content),
        ],
      ),
    );
  }
}

// Animation mixin — shared across slides 2, 3, 4
mixin _FadeSlideAnim<T extends StatefulWidget>
    on State<T>, SingleTickerProviderStateMixin<T> {
  late AnimationController animController;

  void initAnim({Duration duration = const Duration(milliseconds: 600)}) {
    animController = AnimationController(vsync: this, duration: duration)
      ..forward();
  }

  Animation<double> staggered(double start, double end) => CurvedAnimation(
        parent: animController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      );

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }
}

// SLIDE 1 — Scroll to Learn
class _Slide1ScrollToLearn extends StatefulWidget {
  const _Slide1ScrollToLearn();

  @override
  State<_Slide1ScrollToLearn> createState() => _Slide1State();
}

class _Slide1State extends State<_Slide1ScrollToLearn>
    with SingleTickerProviderStateMixin {
  late AnimationController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SlideShell(
      tag: 'STUDY DIFFERENTLY',
      title: 'Learn like you scroll',
      subtitle:
          'Swipe through flashcards, quizzes, and\nexplainers — just like your feed.',
      content: Center(
        child: Container(
          width: 210,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          clipBehavior: Clip.hardEdge,
          child: AnimatedBuilder(
            animation: _scrollController,
            builder: (_, __) {
              final offset = _scrollController.value * 400;
              return Stack(
                children: [
                  MiniCard(
                    top: 0 - offset,
                    accent: AppColors.purple,
                    label: 'FLASHCARD',
                    labelIcon: Icons.credit_card,
                    question: 'What is photosynthesis?',
                    extra: const MiniFlipHint(),
                  ),
                  MiniCard(
                    top: 400 - offset,
                    accent: AppColors.redCoral,
                    label: 'QUICK QUIZ',
                    labelIcon: Icons.help_outline,
                    question: 'Which organelle produces ATP?',
                    extra: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MiniOption('A. Nucleus', false),
                        SizedBox(height: 4),
                        MiniOption('B. Mitochondria', false),
                        SizedBox(height: 4),
                        MiniOption('C. Ribosome', false),
                        SizedBox(height: 4),
                        MiniOption('D. Vacuole', false),
                      ],
                    ),
                  ),
                  MiniCard(
                    top: 800 - offset,
                    accent: AppColors.gold,
                    label: 'FILL IN BLANK',
                    labelIcon: Icons.edit_outlined,
                    question: "DNA is stored in the cell's _____.",
                    extra: const MiniFillInput(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// SLIDE 2 — Card Types
class _Slide2CardTypes extends StatefulWidget {
  const _Slide2CardTypes();

  @override
  State<_Slide2CardTypes> createState() => _Slide2State();
}

class _Slide2State extends State<_Slide2CardTypes>
    with SingleTickerProviderStateMixin, _FadeSlideAnim {
  static const _types = [
    ('🃏', 'Flashcard', 'Tap to flip. Classic active recall.', AppColors.purple),
    ('⚡', 'Quick Quiz', '4-option MCQ. Instant feedback.', AppColors.redCoral),
    ('✏️', 'Fill in Blank', 'Type the missing word or phrase.', AppColors.gold),
    ('💡', 'Explainer', 'Bite-sized concept breakdowns.', AppColors.green),
  ];

  @override
  void initState() {
    super.initState();
    initAnim();
  }

  @override
  Widget build(BuildContext context) {
    return _SlideShell(
      tag: '4 WAYS TO STUDY',
      title: 'Every style, one feed',
      subtitle: 'Mix and match study modes so you never get bored.',
      content: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(_types.length, (i) {
          final anim = staggered(i * 0.15, i * 0.15 + 0.5);
          return AnimatedBuilder(
            animation: anim,
            builder: (_, __) => Opacity(
              opacity: anim.value,
              child: Transform.translate(
                offset: Offset(0, 24 * (1 - anim.value)),
                child: TypeCard(
                  emoji: _types[i].$1,
                  name: _types[i].$2,
                  desc: _types[i].$3,
                  color: _types[i].$4,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// SLIDE 3 — AI Import
class _Slide3AIImport extends StatefulWidget {
  const _Slide3AIImport();

  @override
  State<_Slide3AIImport> createState() => _Slide3State();
}

class _Slide3State extends State<_Slide3AIImport>
    with SingleTickerProviderStateMixin, _FadeSlideAnim {
  static const _steps = [
    ('📄', AppColors.purple, 'Import your notes', 'Paste text, upload a doc, or type freehand'),
    ('✨', AppColors.gold, 'AI generates cards', 'Flashcards, quizzes & explainers auto-created'),
    ('🚀', AppColors.green, 'Start studying instantly', 'Edit, remix, or share your deck'),
  ];

  @override
  void initState() {
    super.initState();
    initAnim(duration: const Duration(milliseconds: 800));
  }

  @override
  Widget build(BuildContext context) {
    return _SlideShell(
      tag: 'INSTANT SETUP',
      title: 'Your notes → ready decks',
      subtitle: 'Paste your notes and AI generates an\nentire deck in seconds.',
      content: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Column(
              children: List.generate(_steps.length, (i) {
                final anim = staggered(i * 0.2, i * 0.2 + 0.5);
                return AnimatedBuilder(
                  animation: anim,
                  builder: (_, __) => Opacity(
                    opacity: anim.value,
                    child: Transform.translate(
                      offset: Offset(-16 * (1 - anim.value), 0),
                      child: Column(
                        children: [
                          AIStep(
                            emoji: _steps[i].$1,
                            color: _steps[i].$2,
                            label: _steps[i].$3,
                            sub: _steps[i].$4,
                          ),
                          if (i < _steps.length - 1)
                            const Divider(color: Colors.white10, height: 1),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: MethodCard(
                  emoji: '📚',
                  label: 'Build manually',
                  sub: 'Create cards one by one',
                  highlighted: false,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const MethodCard(
                      emoji: '🤖',
                      label: 'Generate with AI',
                      sub: 'Paste notes, done',
                      highlighted: true,
                    ),
                    Positioned(
                      top: -10,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                              color: AppColors.purple,
                              borderRadius: BorderRadius.circular(6)),
                          child: const Text('AI POWERED',
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// SLIDE 4 — Friends
class _Slide4Friends extends StatefulWidget {
  const _Slide4Friends();

  @override
  State<_Slide4Friends> createState() => _Slide4State();
}

class _Slide4State extends State<_Slide4Friends>
    with SingleTickerProviderStateMixin, _FadeSlideAnim {
  static const _friends = [
    ('JK', 'Jordan K.', AppColors.purple, AppColors.purpleLight),
    ('AM', 'Aisha M.', AppColors.green, Color(0xFF55EFC4)),
    ('TR', 'Tyler R.', AppColors.gold, Color(0xFFE17055)),
  ];

  @override
  void initState() {
    super.initState();
    initAnim(duration: const Duration(milliseconds: 700));
  }

  @override
  Widget build(BuildContext context) {
    return _SlideShell(
      tag: 'BETTER TOGETHER',
      title: 'Study with friends',
      subtitle: 'Share decks, challenge each other,\nand stay accountable.',
      content: Column(
        children: List.generate(_friends.length, (i) {
          final anim = staggered(i * 0.15, i * 0.15 + 0.5);
          return AnimatedBuilder(
            animation: anim,
            builder: (_, __) => Opacity(
              opacity: anim.value,
              child: Transform.scale(
                scale: 0.95 + 0.05 * anim.value,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: FriendRow(
                    initials: _friends[i].$1,
                    name: _friends[i].$2,
                    fromColor: _friends[i].$3,
                    toColor: _friends[i].$4,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}