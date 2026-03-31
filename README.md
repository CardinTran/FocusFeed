# FocusFeed

**Replace the Scroll. Reclaim Your Time.**

FocusFeed is a mobile app that replaces social media doomscrolling with productive learning. Instead of blocking TikTok or Instagram, it gives college students a TikTok-style swipeable feed of flashcards, quizzes, and micro-explainers pulled from their own coursework. The core insight: redirect dopamine instead of fighting it.

> "Duolingo proved learning can be addictive. Anki proved spaced repetition works. One Sec proved you can intervene at temptation. FocusFeed combines all three — but for your actual coursework."

---

## Features

- **Swipeable Study Feed** — Full-screen cards you swipe through like a social feed
- **4 Card Types** — Flashcards, multiple-choice quizzes, fill-in-the-blank, and micro-explainers
- **Spaced Repetition** — Cards you struggle with appear more often; mastered cards fade back
- **Deck Management** — Create, edit, and organize your own study decks
- **Streak Tracking** — Daily study streaks to keep you accountable
- **Profile & Stats** — Track cards studied, accuracy, and session history
- **Auth** — Email/password and Google Sign-In via Firebase

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter (Dart) |
| Backend | Firebase (Auth + Firestore) |
| State Management | Riverpod |
| Routing | GoRouter |
| Auth Providers | Google Sign-In |

---

## Prerequisites

Before running FocusFeed locally, make sure you have the following installed:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (SDK `^3.11.0`)
- [Dart SDK](https://dart.dev/get-dart) (included with Flutter)
- [Firebase CLI](https://firebase.google.com/docs/cli) (for backend setup)
- Android Studio or Xcode (for emulators/simulators)
- A Firebase project with **Authentication** and **Firestore** enabled

---

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/CardinTran/FocusFeed.git
cd FocusFeed/focusfeed
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

This project uses Firebase. You'll need to add your own Firebase config files:

- **Android:** Place your `google-services.json` in `android/app/`
- **iOS:** Place your `GoogleService-Info.plist` in `ios/Runner/`

If you're setting up a new Firebase project:

```bash
firebase login
flutterfire configure
```

> Note: The existing `firebase.json` in this repo is pre-configured for the team's Firebase project. External contributors will need their own Firebase project.

### 4. Run the app

```bash
# List available devices
flutter devices

# Run on a specific device
flutter run -d <device-id>

# Run on iOS simulator
flutter run -d iPhone

# Run on Android emulator
flutter run -d emulator
```

---

## Project Structure

```
focusfeed/
├── lib/
│   ├── main.dart
│   ├── features/
│   │   ├── auth/          # Login, signup, Google Sign-In
│   │   ├── feed/          # Swipeable card feed
│   │   ├── library/       # Deck and card management
│   │   ├── profile/       # User profile and stats
│   │   ├── settings/      # App preferences
│   │   ├── saved/         # Saved cards
│   │   ├── import/        # Content import
│   │   └── nav/           # Bottom navigation
│   └── core/              # Shared theme, utilities, widgets
├── android/
├── ios/
├── firebase.json
└── pubspec.yaml
```

---

## Git Workflow

We follow a feature-branch workflow. **Never push directly to `main`.**

```bash
# Create a feature branch
git checkout -b feat/your-feature-name

# Commit your work
git commit -m "feat: describe what you built"

# Push and open a PR
git push origin feat/your-feature-name
```

**Branch prefixes:** `feat/`, `fix/`, `test/`, `devops/`, `docs/`

All changes go through pull requests and must be reviewed before merging.

---

## Task Management

We use a Kanban board to track all project work:
[GitHub Project Board](https://github.com/users/CardinTran/projects/4)

- Tasks are prioritized P0–P4 (P0 = highest priority / blocking)
- Self-select tasks you can actively work on
- Move cards across columns as status changes
- Communicate blockers early

---

## Team

| Role | Responsibility |
|------|---------------|
| Software Architect (Trinh) | System structure, data models, service layer, tech decisions |
| Scrum Master (Cardin) | Sprint planning, backlog, standups, removing blockers |
| UI/UX Designer (Luc) | Figma wireframes, design system, screen flows |
| Senior Developer (Renee) | Core UI, swipe mechanics, feature development |
| Product Tester (Austin) | Testing, bug reporting, builds, Firebase monitoring |
