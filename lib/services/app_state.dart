import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/achievement_model.dart';
import '../models/book_model.dart';
import 'firebase_service.dart';

class AppState extends ChangeNotifier {
  AppState(this._preferences);

  final SharedPreferences _preferences;

  ThemeMode themeMode = ThemeMode.system;
  bool notificationsEnabled = true;
  bool autoSaveProgress = true;
  double fontSize = 18;
  int annualReadingGoal = 12;

  // Real user session info
  String? userId;
  String userName = 'Reader';
  String userEmail = '';
  bool isAuthenticated = false;

  // Real user book collections (stored as full Book JSON objects)
  final Map<String, Book> _savedBooks = {};
  final Set<String> libraryBookIds = {};
  final Set<String> favoriteBookIds = {};
  final Set<String> completedBookIds = {};
  final Map<String, double> progressByBook = {};
  final Map<String, double> positionByBook = {};
  final Set<String> readingDays = {};
  final Map<String, String> achievementUnlockedDates = {};

  static Future<AppState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final state = AppState(prefs);

    // Load settings
    state.themeMode = _themeModeFromString(prefs.getString('themeMode'));
    state.notificationsEnabled = prefs.getBool('notifications') ?? true;
    state.autoSaveProgress = prefs.getBool('autoSaveProgress') ?? true;
    state.fontSize = prefs.getDouble('fontSize') ?? 18;
    state.annualReadingGoal = prefs.getInt('annualGoal') ?? 12;

    // Load user session
    state.userId = prefs.getString('userId');
    state.userName = prefs.getString('userName') ?? 'Reader';
    state.userEmail = prefs.getString('userEmail') ?? '';
    state.isAuthenticated = prefs.getBool('isAuthenticated') ?? false;

    // Check if Firebase has a live user session
    final fbUser = FirebaseService.instance.currentUser;
    if (fbUser != null) {
      state.userId = fbUser.uid;
      state.userName = fbUser.displayName ?? fbUser.email?.split('@').first ?? 'Reader';
      state.userEmail = fbUser.email ?? '';
      state.isAuthenticated = true;
    }

    // Load IDs
    state.libraryBookIds.addAll(prefs.getStringList('libraryBooks') ?? []);
    state.favoriteBookIds.addAll(prefs.getStringList('favoriteBooks') ?? []);
    state.completedBookIds.addAll(prefs.getStringList('completedBooks') ?? []);
    state.readingDays.addAll(prefs.getStringList('readingDays') ?? []);

    // Load full saved books from preferences
    final savedKeys = prefs.getStringList('savedBookIndex') ?? [];
    for (final id in savedKeys) {
      final jsonStr = prefs.getString('saved_book_$id');
      if (jsonStr != null) {
        try {
          final map = jsonDecode(jsonStr) as Map<String, dynamic>;
          final book = Book.fromJson(map);
          state._savedBooks[id] = book;
          state.progressByBook[id] = book.progress;
          state.positionByBook[id] = book.readingPosition;
          if (book.isCompleted) state.completedBookIds.add(id);
          if (book.isFavorite) state.favoriteBookIds.add(id);
          if (book.isSaved) state.libraryBookIds.add(id);
        } catch (e) {
          debugPrint('[AppState] Error deserializing book $id: $e');
        }
      }
    }

    // Load achievements unlock dates
    final unlockDates = prefs.getString('achievementUnlockedDates');
    if (unlockDates != null) {
      try {
        state.achievementUnlockedDates.addAll(
          Map<String, String>.from(jsonDecode(unlockDates) as Map),
        );
      } catch (_) {}
    }

