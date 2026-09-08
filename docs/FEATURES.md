# BookVerse - Feature Matrix & Roadmap

This document outlines the current functional state, active development items, planned enhancements, and long-term ideas for **BookVerse**.

Each feature is labeled with one of the following statuses:
* **`[IMPLEMENTED]`**: Fully functional in the existing codebase.
* **`[IN PROGRESS]`**: Currently partially structured or awaiting integration.
* **`[PLANNED]`**: Defined and scheduled for upcoming development phases.

---

## 1. Application Foundation & Global Navigation

| Feature | Status | Description |
|---|---|---|
| Material 3 Theming | `[IMPLEMENTED]` | Seeded deep purple theme with customized light scaffold background (`#F8F7FC`). |
| 4-Tab Bottom Navigation | `[IMPLEMENTED]` | Navigation bar with Home, Library, Search, and Profile tabs. |
| Persistent Screen Stacking | `[IMPLEMENTED]` | `IndexedStack` preserving scroll states and view data between tab switches. |
| Android App Label Configuration | `[IMPLEMENTED]` | Android application title configured as "BookVerse" in `AndroidManifest.xml`. |
| iOS Display Name Configuration | `[PLANNED]` | Update iOS bundle display name to "BookVerse" in `Info.plist`. |
| Light / Dark Theme Switching | `[PLANNED]` | Dynamic theme mode toggle with dark mode palette. |

---

## 2. Home Screen

| Feature | Status | Description |
|---|---|---|
| Welcome Header & Subtitle | `[IMPLEMENTED]` | Welcoming greeting text and reader encouragement. |
| Notification Action Icon | `[IMPLEMENTED]` | Bell icon button with feedback snackbar. |
| Home Search Input Bar UI | `[IMPLEMENTED]` | Styled search bar with prefix search icon. |
| Home Search Bar Redirection | `[PLANNED]` | Directing user to the Search tab with pre-filled query on interaction. |
| "Continue Reading" Carousel | `[IMPLEMENTED]` | Horizontal book cards showing active reading progress bars (`progress > 0.1`). |
| "Popular Books" Ranking Feed | `[IMPLEMENTED]` | Horizontal ranking list with `#rank` badges, author names, and star ratings. |
| "Recommended Books" List | `[IMPLEMENTED]` | Vertical list of curated titles with category tags. |
| "Popular Categories" Wrap Grid | `[IMPLEMENTED]` | Category pill chips for Fiction, Science, History, Romance, Fantasy, Technology. |
| Category Filter Navigation | `[PLANNED]` | Tapping a category chip filters books or routes to a category-specific view. |
| "See All" Book Feed Browsing | `[PLANNED]` | Tapping "See All" opens a full paginated or scrollable list for each section. |

---

## 3. Library Screen

| Feature | Status | Description |
|---|---|---|
| "Currently Reading" Section | `[IMPLEMENTED]` | Lists books where `!isCompleted` with real-time percentage progress bar. |
| "Favorites" Section | `[IMPLEMENTED]` | Displays books flagged with `isFavorite == true`. |
| "Completed" Section | `[IMPLEMENTED]` | Displays finished books flagged with `isCompleted == true`. |
| "Saved Books" Section | `[IMPLEMENTED]` | Displays bookmarked/saved titles flagged with `isSaved == true`. |
| Empty State Handling for Library | `[PLANNED]` | Friendly placeholder graphics/messages when a library shelf is empty. |
| Tabbed Library Filtering | `[PLANNED]` | Segmented tabs (All / Reading / Favorites / Finished / Saved) for easier browsing. |
| Custom Shelves / Collections | `[PLANNED]` | User-created custom shelves (e.g., "Summer Reads", "Study Materials"). |

---

## 4. Search Screen

