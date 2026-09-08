# BookVerse - System Architecture Documentation

## 1. Overview

**BookVerse** is a cross-platform mobile application developed with Google Flutter and Dart 3. The architecture adheres to a clean, component-oriented, layered structure designed to maintain high readability, separation of concerns, and ease of onboarding for junior and intermediate Flutter developers.

---

## 2. Technology Stack & Dependencies

| Layer / Aspect | Technology / Package | Current Version / Detail |
|---|---|---|
| **Language** | Dart | `>=3.13.1 <4.0.0` (Null Safety Enabled) |
| **Framework** | Flutter Framework | Material 3 (`useMaterial3: true`) |
| **Linting & Analysis** | `flutter_lints` | `^6.0.0` |
| **State Management (Current)** | Ephemeral / Local Widget State | `StatefulWidget` / `setState` |
| **Data Layer (Current)** | In-Memory Static Repository | `final List<Book> sampleBooks` |
| **Target Platforms** | Android (Primary), iOS (Supported), Windows/Desktop (Tooling) | Min SDK: Flutter default, Target SDK: 34+ |

### Dependencies in `pubspec.yaml`
```yaml
dependencies:
  flutter:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```
*No external dependencies or third-party packages are currently installed.*

---

## 3. Directory & Folder Structure

### 3.1 Current Project Layout
```
my_app/
├── android/                   # Native Android configuration (Kotlin/Gradle)
│   └── app/src/main/
│       └── AndroidManifest.xml # android:label="BookVerse"
├── ios/                       # Native iOS configuration (Runner/Info.plist)
├── lib/                       # Main Flutter source code
│   ├── app.dart               # Root MaterialApp widget & theme configuration
│   ├── main.dart              # Main entry point (main() -> runApp(BookVerseApp))
│   ├── models/                # Domain models and static sample datasets
│   │   └── book_model.dart    # Book data class and sampleBooks list
│   ├── screens/               # Feature-specific page widgets
│   │   ├── book_details_page.dart  # Detailed synopsis, rating, actions
│   │   ├── home/
│   │   │   └── home_page.dart      # Welcome, continue reading, popular & recommended
│   │   ├── library/
│   │   │   └── library_page.dart   # Categorized book lists (Reading, Favs, Completed)
│   │   ├── main_screen.dart        # Scaffold with IndexedStack & NavigationBar
│   │   ├── profile/
│   │   │   └── profile_page.dart   # User stats, reading goals, action tiles
│   │   ├── reading_page.dart       # Active reading view with progress & text
│   │   └── search/
│   │       └── search_page.dart    # Live title/author search & filtered list
│   └── widgets/               # Reusable UI presentation components
│       ├── book_card.dart          # Horizontal card with progress indicator
│       ├── category_chip.dart      # Pill tag with icon and text
│       ├── library_book.dart       # List row item with progress percentage
│       ├── popular_book_card.dart  # Card with rank number (#1) and rating
│       ├── profile_option.dart     # List tile for profile settings actions
│       ├── profile_stat.dart       # Column displaying metric number and label
│       ├── recently_added_book.dart# Compact list item for recommendations
│       └── section_title.dart      # Header row with title and 'See All' button
├── pubspec.yaml               # Project dependencies and asset definitions
├── analysis_options.yaml      # Dart analyzer and linting rules
└── docs/                      # Architectural and operational project documentation
```

---

## 4. Key Files & Responsibilities

