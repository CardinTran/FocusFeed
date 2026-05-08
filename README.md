# FocusFeed

**Replace the Scroll. Reclaim Your Time.**

## Project Deliverables

- **Project Name:** FocusFeed
- **Team Number:** `TODO: add team number`
- **Repository:** https://github.com/CardinTran/FocusFeed
- **Deployed Project:** `TODO: add deployed app/store/testflight/web link or clearly state "not deployed"`

### Team Members

| Role | Name | GitHub Username |
|------|------|-----------------|
| Software Architect | Trinh | `TODO` |
| Scrum Master | Cardin | [@CardinTran](https://github.com/CardinTran) |
| UI/UX Designer | Luc | `TODO` |
| Senior Developer | Renee | `TODO` |
| Product Tester | Austin | `TODO` |

### Required Project Links

- **Kanban Board:** [GitHub Project Board](https://github.com/users/CardinTran/projects/4)
- **Designs:** `TODO: add Figma / wireframe / mockup link`
- **Code Standards:** [focusfeed/analysis_options.yaml](/Users/cardintran/Documents/GitHub/FocusFeed/focusfeed/analysis_options.yaml)
- **Git Workflow / Branch Naming:** See the `Git Workflow` section in this README

### Description

FocusFeed is a mobile app that replaces social media doomscrolling with productive learning. Instead of blocking TikTok or Instagram, it gives college students a TikTok-style swipeable feed of flashcards, quizzes, and micro-explainers pulled from their own coursework. The core insight is to redirect the same swipe habit toward study content instead of trying to block the behavior completely.

> "Duolingo proved learning can be addictive. Anki proved spaced repetition works. One Sec proved you can intervene at temptation. FocusFeed combines all three — but for your actual coursework."

### Platforms Known To Work

- **Development environment used by this repo:** macOS
- **Primary run targets documented in this README:** Chrome, Android Emulator, iOS Simulator
- **Flutter platform folders included in the repo:** Android, iOS, macOS, Web, Linux, Windows

If you are grading the project and want the simplest path, use **Chrome** or an **Android Emulator** after completing the setup steps below.

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

## Software Requirements

Install the following free/community tools before trying to run the project:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `3.11.x or newer`
- [Dart SDK](https://dart.dev/get-dart) `^3.11.0` (installed with Flutter)
- [Git](https://git-scm.com/downloads)
- [Android Studio](https://developer.android.com/studio) Community Edition
- [Xcode](https://developer.apple.com/xcode/) if running iOS on macOS
- [Firebase CLI](https://firebase.google.com/docs/cli) if you need to reconfigure Firebase locally

Recommended IDE options:

- **Android Studio**
  - Flutter plugin
  - Dart plugin
- **VS Code**
  - Flutter extension
  - Dart extension

Verify your toolchain:

```bash
flutter doctor
```

If `flutter doctor` reports missing platform dependencies, fix those before continuing.

---

## Dependency Versions

### App Dependencies

These versions come from [`focusfeed/pubspec.yaml`](/Users/cardintran/Documents/GitHub/FocusFeed/focusfeed/pubspec.yaml) and the currently locked packages in [`focusfeed/pubspec.lock`](/Users/cardintran/Documents/GitHub/FocusFeed/focusfeed/pubspec.lock).

| Dependency | Version |
|-----------|---------|
| Flutter SDK | `3.11.x+` |
| Dart SDK | `^3.11.0` |
| cupertino_icons | `1.0.9` |
| firebase_core | `4.7.0` |
| firebase_auth | `6.4.0` |
| cloud_firestore | `6.3.0` |
| google_sign_in | `7.2.0` |
| sign_in_with_apple | `8.0.0` |
| file_picker | `11.0.2` |
| image_picker | `1.2.1` |
| google_mlkit_text_recognition | `0.15.1` |
| image_cropper | `12.2.1` |
| profanity_filter | `2.0.0` |
| flutter_lints | `6.0.0` |
| flutter_launcher_icons | `0.14.3` |
| fake_cloud_firestore | `4.1.0+1` |

### Backend Services

- Firebase Authentication
- Cloud Firestore

### Repository Configuration Files

- Flutter app config: [`focusfeed/pubspec.yaml`](/Users/cardintran/Documents/GitHub/FocusFeed/focusfeed/pubspec.yaml)
- Firebase app mapping: [`focusfeed/firebase.json`](/Users/cardintran/Documents/GitHub/FocusFeed/focusfeed/firebase.json)
- Generated FlutterFire options: [`focusfeed/lib/firebase_options.dart`](/Users/cardintran/Documents/GitHub/FocusFeed/focusfeed/lib/firebase_options.dart)

---

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/CardinTran/FocusFeed.git
cd FocusFeed
cd focusfeed
```

### 2. Download dependencies

Run this from the `focusfeed/` directory:

```bash
flutter pub get
```

### 3. Confirm Flutter can see your devices

```bash
flutter devices
```

### 4. Firebase configuration

This project uses Firebase for login and stored app data.

Files already present in the repository:

- `focusfeed/android/app/google-services.json`
- `focusfeed/lib/firebase_options.dart`
- `focusfeed/firebase.json`

Platform note:

- **Android / Web / macOS / Windows:** Firebase options are already represented in `firebase_options.dart`
- **iOS:** If `ios/Runner/GoogleService-Info.plist` is not available in your local checkout, you will need the team's Firebase iOS plist or your own Firebase project configuration before iOS builds will run successfully

If you need to connect the app to your own Firebase project, use:

```bash
firebase login
dart pub global activate flutterfire_cli
flutterfire configure
```

After reconfiguring Firebase, run:

```bash
flutter pub get
```

### 5. Recommended grading path

For the lowest-friction setup, use one of these:

1. **Chrome**
2. **Android Emulator**
3. **iOS Simulator** on macOS with Xcode installed

---

## Running the Project From Source

All commands below are run from the `focusfeed/` directory.

### Option A: Run in Chrome

```bash
flutter config --enable-web
flutter run -d chrome
```

### Option B: Run in an Android Emulator

1. Open Android Studio
2. Open **Device Manager**
3. Start an emulator
4. Confirm it appears in `flutter devices`
5. Run:

```bash
flutter run -d emulator-5554
```

If your emulator ID is different, replace `emulator-5554` with the ID shown by `flutter devices`.

### Option C: Run in an iOS Simulator

1. Open Xcode once so it can finish installing required components
2. Open the iOS Simulator
3. Confirm it appears in `flutter devices`
4. Run:

```bash
flutter run -d iPhone
```

If Flutter reports that no iOS device is available, start a simulator manually and rerun `flutter devices`.

### Generic Flutter run commands

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

### Helpful cleanup commands

If dependency resolution or build caching causes issues:

```bash
flutter clean
flutter pub get
```

---

## Testing

Run automated tests from the `focusfeed/` directory:

```bash
flutter test
```

Run a single test file:

```bash
flutter test test/widget_test.dart
flutter test test/signup_test.dart
flutter test test/create_account_screen_test.dart
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