    state._refreshAchievementUnlocks();
    return state;
  }

  // ================= GETTERS =================

  /// All books explicitly in the user's library
  List<Book> get libraryBooks {
    return _savedBooks.values
        .where((b) => libraryBookIds.contains(b.id) || b.isSaved)
        .toList();
  }

  /// All books marked as favorite
  List<Book> get favoriteBooks {
    return _savedBooks.values
        .where((b) => favoriteBookIds.contains(b.id) || b.isFavorite)
        .toList();
  }

  /// All books marked as completed (read 100%)
  List<Book> get completedBooks {
    return _savedBooks.values
        .where((b) => completedBookIds.contains(b.id) || b.isCompleted || b.progress >= 0.99)
        .toList();
  }

  /// Only books with real unfinished reading progress (> 0.0 and < 0.99)
  List<Book> get currentlyReading {
    return _savedBooks.values.where((b) {
      final p = progressFor(b);
      final isDone = completedBookIds.contains(b.id) || b.isCompleted;
      return p > 0.01 && p < 0.99 && !isDone;
    }).toList();
  }

  bool isBookInLibrary(String bookId) => libraryBookIds.contains(bookId);
  bool isBookFavorite(String bookId) => favoriteBookIds.contains(bookId);

  double progressFor(Book book) => progressByBook[book.id] ?? book.progress;
  double positionFor(Book book) => positionByBook[book.id] ?? book.readingPosition;

  int get booksRead => completedBooks.length;

  int get currentStreak {
    if (readingDays.isEmpty) return 0;
    var streak = 0;
    var date = DateTime.now();

    // If today is a reading day, count from today.
    // If not read yet today, count from yesterday so streak doesn't prematurely drop.
    if (!readingDays.contains(dayKey(date))) {
      date = date.subtract(const Duration(days: 1));
    }

    while (readingDays.contains(dayKey(date))) {
      streak++;
      date = date.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int get bestStreak {
    if (readingDays.isEmpty) return 0;
    final days = readingDays.map((k) => DateTime.parse(k)).toList()..sort();
    var best = 1;
    var run = 1;
    for (var index = 1; index < days.length; index++) {
      if (days[index].difference(days[index - 1]).inDays == 1) {
        run++;
        best = run > best ? run : best;
      } else if (days[index].difference(days[index - 1]).inDays > 1) {
        run = 1;
      }
    }
    return best;
  }

  // ================= MUTATIONS =================

  /// Toggles whether a book is in the user's personal library
  void toggleLibrary(Book book) {
    final isSaved = libraryBookIds.contains(book.id);
    final updatedBook = book.copyWith(isSaved: !isSaved);

    if (isSaved) {
      libraryBookIds.remove(book.id);
      _savedBooks[book.id] = updatedBook;
      if (userId != null) {
        FirebaseService.instance.removeBookFromLibrary(userId!, book.id);
      }
    } else {
      libraryBookIds.add(book.id);
      _savedBooks[book.id] = updatedBook;
      if (userId != null) {
        FirebaseService.instance.syncBookToLibrary(userId!, updatedBook);
      }
    }

    _persistBook(updatedBook);
    _saveStringSet('libraryBooks', libraryBookIds);
    _refreshAchievementUnlocks();
    notifyListeners();
  }

  /// Toggles favorite status for a book
  void toggleFavorite(Book book) {
    final isFav = favoriteBookIds.contains(book.id);
    final updatedBook = book.copyWith(isFavorite: !isFav);

    if (isFav) {
      favoriteBookIds.remove(book.id);
    } else {
      favoriteBookIds.add(book.id);
    }
    _savedBooks[book.id] = updatedBook;

    _persistBook(updatedBook);
    _saveStringSet('favoriteBooks', favoriteBookIds);
    if (userId != null) {
      FirebaseService.instance.syncBookToLibrary(userId!, updatedBook);
    }
    _refreshAchievementUnlocks();
    notifyListeners();
  }

  /// Records real reading progress, scroll position, and marks today as a real reading day.
  void recordReadingProgress({
    required Book book,
    required double progress,
    required double position,
    bool isCompleted = false,
  }) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final completed = isCompleted || clampedProgress >= 0.99;
    final now = DateTime.now();
    final todayKey = dayKey(now);

    // Only record reading day when progress is actually made
    readingDays.add(todayKey);
    _saveStringSet('readingDays', readingDays);

    progressByBook[book.id] = clampedProgress;
    positionByBook[book.id] = position;

    if (completed) {
      completedBookIds.add(book.id);
      _saveStringSet('completedBooks', completedBookIds);
    }

    final updatedBook = book.copyWith(
      progress: clampedProgress,
      readingPosition: position,
      isCompleted: completed,
      lastReadAt: now,
    );
    _savedBooks[book.id] = updatedBook;
    _persistBook(updatedBook);

    if (userId != null) {
      FirebaseService.instance.syncReadingProgress(
        userId: userId!,
        bookId: book.id,
        progress: clampedProgress,
        readingPosition: position,
        isCompleted: completed,
      );
      FirebaseService.instance.syncReadingActivity(userId!, todayKey);
    }

    _refreshAchievementUnlocks();
    notifyListeners();
  }

  // ================= ACHIEVEMENTS =================

  bool isAchievementUnlocked(String id) {
    final achievement = achievementCatalog.where((item) => item.id == id).firstOrNull;
    return achievement != null && achievementProgress(achievement) >= achievement.threshold;
  }

  int achievementProgress(AchievementDefinition achievement) {
    switch (achievement.requirement) {
      case AchievementRequirement.booksRead:
      case AchievementRequirement.completedBook:
        return booksRead;
      case AchievementRequirement.readingStreak:
        return bestStreak;
      case AchievementRequirement.readingDays:
        return readingDays.length;
      case AchievementRequirement.comeback:
        return _hasComeback ? 1 : 0;
      case AchievementRequirement.libraryBooks:
      case AchievementRequirement.libraryFirst:
        return libraryBooks.length;
      case AchievementRequirement.favoriteFirst:
        return favoriteBooks.length;
    }
  }

  String? achievementUnlockedOn(String id) => achievementUnlockedDates[id];

  bool get _hasComeback {
    if (readingDays.length < 2) return false;
    final dates = readingDays.map((k) => DateTime.parse(k)).toList()..sort();
    return dates.asMap().entries.any(
      (entry) =>
          entry.key > 0 && entry.value.difference(dates[entry.key - 1]).inDays > 1,
    );
  }

  void _refreshAchievementUnlocks() {
    final today = dayKey(DateTime.now());
    var updated = false;
    for (final achievement in achievementCatalog) {
      if (isAchievementUnlocked(achievement.id) &&
          !achievementUnlockedDates.containsKey(achievement.id)) {
        achievementUnlockedDates[achievement.id] = today;
        updated = true;
      }
    }
    if (updated) {
      _preferences.setString(
        'achievementUnlockedDates',
        jsonEncode(achievementUnlockedDates),
      );
    }
  }

  // ================= USER SESSION =================

  void setUserSession({
    required String id,
    required String name,
    required String email,
  }) {
    userId = id;
    userName = name;
    userEmail = email;
    isAuthenticated = true;

    _preferences.setString('userId', id);
    _preferences.setString('userName', name);
    _preferences.setString('userEmail', email);
    _preferences.setBool('isAuthenticated', true);
    notifyListeners();
  }

  Future<void> logout() async {
    userId = null;
    userName = 'Reader';
    userEmail = '';
    isAuthenticated = false;

    await _preferences.remove('userId');
    await _preferences.remove('userName');
    await _preferences.remove('userEmail');
    await _preferences.setBool('isAuthenticated', false);

    await FirebaseService.instance.signOut();
    notifyListeners();
  }

  // ================= SETTINGS =================

  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    _preferences.setString('themeMode', mode.name);
    if (userId != null) {
      FirebaseService.instance.syncSettings(userId!, {'themeMode': mode.name});
    }
    notifyListeners();
  }

  void setNotifications(bool value) {
    notificationsEnabled = value;
    _preferences.setBool('notifications', value);
    if (userId != null) {
      FirebaseService.instance.syncSettings(userId!, {'notifications': value});
    }
    notifyListeners();
  }

  void setAutoSaveProgress(bool value) {
    autoSaveProgress = value;
    _preferences.setBool('autoSaveProgress', value);
    notifyListeners();
  }

  void setFontSize(double value) {
    fontSize = value;
    _preferences.setDouble('fontSize', value);
    notifyListeners();
  }

  void setAnnualGoal(int goal) {
    annualReadingGoal = goal;
    _preferences.setInt('annualGoal', goal);
    notifyListeners();
  }

  // ================= PERSISTENCE HELPERS =================

  void _persistBook(Book book) {
    _preferences.setString('saved_book_${book.id}', jsonEncode(book.toJson()));
    final index = _preferences.getStringList('savedBookIndex') ?? [];
    if (!index.contains(book.id)) {
      index.add(book.id);
      _preferences.setStringList('savedBookIndex', index);
    }
  }

  void _saveStringSet(String key, Set<String> values) {
    _preferences.setStringList(key, values.toList());
  }

  static String dayKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static ThemeMode _themeModeFromString(String? value) {
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ThemeMode.system,
    );
  }
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required super.notifier,
    required super.child,
  });

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope is missing above this widget.');
    return scope!.notifier!;
  }
}
