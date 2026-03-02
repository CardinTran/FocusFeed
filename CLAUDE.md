# CLAUDE.md — FocusFeed Project Context

## What Is FocusFeed?

FocusFeed is a mobile app that replaces social media doomscrolling with productive learning. Instead of blocking TikTok/Instagram, it gives students a TikTok-style swipeable feed of flashcards, quizzes, and micro-explainers pulled from their own coursework. The core insight: redirect dopamine instead of fighting it.

**Tagline:** Replace the Scroll. Reclaim Your Time.
**Target users:** College students who lose study time to social media scrolling.
**Positioning:** "Duolingo proved learning can be addictive. Anki proved spaced repetition works. One Sec proved you can intervene at temptation. FocusFeed combines all three — but for your actual coursework."

---

## Tech Stack

| Layer | Technology | Notes |
|-------|-----------|-------|
| Frontend | **Flutter (Dart)** | Single codebase for iOS + Android |
| Backend | **Firebase** | Auth, Firestore, Cloud Functions. Free tier supports 500+ users |
| State Management | **Riverpod** | Preferred over Provider for testability and scalability |
| Routing | **GoRouter** | Standard Flutter navigation |
| Data Models | **Freezed + json_serializable** | Immutable models with serialization |
| AI (V2) | **OpenAI / Claude API** | Auto-generate flashcards from syllabi |
| Cloud Functions | **TypeScript** | Server-side logic for AI pipeline |
| Version Control | **Git + GitHub** | PRs required, never push directly to main |

---

## Team & Roles

| Role | Responsibility |
|------|---------------|
| **Software Architect (Trinh)** | System structure, data models, service layer, tech decisions, unblocking the team |
| **Scrum Master** | Sprint planning, backlog management, standups, removing blockers |
| **UI/UX Designer** | Figma wireframes and components, design system, screen flows |
| **Senior Developer** | Core UI implementation, swipe mechanics, feature development |
| **Product Tester / DevOps** | Testing, bug reporting, build management, Firebase monitoring |

---

## Project Structure

```
focusfeed/
├── lib/
│   ├── main.dart
│   ├── features/
│   │   ├── feed/              # Swipe feed, card rendering, feed algorithm
│   │   │   ├── models/
│   │   │   ├── screens/
│   │   │   ├── widgets/
│   │   │   ├── services/
│   │   │   └── providers/
│   │   ├── auth/              # Login, signup, Google Sign-In
│   │   │   ├── models/
│   │   │   ├── screens/
│   │   │   ├── services/
│   │   │   └── providers/
│   │   ├── decks/             # Deck management, card CRUD
│   │   │   ├── models/
│   │   │   ├── screens/
│   │   │   ├── widgets/
│   │   │   ├── services/
│   │   │   └── providers/
│   │   └── profile/           # Profile, stats, streaks, settings
│   │       ├── models/
│   │       ├── screens/
│   │       ├── widgets/
│   │       ├── services/
│   │       └── providers/
│   ├── core/                  # Shared utilities, theme, constants
│   │   ├── theme/
│   │   ├── constants/
│   │   ├── widgets/           # Shared components (buttons, inputs)
│   │   └── utils/
│   └── services/              # Top-level Firebase service abstractions
├── test/
├── integration_test/
├── android/
├── ios/
├── firebase/                  # Cloud Functions
├── docs/                      # Architecture decisions, design system
├── pubspec.yaml
└── README.md
```

**Architecture pattern:** Feature-first organization, not type-first. Each feature folder contains its own models, screens, widgets, services, and providers. This keeps related code together and reduces merge conflicts when teammates work in parallel.

---

## Data Models

### User
```dart
class AppUser {
  String uid;
  String displayName;
  String email;
  String? avatarUrl;
  int currentStreak;        // consecutive days studied
  int longestStreak;
  DateTime? lastStudiedDate;
  int totalCardsStudied;
  DateTime createdAt;
}
```

### Deck
```dart
class Deck {
  String id;
  String userId;            // owner
  String name;
  String? description;
  String accentColor;       // hex color for the deck
  int cardCount;
  DateTime createdAt;
  DateTime? lastStudiedAt;
}
```

### Card (base with type variants)
```dart
enum CardType { flashcard, quiz, fillInBlank, explainer, progress, challenge }

class StudyCard {
  String id;
  String deckId;
  String userId;
  CardType type;
  Map<String, dynamic> content;  // type-specific content (see below)
  int repetitionLevel;           // spaced repetition: 0 = new, higher = more known
  DateTime? nextReviewDate;
  DateTime createdAt;
}
```

**Content schemas by card type:**
- **Flashcard:** `{ "front": "What is mitosis?", "back": "Cell division producing two identical daughter cells" }`
- **Quiz:** `{ "question": "Which organelle produces ATP?", "options": ["Nucleus", "Mitochondria", "Ribosome", "Golgi"], "correctIndex": 1 }`
- **Fill in Blank:** `{ "sentence": "The ___ is the powerhouse of the cell", "answer": "mitochondria" }`
- **Explainer:** `{ "title": "Mitosis vs Meiosis", "body": "Mitosis produces 2 identical cells. Meiosis produces 4 genetically unique cells. Mitosis is for growth; meiosis is for reproduction." }`