| File | Primary Responsibility |
|---|---|
| [`lib/main.dart`](file:///C:/Users/91739/App++/my_app/lib/main.dart) | Application bootstrapper. Invokes `runApp(const BookVerseApp())`. |
| [`lib/app.dart`](file:///C:/Users/91739/App++/my_app/lib/app.dart) | Sets up `MaterialApp`, enables `useMaterial3`, configures custom deep purple color palette, sets base background color (`#F8F7FC`), and renders `MainScreen`. |
| [`lib/screens/main_screen.dart`](file:///C:/Users/91739/App++/my_app/lib/screens/main_screen.dart) | Core navigation controller. Houses the 4 primary tabs inside an `IndexedStack` to preserve scroll positions and state across tab switches. |
| [`lib/models/book_model.dart`](file:///C:/Users/91739/App++/my_app/lib/models/book_model.dart) | Defines the immutable `Book` domain model and holds the pre-populated `sampleBooks` static dataset. |
| [`lib/screens/home/home_page.dart`](file:///C:/Users/91739/App++/my_app/lib/screens/home/home_page.dart) | Digital library showcase containing multiple categorized book feeds (Continue Reading, Popular, Recommended, Categories). |
| [`lib/screens/library/library_page.dart`](file:///C:/Users/91739/App++/my_app/lib/screens/library/library_page.dart) | Personal library dashboard filtering books by reading status, favorite status, and saved status. |
| [`lib/screens/search/search_page.dart`](file:///C:/Users/91739/App++/my_app/lib/screens/search/search_page.dart) | Real-time text search screen filtering book titles and authors. |
| [`lib/screens/profile/profile_page.dart`](file:///C:/Users/91739/App++/my_app/lib/screens/profile/profile_page.dart) | Reader metrics, reading goal progress, and utility menu options. |
| [`lib/screens/book_details_page.dart`](file:///C:/Users/91739/App++/my_app/lib/screens/book_details_page.dart) | Comprehensive view of an individual book with synopsis, rating, bookmark toggle, and reading launcher. |
| [`lib/screens/reading_page.dart`](file:///C:/Users/91739/App++/my_app/lib/screens/reading_page.dart) | Chapter reader displaying progress percentage and scrollable reading text. |

---

## 5. Navigation Architecture

BookVerse uses a two-tier navigation model:

1. **Root Tab Navigation (IndexedStack):**
   * Managed in `MainScreen` via Material 3 `NavigationBar`.
   * Displays 4 persistent destinations:
     * Destination 0: `HomePage`
     * Destination 1: `LibraryPage`
     * Destination 2: `SearchPage`
     * Destination 3: `ProfilePage`
   * `IndexedStack` maintains the widget subtree alive across switches, preventing rebuilds and preserving scroll state.

2. **Hierarchical Route Pushes (Imperative Navigator 1.0):**
   * From `HomePage`, `LibraryPage`, or `SearchPage`:
     `Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailsPage(book: book)))`
   * From `BookDetailsPage`:
     `Navigator.push(context, MaterialPageRoute(builder: (_) => ReadingPage(book: book)))`
   * App bars in `BookDetailsPage` and `ReadingPage` feature native back navigation buttons (`Navigator.pop(context)`).

---

## 6. State Management

### 6.0 Persisted reader state
`lib/services/app_state.dart` is the single local state boundary for the current offline app. It uses `shared_preferences` for library book IDs, unique read-book IDs, reading-day keys, per-book progress, theme mode, font size, auto-save, and notification preferences. No Firebase Authentication or Firestore integration exists in this project, so data is device-local and is not user-account scoped.

Opening a book in the reader records its ID and the calendar day once. The current streak counts consecutive calendar days ending today; the best streak is calculated from all stored reading days. Library membership changes only through the explicit Add to Library action. Currently Reading is limited to books with progress greater than zero that are not completed, with a maximum of five visible items.

Achievements are derived from persisted activity rather than pre-unlocked flags: first read, streak milestones, book-count milestones, first library/favorite action, and first completion. Completion data is reserved for future reader completion controls.

Settings are presented from Profile and use `ThemeMode` with centralized light and dark `ThemeData`. The selected mode survives app restarts; push notifications and logout are intentionally informational until an account/backend is added.

The Home page has no notification control. Notification preference is managed only from Profile -> Settings. Because this project contains no Firebase Messaging dependency or notification service, the setting is a persisted local preference and is ready to be connected to FCM when a notification backend is introduced.

### 6.1 Current Architecture (Ephemeral State)
* **Local Widget State:** State is managed locally via `StatefulWidget` and `setState`:
  * `_MainScreenState`: Manages `int selectedIndex`.
  * `_SearchPageState`: Manages `String searchText` and filters in-memory books dynamically during `build()`.
  * `_BookDetailsPageState`: Manages `bool isFavorite`.
  * `_ReadingPageState`: Manages `bool isBookmarked`.
* **State Isolation:** Updates to favorite status or reading progress within `BookDetailsPage` or `ReadingPage` do not mutate the underlying `sampleBooks` collection. When navigating back to `HomePage` or `LibraryPage`, changes are not reflected globally.

### 6.2 Proposed State Architecture
To support synchronized real-time updates and persistence:
* Introduce a lightweight centralized state holder such as `ChangeNotifier` / `ValueNotifier` (e.g., `BookRepository` / `LibraryProvider`).
* Wrap the app or tab screens with `ListenableBuilder` / Provider to propagate book updates (e.g., favoriting a book on Details immediately updates the Library and Profile favorite count).

---

## 7. Data Flow & Communication

```
┌────────────────────────────────────────────────────────┐
│               lib/models/book_model.dart               │
│               `sampleBooks` (List<Book>)               │
└────────────┬──────────────┬──────────────┬─────────────┘
             │              │              │
             ▼              ▼              ▼
       ┌───────────┐  ┌───────────┐  ┌───────────┐
       │ HomePage  │  │LibraryPage│  │SearchPage │
       └─────┬─────┘  └─────┬─────┘  └─────┬─────┘
             │              │              │
             └──────────────┼──────────────┘
                            ▼ (Passes Book via constructor)
                   ┌─────────────────┐
                   │ BookDetailsPage │
                   └────────┬────────┘
                            ▼ (Passes Book via constructor)
                   ┌─────────────────┐
                   │   ReadingPage   │
                   └─────────────────┘
```

1. **Data Source:** Static `sampleBooks` list in `lib/models/book_model.dart`.
2. **Tab Screens:** `HomePage`, `LibraryPage`, and `SearchPage` query/filter `sampleBooks` synchronously.
3. **Screen Transition:** When a user taps a book card or tile, the selected `Book` instance is passed directly as a constructor argument to `BookDetailsPage`.
4. **Reader Transition:** `BookDetailsPage` forwards the `Book` model to `ReadingPage` via its constructor.
5. **Feedback Loop:** Notifications (e.g., "Added to your library") are communicated to users via `ScaffoldMessenger.of(context).showSnackBar()`.
