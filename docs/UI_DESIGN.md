# BookVerse - UI/UX Design System & Guidelines

## 1. Design Philosophy

BookVerse embraces a **clean, modern, content-first digital library aesthetic**. The design balances warm readability with polished, contemporary mobile UI patterns:
* **Generous Whitespace & Soft Depths:** Subtle shadows and elevated cards create visual hierarchy without visual clutter.
* **Cohesive Theming:** Deep Purple accent palette paired with soft off-white background tones (`#F8F7FC`).
* **Visual Clarity:** High-contrast text, clear metadata badges, and smooth horizontal and vertical scrolling flows.

---

## 2. Color Palette

### 2.1 Core Palette
| Token / Element | Color Value | Hex / Code | Usage |
|---|---|---|---|
| **Scaffold Background** | Soft Lavender White | `0xFFF8F7FC` | Background across all primary screens |
| **Primary Seed / Brand** | Deep Purple | `Colors.deepPurple` (`#6750A4`) | App bars, prominent headers, selected icons, primary buttons |
| **Primary Container** | Deep Purple (50) | `Colors.deepPurple.shade50` (`#F3E8FF`) | Goal card background, category tags, avatar containers |
| **Surface / Card Background** | Pure White | `Colors.white` (`#FFFFFF`) | Card bodies, search inputs, statistic containers |
| **Text Primary** | Deep Charcoal / Black | `Colors.black87` / `Colors.black` | Main titles, book names, body reading text |
| **Text Secondary / Muted** | Neutral Slate / Grey | `Colors.grey` (`#9E9E9E`) | Author names, progress subtitles, hint texts |
| **Accent / Rating Gold** | Amber | `Colors.amber` (`#FFC107`) | Star rating icons |
| **Border / Divider** | Purple Tinted Outline | `Colors.deepPurple.shade100` | Category chip borders, subtle dividers |

### 2.2 Dynamic Book Cover Accent Colors
Books in BookVerse currently feature dynamic accent colors used for mock book cover canvases and glow drop shadows:
* Indigo (`Colors.indigo`)
* Blue (`Colors.blue`)
* Deep Purple (`Colors.deepPurple`)
* Teal (`Colors.teal`)
* Orange (`Colors.orange`)
* Green (`Colors.green`)

---

## 3. Typography Hierarchy

The default font family configured in `ThemeData` is **Roboto** (Material 3 default).

| Style Role | Font Size | Font Weight | Color | Example Location |
|---|---|---|---|---|
| **Display / Page Header** | `28px - 30px` | Bold (`FontWeight.bold`) | Deep Purple | "Welcome to BookVerse", "My Library", "Profile" |
| **Section Title** | `22px` | Bold (`FontWeight.bold`) | Black87 | "Continue Reading", "Popular Books", "Reading Goal" |
| **Card Title (Primary)** | `16px` | Bold (`FontWeight.bold`) | Black87 | Book titles in cards, Library rows |
| **Card Title (Ranked)** | `15px` | Bold (`FontWeight.bold`) | Black87 | Book titles in `PopularBookCard` |
| **Subtitle / Author** | `13px - 15px` | Normal / Medium | Grey | "Find your next favorite read", Author names |
| **Badge / Tag Text** | `12px - 14px` | Semi-bold (`FontWeight.w600`) | Deep Purple | Category chips, rating values, rank badges |
| **Reading Text Body** | `18px` | Normal (`FontWeight.w400`) | Black87 (Line Height: 1.8) | Reading screen chapter body |
| **Synopsis Description** | `15px` | Normal (Line Height: 1.6) | Black87 | Book details description |

---

## 4. Component Design Specifications

### 4.1 Navigation Bar
* **Container:** Material 3 `NavigationBar` with pure white background (`Colors.white`).
* **Active Indicator:** Light purple pill (`Colors.deepPurple.shade100`).
* **Icons:** Outlined icon when inactive (e.g., `Icons.home_outlined`), filled icon when active (e.g., `Icons.home`).
* **Labels:** 4 persistent labels: `Home`, `Library`, `Search`, `Profile`.

### 4.2 Cards & Containers
* **Standard Book Card (`BookCard`):**
  * Width: `175px`, Margin: `15px` right.
  * Border Radius: `16px`, Elevation: `3`.
  * Book Cover: Top container with `12px` rounded corners and white center icon.
  * Linear Progress Bar: `5px` height, rounded ends, shown if `progress > 0`.
* **Popular Book Card (`PopularBookCard`):**
  * Width: `180px`, Margin: `15px` right.
  * Includes top-left floating rank pill (`#1`, `#2`) with white background and bold purple text.
  * Star rating row with Amber star icon and numeric text.
