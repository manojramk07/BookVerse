# BookVerse - Comprehensive Development Roadmap

This document outlines the phased engineering roadmap for building, refining, and releasing the **BookVerse** Flutter application.

---

## Roadmap Overview

```
Phase 1: Foundation
   │
   ▼
Phase 2: Main Navigation
   │
   ▼
Phase 3: Home Experience
   │
   ▼
Phase 4: Library Management
   │
   ▼
Phase 5: Search & Discovery
   │
   ▼
Phase 6: Profile & Stats
   │
   ▼
Phase 7: Book Details
   │
   ▼
Phase 8: Reading Experience
   │
   ▼
Phase 9: Local Data Persistence
   │
   ▼
Phase 10: Testing & Polishing
   │
   ▼
Phase 11: Release & Deployment
```

---

## Phase 1: Foundation

* **Goal:** Establish a robust project foundation, clean up configuration warnings/deprecations, normalize naming conventions, and prepare state scaffolding.
* **Features:**
  * Fix deprecated `withOpacity` call in `lib/screens/book_details_page.dart` using `.withValues(alpha: 0.35)`.
  * Refactor top-level function `sectionTitle` in `lib/widgets/section_title.dart` to a clean `StatelessWidget` (`SectionTitle`).
  * Verify `pubspec.yaml` package configuration and app metadata.
  * Verify clean `flutter analyze` with 0 issues.
* **Files Likely to be Changed:**
  * `lib/screens/book_details_page.dart`
  * `lib/widgets/section_title.dart`
  * `lib/screens/home/home_page.dart` (import and call site for SectionTitle)
  * `pubspec.yaml`
* **Dependencies Required:** None (Core Flutter SDK).
* **Testing Requirements:** Run `flutter analyze` to ensure 0 lint errors, verify debug build compiles cleanly on Android emulator/device.

---

## Phase 2: Main Navigation

* **Goal:** Ensure smooth, persistent bottom navigation with clear visual indicators and deep navigation support.
* **Features:**
  * Verify `IndexedStack` maintains tab state without memory leaks.
  * Ensure accessibility labels on `NavigationDestination` items (Home, Library, Search, Profile).
  * Add programmatic tab switching capability (e.g., allow Home search bar tap to switch directly to Search tab index `2`).
* **Files Likely to be Changed:**
  * `lib/screens/main_screen.dart`
  * `lib/screens/home/home_page.dart`
* **Dependencies Required:** None.
* **Testing Requirements:** Verify tab switching on tap, ensure scroll position in Home and Library is preserved when toggling tabs.

---

## Phase 3: Home Experience

* **Goal:** Create an engaging, high-performance home digital library experience with curated feeds and category browsing.
* **Features:**
  * Connect Home search bar tap to trigger search navigation.
  * Implement dynamic "Continue Reading" cards with progress percentage badges.
  * Implement "Popular Books" horizontal feed with rank chips and ratings.
  * Implement "Recommended Books" list with category tags.
  * Make category chips interactive with visual selection states or category routing.
* **Files Likely to be Changed:**
  * `lib/screens/home/home_page.dart`
  * `lib/widgets/book_card.dart`
  * `lib/widgets/popular_book_card.dart`
  * `lib/widgets/recently_added_book.dart`
  * `lib/widgets/category_chip.dart`
* **Dependencies Required:** None.
* **Testing Requirements:** Test horizontal and vertical scrolling behavior, card tap responses, and navigation transitions to details screen.

---

## Phase 4: Library Management

* **Goal:** Provide intuitive organization of user reading materials into distinct shelves with real-time status updates.
* **Features:**
  * Organize library into clear sections: "Currently Reading", "Favorites", "Completed", and "Saved Books".
  * Add empty state illustrations/placeholders when a section has no books.
  * Display clear progress percentage indicators on reading items.
  * Provide quick action buttons (e.g., mark as completed, remove from saved).
* **Files Likely to be Changed:**
  * `lib/screens/library/library_page.dart`
  * `lib/widgets/library_book.dart`
* **Dependencies Required:** None.
* **Testing Requirements:** Validate list rendering with zero, one, and multiple items across all 4 library categories.

---

## Phase 5: Search & Discovery

* **Goal:** Deliver instant, frictionless book discovery with live filtering and informative feedback.
* **Features:**
  * Real-time search query matching across book titles and authors.
  * Clear query action button `(X)` inside search input field.
  * Formatted search result tiles with cover thumbnail, title, author, and category.
  * Friendly, clean empty state when no matching results are found.
* **Files Likely to be Changed:**
  * `lib/screens/search/search_page.dart`