| Feature | Status | Description |
|---|---|---|
| Live Text Search | `[IMPLEMENTED]` | Real-time filtering matching queries against book titles and authors. |
| Instant Search Results List | `[IMPLEMENTED]` | Clean list tiles displaying accent cover, title, author, and forward chevron. |
| Empty Results State | `[IMPLEMENTED]` | Contextual message when no titles or authors match the search string. |
| Search by Category / Genre | `[PLANNED]` | Filter search results by genre/category tags. |
| Recent Searches History | `[PLANNED]` | Persisted history of recent search terms with quick clear options. |
| Clear Search Query Button | `[PLANNED]` | Trailing `(X)` icon button to clear active search text instantly. |

---

## 5. Profile & Reader Stats

| Feature | Status | Description |
|---|---|---|
| User Avatar & Identification | `[IMPLEMENTED]` | Profile avatar icon, reader name ("Aisha Carter"), and email. |
| Reader Statistics Counters | `[IMPLEMENTED]` | Quick-glance metric boxes for Books Read (24), Reading (8), Favorites (4). |
| Dynamic Metric Calculation | `[PLANNED]` | Calculating stats dynamically based on actual user library data. |
| Annual Reading Goal Card | `[IMPLEMENTED]` | Progress bar and textual milestone indicator (7 of 12 books complete). |
| Custom Reading Goal Setter | `[PLANNED]` | User ability to set/edit annual and monthly reading targets. |
| Profile Settings Navigation | `[IMPLEMENTED]` | Interactive menu tiles with feedback snackbars for Edit Profile, Settings, etc. |
| Editable User Profile | `[PLANNED]` | Edit profile modal/screen to update display name, avatar, and reading preferences. |

---

## 6. Book Details Screen

| Feature | Status | Description |
|---|---|---|
| Hero Accent Book Cover | `[IMPLEMENTED]` | Elevated book cover with custom accent color and soft glow drop shadow. |
| Comprehensive Book Metadata | `[IMPLEMENTED]` | Title, author, star rating, and category tag badge. |
| Synopsis & Description | `[IMPLEMENTED]` | Multi-line book overview with comfortable line height. |
| "Read Now" Navigation | `[IMPLEMENTED]` | Primary action button launching the chapter reader view. |
| Interactive Favorite Toggle | `[IMPLEMENTED]` | Heart icon toggle switching between filled and outlined states. |
| "Add to Library" Action | `[IMPLEMENTED]` | Outlined button showing confirmation snackbar. |
| Synchronized Library Updates | `[PLANNED]` | Persisting favorite/saved changes across the global state repository. |
| User Reviews & Rating Submission| `[PLANNED]` | Ability for users to submit personal ratings and notes. |

---

## 7. Reading Screen

| Feature | Status | Description |
|---|---|---|
| Book & Chapter Headers | `[IMPLEMENTED]` | App bar title and styled chapter banner container. |
| Reading Progress Bar | `[IMPLEMENTED]` | Progress indicator visualizing chapter progress percentage. |
| Scrollable Text Body | `[IMPLEMENTED]` | Clean, typography-focused reading content view. |
| Interactive Bookmark Toggle | `[IMPLEMENTED]` | Action button toggling chapter bookmark state. |
| Multi-Chapter Navigation | `[PLANNED]` | Chapter selector drawer / next and previous chapter navigation buttons. |
| Reading Customization Panel | `[PLANNED]` | Modal sheet for font sizing, font family selection, and theme modes (Light, Sepia, Dark). |
| Real Reading Position Tracking | `[PLANNED]` | Saving scroll offset / last read page automatically to local storage. |

---

## 8. Data Persistence & Offline Functionality

| Feature | Status | Description |
|---|---|---|
| In-Memory Mock Repository | `[IMPLEMENTED]` | Static `sampleBooks` collection in `book_model.dart`. |
| Local Database / Key-Value Store | `[PLANNED]` | Persistent storage using `shared_preferences` or SQLite / Hive. |
| Offline Book Reading | `[PLANNED]` | Complete offline access to downloaded book chapters and cached covers. |
| Export / Import Reading Data | `[PLANNED]` | Backup and restore reading progress and bookmarks. |
