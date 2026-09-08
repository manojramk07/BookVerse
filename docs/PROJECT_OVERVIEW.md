# BookVerse - Project Overview

## 1. Executive Summary

**BookVerse** is a modern, lightweight mobile digital reading and personal library application built with Flutter. It is designed to provide book enthusiasts, casual readers, and students with an elegant, distraction-free environment to discover books, manage personal reading collections, track reading goals, and read digital book content on mobile devices.

---

## 2. Purpose & Vision

The core mission of BookVerse is to make mobile reading delightful, accessible, and organized:
* **Frictionless Book Discovery:** Present readers with curated selections, popular titles, personalized recommendations, and instant search across titles and authors.
* **Personal Library Management:** Allow readers to categorize their books into active reading lists, favorites, completed titles, and saved bookmarks.
* **Goal & Progress Tracking:** Keep readers motivated with reading goals, percentage-based progress tracking, and reader statistics.
* **Clean Reading Experience:** Deliver a clean, legible e-reading interface with chapter navigation, typography tailored for readability, and instant bookmarking.

---

## 3. Target Audience

* **Avid Readers & Book Lovers:** Users who read multiple books simultaneously and want to organize their favorites and reading history.
* **Self-Improvement & Habit Builders:** Individuals tracking annual reading goals and daily reading streaks.
* **Students & Casual Readers:** Users looking for a simple, fast mobile reader without bloated interfaces or subscription barriers.

---

## 4. Current State of the Project

The BookVerse project is currently in an **early working prototype (UI & Mock Data)** stage:
* The core Flutter project structure is initialized with Dart 3.x and Material 3 design tokens.
* Bottom navigation with 4 primary tabs (Home, Library, Search, Profile) is functional using an `IndexedStack`.
* Book details and reading reader screens are implemented and navigate smoothly.
* All screens utilize in-memory static mock data (`sampleBooks` in `lib/models/book_model.dart`).
* No third-party state management or local database is currently connected; mutations (such as favoriting or bookmarking) are transient and local to the active widget.

---

## 5. Summary of Features

### 5.1 Current Implemented Features
* **4-Tab Bottom Navigation Bar:** Seamless switching between Home, Library, Search, and Profile with persistent tab state via `IndexedStack`.
* **Home Screen:**
  * Greeting header with user notification trigger.
  * Search bar container.
  * "Continue Reading" horizontal book carousel with visual progress indicators.
  * "Popular Books" horizontal ranking list with numerical rank badges and star ratings.
  * "Recommended Books" vertical listing with category tags.
  * "Popular Categories" chip grid (Fiction, Science, History, Romance, Fantasy, Technology).
* **Library Screen:**
  * Categorized views for *Currently Reading*, *Favorites*, *Completed*, and *Saved Books*.
  * Progress percentage bars on book tiles.
* **Search Screen:**
  * Real-time search query filtering by title and author.
  * Empty state feedback when no matching records are found.
  * Direct navigation to book details from search results.
* **Profile Screen:**
  * Reader avatar, display name, and email.
  * Reading metrics counter (Books Read, Currently Reading, Favorites).
  * Annual Reading Goal card with progress bar (e.g., 7 of 12 books complete).
  * Settings and utility options (Edit Profile, Settings, Saved Books, Help & Support, Logout).
* **Book Details Screen:**
  * Dynamic accent-colored book cover presentation.
  * Metadata display (Title, Author, Rating, Category badge).
  * Book synopsis/description.
  * "Read Now" action button leading to reading reader.
  * Favorite toggle and "Add to Library" action.
* **Reading Screen:**
  * Book title in app bar with interactive bookmark toggle.
  * Chapter header banner.
  * Reading progress bar.
  * Scrollable chapter reading body text.

### 5.2 Planned & Future Features
* **State Management & Data Synchronization:** Centralized reactive state store (e.g., `ChangeNotifier` / Provider) so updating favorite status or reading progress reflects across Home, Library, Details, and Profile instantly.
* **Persistent Local Storage:** Offline persistence via `shared_preferences` / SQLite / Hive / Isar for bookmarks, custom notes, library shelves, and reading progress.
* **Real Book Covers & Media Support:** Support for asset images and cached network images alongside color-based vector covers.
* **Enhanced Reading Controls:** Font size adjustments, theme switching (Light / Dark / Sepia / OLED Black), line height controls, and page-turn / scroll modes.
* **Interactive Search Navigation:** Linking the Home screen search bar directly to the Search tab with pre-filled queries.
* **Dynamic Profile Management:** Editable profile details, dynamic calculation of reading statistics from actual library state, and custom goal settings.

---

## 6. Main User Experience (User Journey)

```
[ Launch App ]
      │
      ▼
[ Main Screen (IndexedStack) ]
      │
      ├──► [ Home Tab ] ──────────► Tap Book ──────────┐
      │                                                │
      ├──► [ Library Tab ] ───────► Tap Book ──────────┤
      │                                                │
      ├──► [ Search Tab ] ────────► Tap Book ──────────┼──► [ Book Details ]
      │                                                │           │
      └──► [ Profile Tab ]                             │           ▼
                                                       └───► [ Read Now ] ──► [ Reading Screen ]
```

1. **Launch & Discovery:** The user opens the app into the Home screen, reviewing current reading progress and discovering trending titles.
2. **Browsing & Search:** The user switches to Search to filter titles by keyword or author, or visits Library to pick up saved or favorite books.
3. **Detail Inspection:** Tapping any book card opens the comprehensive Book Details view with synopsis, rating, and category.
4. **Active Reading:** Tapping "Read Now" launches the reading view, where progress is displayed, content is read, and the chapter can be bookmarked.
5. **Profile & Goals:** The user checks their annual reading goal, completed book count, and manages application settings via the Profile tab.