* **Dependencies Required:** None.
* **Testing Requirements:** Test case-insensitive search queries, special characters, whitespace trimming, and empty state display.

---

## Phase 6: Profile & Reader Stats

* **Goal:** Display personalized reader progress, reading statistics, and annual goal tracking.
* **Features:**
  * Present reader avatar, name, and email.
  * Dynamic statistics calculation reflecting total books read, currently reading count, and favorite count.
  * Annual reading goal visual progress bar with completed book milestones.
  * Interactive settings options (Edit Profile, App Settings, Help & Support, Logout) with feedback dialogs/snackbars.
* **Files Likely to be Changed:**
  * `lib/screens/profile/profile_page.dart`
  * `lib/widgets/profile_stat.dart`
  * `lib/widgets/profile_option.dart`
* **Dependencies Required:** None.
* **Testing Requirements:** Validate statistics display math, progress bar boundary clamping (`0.0` to `1.0`), and action item tap callbacks.

---

## Phase 7: Book Details

* **Goal:** Present an immersive, informative book overview with clear call-to-actions.
* **Features:**
  * Prominent book cover with rounded corners and dynamic accent glow.
  * Book title, author name, rating stars, and category badge.
  * Formatted book description/synopsis with readable typography.
  * "Read Now" primary launcher button.
  * Interactive Favorite heart toggle and "Add to Library" button.
* **Files Likely to be Changed:**
  * `lib/screens/book_details_page.dart`
* **Dependencies Required:** None.
* **Testing Requirements:** Verify navigation push and pop transitions, toggle state animations, and argument passing to reading view.

---

## Phase 8: Reading Experience

* **Goal:** Deliver a comfortable, distraction-free reading reader.
* **Features:**
  * App bar displaying book title and interactive bookmark toggle.
  * Chapter header badge with icon and chapter title.
  * Reader progress indicator.
  * Scrollable chapter text content with optimal font sizing (`18px`) and line height (`1.8`).
  * Back navigation returning smoothly to details.
* **Files Likely to be Changed:**
  * `lib/screens/reading_page.dart`
* **Dependencies Required:** None.
* **Testing Requirements:** Test scroll performance, long-text rendering, and bookmark state toggling.

---

## Phase 9: Local Data Persistence & Reactive State

* **Goal:** Ensure all user actions (favorites, library additions, reading progress, bookmarks, goals) persist offline across app restarts.
* **Features:**
  * Create a lightweight reactive state repository (`BookRepository` or `ChangeNotifier`).
  * Persist bookmarks, favorite IDs, reading progress, and custom settings using `shared_preferences` (or lightweight SQLite/Hive).
  * Auto-save reading position on scroll or screen exit.
* **Files Likely to be Changed:**
  * `lib/models/book_model.dart`
  * `lib/repositories/book_repository.dart` (new)
  * `lib/app.dart`
  * `pubspec.yaml`
* **Dependencies Required:** `shared_preferences` (only when persistence phase is explicitly initiated).
* **Testing Requirements:** Kill and restart app; verify modified favorites, progress, and bookmarks persist accurately.

---

## Phase 10: Testing and Polishing

* **Goal:** Guarantee app stability, smooth animations, accessibility, and zero lint warnings.
* **Features:**
  * Write unit tests for search query filtering and model serialization.
  * Write widget tests for navigation bar, book cards, and search page.
  * Profile UI frame rate (60/120 fps target) and memory usage.
  * Ensure consistent padding and responsive layout on varying Android screen densities.
* **Files Likely to be Changed:**
  * `test/widget_test.dart`
  * `test/unit/book_model_test.dart`
  * UI widgets across `lib/widgets/`
* **Dependencies Required:** `flutter_test`.
* **Testing Requirements:** Run `flutter test` with 100% test pass rate and `flutter analyze` with 0 warnings.

---

## Phase 11: Release & App Store Deployment

* **Goal:** Prepare production build artifacts for Android and iOS.
* **Features:**
  * Configure production app launcher icons and splash screens.
  * Set final application ID, version codes (`version: 1.0.0+1`), and signing keys in `android/app/build.gradle.kts`.
  * Update iOS display name and bundle identifiers in `ios/Runner/Info.plist`.
  * Build release APK / App Bundle (`flutter build appbundle`).
* **Files Likely to be Changed:**
  * `android/app/build.gradle.kts`
  * `ios/Runner/Info.plist`
  * `pubspec.yaml`
* **Dependencies Required:** None.
* **Testing Requirements:** Install and run release APK on physical Android device; verify startup performance and all core flows.