* **List Row Book Tile (`RecentlyAddedBook` & `LibraryBook`):**
  * Border Radius: `15px` - `16px`, Elevation: `2`.
  * Leading cover thumbnail: `65px` width × `85px - 90px` height.
  * Horizontal layout with title, author, and progress indicator or category tag.

### 4.3 Buttons & Actions
* **Filled Primary Button:** `FilledButton.icon` with `14px` - `16px` rounded corners (used for "Read Now").
* **Outlined Action Button:** `OutlinedButton.icon` with matching rounded corners (used for "Add to Library").
* **Tonal Icon Button:** `IconButton.filledTonal` for favorite toggle.
* **Text Button:** Simple `TextButton` for "See All" section actions.

### 4.4 Category Chips (`CategoryChip`)
* Horizontal padding `15px`, vertical padding `12px`.
* Rounded border `15px` with light purple border line (`deepPurple.shade100`).
* Leading colored icon (`20px`) and medium-weight title.

---

## 5. Screen Layout Specifications

### 5.1 Home Screen (`HomePage`)
1. **Header Section:** Top row containing greeting and notification bell icon button inside a circular container.
2. **Search Container:** Rounded box (`16px`) with soft shadow (`alpha: 0.05`), prefix search icon, and placeholder text.
3. **Continue Reading Feed:** Horizontal scrollable `ListView` (`220px` height) with progress bars.
4. **Popular Books Feed:** Horizontal scrollable `ListView` (`240px` height) with rank tags and ratings.
5. **Recommended Books Feed:** Vertical non-scrollable `ListView` embedded in outer scroll view.
6. **Popular Categories:** Responsive `Wrap` layout with horizontal and vertical spacing (`10px`).

### 5.2 Library Screen (`LibraryPage`)
1. **Header:** "My Library" display heading with "Your saved books" subtitle.
2. **Four Filtered Sections:**
   * Currently Reading
   * Favorites
   * Completed
   * Saved Books
3. **Tile Layout:** Vertically stacked `LibraryBook` cards with tap ripple effects leading to Details.

### 5.3 Search Screen (`SearchPage`)
1. **Search Input Field:** Full-width filled text input with rounded border (`15px`) and active `onChanged` listener.
2. **Live Results:** Dynamic `ListView` rendering filtered book cards.
3. **Empty State:** Centered friendly message: *"No books found. Try a different title or author."*

### 5.4 Profile Screen (`ProfilePage`)
1. **Header & Avatar:** Centered `CircleAvatar` (`radius: 55`), display name, and email address.
2. **Stat Row:** White rounded card containing 3 equal columns (`ProfileStat`):
   * Books Read (24)
   * Reading (8)
   * Favorites (4)
3. **Goal Progress Card:** Highlighted purple container (`deepPurple.shade50`) with annual goal title, progress bar (`0.7`), and completion subtitle.
4. **Action Menu:** Vertically stacked `ProfileOption` cards (Edit Profile, Settings, Saved Books, Help & Support, Logout).

### 5.5 Book Details Screen (`BookDetailsPage`)
1. **Hero Book Cover:** Prominent elevated cover container (`180px × 240px`, radius `26px`) with matching glow shadow.
2. **Title & Author:** Large bold title with author subtitle.
3. **Metadata Row:** Star rating badge paired with category badge pill.
4. **Synopsis:** Full-text description with comfortable line spacing (`1.6`).
5. **Action Bar:** "Read Now" primary button alongside Favorite toggle and "Add to Library" secondary button.

### 5.6 Reading Screen (`ReadingPage`)
1. **App Bar:** Book title heading with interactive Bookmark action icon.
2. **Chapter Header:** Purple banner pill containing book icon and current chapter title.
3. **Progress Bar:** High-contrast `LinearProgressIndicator` showing reader progress.
4. **Reader Body:** Smooth vertical scrolling text area with `18px` font size and `1.8` line height.

---

## 6. Design Direction & Future Guidelines

To keep the BookVerse experience premium and consistent in future phases:
1. **Maintain Consistent Corner Radii:**
   * Small items (chips, thumbnails): `10px - 12px`
   * Standard cards and inputs: `15px - 16px`
   * Prominent hero covers: `24px - 26px`
2. **Maintain Padding Standards:**
   * Screen edge margin: `20px` standard padding.
   * Section vertical spacing: `24px - 28px`.
   * Item spacing in lists: `12px - 15px`.
3. **Support Dark Mode & Custom Reader Themes:**
   * Prepare color tokens for dark mode (e.g., `#121212` background, elevated `#1E1E2E` card surfaces).
   * Prepare e-reader themes (Sepia `#FBF0D9`, Night Mode `#181A1B`).
4. **Asset & Cover Image Strategy:**
   * Seamless fallback: Display the current colored vector cover if an image URL or local asset is unavailable or loading.
   * Use `ClipRRect` to ensure image covers respect existing border radii.
