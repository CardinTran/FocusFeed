# Git Conventions — FocusFeed

## Branch Naming

```
<prefix>/<short-description>
```

| Prefix | When to use |
|--------|-------------|
| `feat/` | New feature or screen |
| `fix/` | Bug fix |
| `test/` | Adding or updating tests |
| `devops/` | CI/CD, Firebase config, build tooling |
| `docs/` | Documentation only |
| `refactor/` | Code restructure with no behavior change |

**Examples:**
```
feat/swipe-feed-ui
fix/google-signin-ios
refactor/auth-service-riverpod
devops/firebase-app-distribution
```

---

## Commit Message Format

Follow the [Conventional Commits](https://www.conventionalcommits.org/) spec:

```
<type>(<scope>): <short summary>

[optional body]

[optional footer]
```

### Types

| Type | When to use |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Code change that is not a fix or feature |
| `test` | Adding or updating tests |
| `docs` | Documentation changes |
| `style` | Formatting, missing semicolons, etc. (no logic change) |
| `chore` | Dependency updates, build config, tooling |
| `perf` | Performance improvement |

### Scopes (optional but encouraged)

Use the feature folder name or layer:

```
auth, feed, decks, profile, core, services, models, firebase
```

### Rules

- Summary line: **50 characters max**, imperative mood ("add", not "added" or "adds")
- Body: wrap at 72 characters, explain *what and why*, not *how*
- No period at the end of the summary line

### Examples

```bash
# Simple
feat(auth): add Google Sign-In button to login screen

# With scope and body
fix(feed): prevent duplicate cards on fast swipe

Cards were being added to the seen set after the animation
completed. Move the seen-check to swipe initiation instead.

# Breaking change
feat(models)!: rename StudyCard.content to StudyCard.payload

BREAKING CHANGE: All Firestore documents must be migrated.
Run migration script in scripts/migrate_card_content.dart.

# Chore
chore: upgrade flutter_riverpod to 2.6.1
```

---

## Pull Request Format

### Title

Same format as a commit summary — `type(scope): short description`.

```
feat(feed): implement swipeable card feed with mixed card types
fix(auth): resolve Google Sign-In crash on iOS 17
```

### Body Template

```markdown
## What
<!-- One or two sentences describing what changed. -->

## Why
<!-- Why this change was needed — link to task, bug, or design decision. -->

## How to Test
- [ ] Step one
- [ ] Step two
- [ ] Edge case to verify

## Screenshots / Demo
<!-- Delete if not applicable. Attach screen recording for UI changes. -->

## Checklist
- [ ] No direct pushes to `main` — this is a PR
- [ ] Code follows Riverpod (not Provider/Bloc) pattern
- [ ] New screens use GoRouter for navigation
- [ ] Data models use Freezed
- [ ] Feature folder structure maintained (not type-first)
- [ ] Dark mode tested
- [ ] No debug prints or commented-out code left in
```

### PR Rules

- **Never push directly to `main`.** All changes go through PRs.
- Target `developer` for day-to-day work; target `main` only for release-ready merges.
- Keep PRs focused — one feature or fix per PR. If a PR touches more than 3 unrelated files, consider splitting it.
- Assign at least one reviewer before merging.
- Resolve all review comments before merging (or explicitly mark as "deferred to follow-up PR").
- Squash commits on merge for features; merge commit for release PRs so history is traceable.