### StudySession
```dart
class StudySession {
  String id;
  String userId;
  int cardsStudied;
  int correctAnswers;
  Duration sessionLength;
  DateTime startedAt;
}
```

---

## Firestore Schema

```
users/{uid}
  - displayName, email, avatarUrl, currentStreak, longestStreak,
    lastStudiedDate, totalCardsStudied, createdAt

users/{uid}/decks/{deckId}
  - name, description, accentColor, cardCount, createdAt, lastStudiedAt

users/{uid}/decks/{deckId}/cards/{cardId}
  - type, content, repetitionLevel, nextReviewDate, createdAt

users/{uid}/sessions/{sessionId}
  - cardsStudied, correctAnswers, sessionLength, startedAt
```

**Design decision:** Subcollection approach (cards nested under decks under users). This naturally scopes data to the owning user and makes security rules straightforward. Tradeoff: querying cards across all decks requires a collection group query.

---

## Feed Algorithm

The feed is the heart of the product. Cards are selected and ordered using these rules:

1. **Pull due cards first** — cards where `nextReviewDate <= now` based on spaced repetition
2. **Mix card types unpredictably** — never show 3 of the same type in a row (variable reward schedule)
3. **Inject progress cards** — every 8-10 cards, insert a progress card showing session stats
4. **Weight by confidence** — cards rated "hard" appear 2x more frequently than "easy" cards
5. **Shuffle within priority tiers** — don't show cards in creation order

Start with a simple random shuffle + spaced repetition weighting for MVP. Make the algorithm a standalone service class so it can be swapped out for a smarter version later.

---

## Card Type Visual Identity

Each card type has a signature color. This color appears as a top accent bar on the card and in the card type label.

| Card Type | Color | Hex |
|-----------|-------|-----|
| Flashcard | Purple | `#6C5CE7` |
| Quick Quiz | Red/Coral | `#FF6B6B` |
| Fill in Blank | Gold | `#FDCB6E` |
| Micro-Explainer | Green | `#00B894` |
| Progress Card | Purple Light | `#A29BFE` |
| Challenge | Red/Coral | `#FF6B6B` |

---

## Design System (Quick Reference)

### Colors

| Name | Hex | Usage |
|------|-----|-------|
| Purple (primary) | `#6C5CE7` | Buttons, active states, links |
| Purple Light | `#A29BFE` | Secondary accent, hover states |
| Purple Background | `#1E1B4B` | Modal/onboarding backgrounds |
| Dark | `#0F0F23` | App background (dark mode) |
| Navy | `#1A1A3E` | Nav bar, secondary dark bg |
| Card Background | `#1E1E3A` | Card surfaces on dark bg |
| Off White | `#F8F9FC` | Light mode background |
| White | `#FFFFFF` | Card surfaces on light bg |
| Green | `#00B894` | Correct, success, "easy" |
| Red/Coral | `#FF6B6B` | Wrong, error, "hard" |
| Gold | `#FDCB6E` | Highlights, achievements, "medium" |
| Gray | `#94A3B8` | Secondary text (dark bg) |
| Gray Dark | `#64748B` | Secondary text (light bg) |
| Gray Light | `#E2E8F0` | Borders, dividers, disabled |

### Typography
- **Headings:** Inter Bold
- **Body:** Inter Regular
- Card question: 24px Bold
- Card body: 18px Regular
- Body text: 16px Regular
- Captions: 12px Regular

### Spacing
8px base grid: 4 / 8 / 16 / 24 / 32 / 48

### Corner Radius
Cards: 16px, Buttons: 12px, Inputs: 10px, Chips: 8px

### Icons
Lucide Icons — 24px, 1.5px stroke weight

---

## Key Packages

```yaml
dependencies:
  flutter_riverpod: ^2.x       # State management
  go_router: ^13.x              # Navigation
  firebase_core: ^2.x           # Firebase initialization
  firebase_auth: ^4.x           # Authentication
  cloud_firestore: ^4.x         # Database
  freezed_annotation: ^2.x      # Immutable data models
  json_annotation: ^4.x         # JSON serialization
  google_sign_in: ^6.x          # Google auth
  flutter_card_swiper: ^x.x     # Card swipe (evaluate vs custom PageView)
  lucide_icons: ^0.x            # Icon set

dev_dependencies:
  freezed: ^2.x                 # Code generation for models
  json_serializable: ^6.x       # Code generation for JSON
  build_runner: ^2.x            # Runs code generation
  flutter_test:                  # Testing
  integration_test:              # Integration testing
```

---

## Competitive Landscape

FocusFeed's differentiation across 4 dimensions no competitor covers all at once:

| Feature | Duolingo | Quizlet | Anki | Deepstash | ScrollEd | One Sec | **FocusFeed** |
|---------|----------|---------|------|-----------|----------|---------|---------------|
| Swipeable Feed | ✓ | ✗ | ✗ | ✓ | ✓ | ✗ | **✓** |
| Your Own Content | ✗ | ✓ | ✓ | ✗ | ✓ | ✗ | **✓** |
| Active Recall | ✓ | ✓ | ✓ | ✗ | ✗ | ✗ | **✓** |
| Habit Intercept | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | **✓** |

