# BookVerse - Data Models & Schema Documentation

This document describes the existing data structures in BookVerse as well as proposed data models for upcoming phases.

---

## 1. Existing Data Models [IMPLEMENTED]

### 1.1 `Book` Model
Located in [`lib/models/book_model.dart`](file:///C:/Users/91739/App++/my_app/lib/models/book_model.dart).

```dart
import 'package:flutter/material.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final String category;
  final double rating;
  final Color accentColor;
  final double progress;
  final String chapterTitle;
  final String readingText;
  final bool isFavorite;
  final bool isSaved;
  final bool isCompleted;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.category,
    required this.rating,
    required this.accentColor,
    required this.progress,
    required this.chapterTitle,
    required this.readingText,
    required this.isFavorite,
    required this.isSaved,
    required this.isCompleted,
  });
}
```

#### Field Descriptions:
| Field Name | Type | Purpose |
|---|---|---|
| `id` | `String` | Unique identifier for each book (e.g., `'1'`, `'2'`). |
| `title` | `String` | Book title. |
| `author` | `String` | Name of the author. |
| `description` | `String` | Full summary/synopsis of the book. |
| `category` | `String` | Genre/Category name (e.g., `'Fiction'`, `'Self Growth'`, `'Adventure'`). |
| `rating` | `double` | Average rating from 0.0 to 5.0 (e.g., `4.8`). |
| `accentColor` | `Color` | Visual accent color used for cover presentation and shadows. |
| `progress` | `double` | Reader progress value from `0.0` (0%) to `1.0` (100%). |
| `chapterTitle` | `String` | Current chapter heading (e.g., `'Chapter 5: The Library of Possibilities'`). |
| `readingText` | `String` | Text content displayed in the reading screen. |
| `isFavorite` | `bool` | Flag indicating whether the book is in the user's favorites list. |
| `isSaved` | `bool` | Flag indicating whether the book is saved/bookmarked in the library. |
| `isCompleted` | `bool` | Flag indicating whether the user has finished reading the book. |

---

### 1.2 `sampleBooks` Mock Dataset
Currently hardcoded in [`lib/models/book_model.dart`](file:///C:/Users/91739/App++/my_app/lib/models/book_model.dart):
* **Total Books:** 6 pre-populated sample books:
  1. *The Midnight Library* by Matt Haig (Fiction, 4.8★, Indigo)
  2. *Atomic Habits* by James Clear (Self Growth, 4.9★, Blue)
  3. *The Great Adventure* by John Smith (Adventure, 4.7★, Deep Purple)
  4. *Mystery of Time* by Sarah Wilson (Mystery, 4.6★, Teal)
  5. *Beyond the Stars* by David Brown (Science Fiction, 4.5★, Orange)
  6. *The Secret Garden* by Frances Hodgson Burnett (Classic, 4.7★, Green)

---

## 2. Proposed Future Data Models [PROPOSED - DO NOT IMPLEMENT YET]

> [!NOTE]
> The models below represent the target schema for future state management and database persistence phases. They are not yet implemented in the codebase.

### 2.1 Proposed `Book` Model (Enhanced)
Adding immutability helpers, JSON serialization, and multi-chapter support:

```dart
// PROPOSED - NOT YET IMPLEMENTED
class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final String category;
  final double rating;
  final int colorValue; // Stored as integer for JSON persistence
  final double progress;
  final String? coverImageUrl;
  final List<Chapter> chapters;
  final int currentChapterIndex;
  final bool isFavorite;
  final bool isSaved;
  final bool isCompleted;
  final DateTime? lastReadAt;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.category,
    required this.rating,
    required this.colorValue,
    this.progress = 0.0,
    this.coverImageUrl,
    this.chapters = const [],
    this.currentChapterIndex = 0,
    this.isFavorite = false,
    this.isSaved = false,
    this.isCompleted = false,
    this.lastReadAt,
  });

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? description,
    String? category,
    double? rating,
    int? colorValue,
    double? progress,
    String? coverImageUrl,
    List<Chapter>? chapters,
    int? currentChapterIndex,
    bool? isFavorite,
    bool? isSaved,
    bool? isCompleted,
    DateTime? lastReadAt,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      colorValue: colorValue ?? this.colorValue,
      progress: progress ?? this.progress,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      chapters: chapters ?? this.chapters,
      currentChapterIndex: currentChapterIndex ?? this.currentChapterIndex,
      isFavorite: isFavorite ?? this.isFavorite,
      isSaved: isSaved ?? this.isSaved,
      isCompleted: isCompleted ?? this.isCompleted,
      lastReadAt: lastReadAt ?? this.lastReadAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'author': author,
    'description': description,
    'category': category,
    'rating': rating,
    'colorValue': colorValue,
    'progress': progress,
    'coverImageUrl': coverImageUrl,
    'currentChapterIndex': currentChapterIndex,
    'isFavorite': isFavorite,
    'isSaved': isSaved,
    'isCompleted': isCompleted,
    'lastReadAt': lastReadAt?.toIso8601String(),
  };

  factory Book.fromJson(Map<String, dynamic> json) => Book(
    id: json['id'] as String,
    title: json['title'] as String,
    author: json['author'] as String,
    description: json['description'] as String,
    category: json['category'] as String,
    rating: (json['rating'] as num).toDouble(),
    colorValue: json['colorValue'] as int,
    progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
    coverImageUrl: json['coverImageUrl'] as String?,
    currentChapterIndex: json['currentChapterIndex'] as int? ?? 0,
    isFavorite: json['isFavorite'] as bool? ?? false,
    isSaved: json['isSaved'] as bool? ?? false,
    isCompleted: json['isCompleted'] as bool? ?? false,
    lastReadAt: json['lastReadAt'] != null ? DateTime.parse(json['lastReadAt'] as String) : null,
  );
}
```

---

### 2.2 Proposed `Chapter` Model
Supports books with multiple sequential chapters and reading content:

```dart
// PROPOSED - NOT YET IMPLEMENTED
class Chapter {
  final String id;
  final String bookId;
  final String title;
  final String content;
  final int orderIndex;

  const Chapter({
    required this.id,
    required this.bookId,
    required this.title,
    required this.content,
    required this.orderIndex,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'bookId': bookId,
    'title': title,
    'content': content,
    'orderIndex': orderIndex,
  };

  factory Chapter.fromJson(Map<String, dynamic> json) => Chapter(
    id: json['id'] as String,
    bookId: json['bookId'] as String,
    title: json['title'] as String,
    content: json['content'] as String,
    orderIndex: json['orderIndex'] as int,
  );
}
```

---

### 2.3 Proposed `UserProfile` Model
Encapsulates reader profile information and dynamic reading statistics:

```dart
// PROPOSED - NOT YET IMPLEMENTED
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final int annualGoal;
  final int booksRead;
  final int currentlyReading;
  final int favoritesCount;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.annualGoal,
    this.booksRead = 0,
    this.currentlyReading = 0,
    this.favoritesCount = 0,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    int? annualGoal,
    int? booksRead,
    int? currentlyReading,
    int? favoritesCount,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      annualGoal: annualGoal ?? this.annualGoal,
      booksRead: booksRead ?? this.booksRead,
      currentlyReading: currentlyReading ?? this.currentlyReading,
      favoritesCount: favoritesCount ?? this.favoritesCount,
    );
  }
}
```

---

### 2.4 Proposed `Bookmark` Model
Persists reading position and user bookmarks:

```dart
// PROPOSED - NOT YET IMPLEMENTED
class Bookmark {
  final String id;
  final String bookId;
  final String chapterId;
  final String chapterTitle;
  final double scrollOffset;
  final DateTime createdAt;
  final String? note;

  const Bookmark({
    required this.id,
    required this.bookId,
    required this.chapterId,
    required this.chapterTitle,
    required this.scrollOffset,
    required this.createdAt,
    this.note,
  });
}
```