**Closest competitor:** ScrollEd — transforms documents into scrollable learning feeds. FocusFeed's advantage: active recall (quizzes, flashcards) vs just summaries, plus app interception.

**Biggest risk:** Content creation friction. Users need enough cards in their feed for it to feel like a scrollable experience. AI card generation (V2) is the critical feature to solve this.

---

## Science Behind the Design

Every design decision maps to established research:

- **Variable Reward Schedule** (B.F. Skinner) — Mixing card types unpredictably triggers sustained dopamine release, same mechanism as TikTok and slot machines
- **Active Recall** (Roediger & Karpicke, 2006) — Self-testing is 50% more effective than re-reading. Quizzes and flashcards force retrieval
- **Spaced Repetition** (Ebbinghaus) — Reviewing at increasing intervals fights the Forgetting Curve. Hard cards appear more often, easy cards fade back
- **Habit Stacking** (James Clear, Atomic Habits) — Attaching learning to the existing scroll urge is the most effective way to form new habits

---

## MVP Feature Scope

### In Scope (build these)
- Email + password auth with Google Sign-In
- First-time onboarding (2-3 swipeable intro cards)
- Swipeable full-screen card feed with mixed card types
- Flashcard (tap to flip), Quiz (4 options), Fill-in-Blank, Micro-Explainer
- Confidence rating (easy/medium/hard) after each card
- Progress card injected into feed
- Deck creation (name, color)
- Card creation (type-specific forms)
- Deck list and deck detail views
- Edit and delete cards/decks
- Streak tracking (daily counter)
- Profile screen with stats (streak, total cards studied, cards today)
- Empty states, loading states, error states
- Dark mode (default)
- Bottom navigation (Feed, My Decks, Profile)
- Settings (reminders toggle, dark/light mode, session length)

### Out of Scope (V2+)
- AI card generation from syllabi
- Quizlet/Anki import
- Social features (study groups, shared decks, leaderboards)
- App interception (Android UsageStats API)
- Challenge card type
- Creator marketplace
- B2B university features
- Streak calendar/heatmap (nice-to-have, defer if time-constrained)

---

## Roadmap

| Phase | What | Goal |
|-------|------|------|
| **MVP (Now)** | Swipeable feed, manual card creation, 4 card types, streaks | Prove the core loop |
| **V2 (Next)** | AI card generation, Quizlet import, notifications | Remove content friction |
| **V3 (Then)** | Social features, XP system, leaderboards, campus ambassadors | Drive retention & virality |
| **V4 (Vision)** | App interception, B2B university licenses, creator marketplace | Scale to platform |

---

## Build Order (Fastest Path)

1. **Firebase Auth** — email/password login screen (unblocks everything)
2. **Deck creation + My Decks screen** — validates Firestore CRUD works
3. **Card creation** — flashcard type only first, form with front/back
4. **Feed screen** — pull real cards from Firestore, display as swipeable cards
5. **Additional card types** — quiz, fill-in-blank, explainer (one at a time)
6. **Card type mixer** — randomize card types in the feed
7. **Confidence rating** — easy/medium/hard buttons, update spaced repetition data
8. **Streak tracking** — daily counter, display on feed and profile
9. **Profile screen** — stats, streak count, logout
10. **Onboarding flow** — 2-3 intro cards for first-time users
11. **Settings** — dark mode toggle, reminder time, session length
12. **Polish** — animations, empty states, error handling, loading skeletons

---

## Git Workflow

```bash
# Create feature branch
git checkout -b feat/card-swipe-feed

# Commit with descriptive message
git commit -m "feat: implement swipeable card feed with dummy data"

# Push and open PR
git push origin feat/card-swipe-feed
```

**Branch prefixes:** `feat/`, `fix/`, `test/`, `devops/`, `docs/`
**Never push directly to main.** All changes go through pull requests.

---

## Market Data (for reference)

- 20M+ US college students (primary market)
- EdTech market: $334B (2023) → $739B (2029), 14.1% CAGR
- Wellness apps market: $11.2B (2024) → $45.7B (2034), 15.1% CAGR
- College students average 8-10 hours daily screen time
- 90% of students multitask with social media during study
- App blockers only reduce usage by 6.2%
- 50% of new information forgotten within 1 hour without reinforcement
- Meta-analysis: -0.17 correlation between social media addiction and GPA

---

## Notes for Claude

When helping with this project:
- The app is dark-mode-first with the color palette above
- Use Riverpod for state management, not Provider or Bloc
- Use GoRouter for navigation
- Use Freezed for data models
- Feature-first folder structure, not type-first
- Firestore subcollection pattern: users/{uid}/decks/{deckId}/cards/{cardId}
- The feed algorithm should be a standalone service class, easily swappable
- Card types each have a signature color — this is a core UX pattern
- The swipe mechanic must feel smooth and satisfying — this is the #1 UX priority
- Trinh is the software architect leading a 5-person team
- This is a class project with a compressed timeline (~3 weeks for MVP)