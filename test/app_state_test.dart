import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/models/book_model.dart';
import 'package:my_app/services/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppState Real Data Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Initializes with empty real data without dummy books', () async {
      final state = await AppState.load();
      expect(state.libraryBooks, isEmpty);
      expect(state.currentlyReading, isEmpty);
      expect(state.completedBooks, isEmpty);
      expect(state.booksRead, equals(0));
      expect(state.currentStreak, equals(0));
    });

    test('Records real reading progress and updates streak', () async {
      final state = await AppState.load();
      const testBook = Book(
        id: 'book_real_1',
        title: 'Real Test Book',
        author: 'Test Author',
        description: 'Real description',
        category: 'Fiction',
        rating: 4.5,
        accentColor: Colors.purple,
        progress: 0.0,
        chapterTitle: 'Chapter 1',
        readingText: 'Sample text content here...',
        isFavorite: false,
        isSaved: false,
        isCompleted: false,
      );

      // Record reading progress
      state.recordReadingProgress(
        book: testBook,
        progress: 0.45,
        position: 350.0,
      );

      expect(state.currentlyReading.length, equals(1));
      expect(state.currentlyReading.first.title, equals('Real Test Book'));
      expect(state.progressFor(testBook), equals(0.45));
      expect(state.positionFor(testBook), equals(350.0));
      expect(state.currentStreak, equals(1));
    });

    test('Completing a book marks it completed and updates booksRead', () async {
      final state = await AppState.load();
      const testBook = Book(
        id: 'book_finish_1',
        title: 'Finished Book',
        author: 'Test Author',
        description: 'Real description',
        category: 'Fiction',
        rating: 4.8,
        accentColor: Colors.teal,
        progress: 0.0,
        chapterTitle: 'Chapter 1',
        readingText: 'Text',
        isFavorite: false,
        isSaved: false,
        isCompleted: false,
      );

      state.recordReadingProgress(
        book: testBook,
        progress: 1.0,
        position: 1000.0,
        isCompleted: true,
      );

      expect(state.currentlyReading, isEmpty);
      expect(state.completedBooks.length, equals(1));
      expect(state.booksRead, equals(1));
      expect(state.isAchievementUnlocked('first-read'), isTrue);
    });

    test('Library toggle persists book in library', () async {
      final state = await AppState.load();
      const testBook = Book(
        id: 'book_fav_1',
        title: 'Favorite Title',
        author: 'Jane Doe',
        description: 'Story',
        category: 'Adventure',
        rating: 4.2,
        accentColor: Colors.blue,
        progress: 0.0,
        chapterTitle: 'Chapter 1',
        readingText: '',
        isFavorite: false,
        isSaved: false,
        isCompleted: false,
      );

      state.toggleLibrary(testBook);
      expect(state.isBookInLibrary('book_fav_1'), isTrue);
      expect(state.libraryBooks.length, equals(1));

      // Toggle off
      state.toggleLibrary(testBook);
      expect(state.isBookInLibrary('book_fav_1'), isFalse);
      expect(state.libraryBooks, isEmpty);
    });

    test('Permanent User ID is retained and not regenerated on reload or refresh', () async {
      final state1 = await AppState.load();
      final initialId = state1.userId;
      expect(initialId, isNotEmpty);
      expect(initialId, startsWith('BV-'));

      // Safe refreshData does not change user ID
      state1.refreshData();
      expect(state1.userId, equals(initialId));

      // Reloading app preserves the exact same permanent user ID
      final state2 = await AppState.load();
      expect(state2.userId, equals(initialId));
    });

    test('Edited profile details are replaced and saved permanently across reload', () async {
      final state = await AppState.load();
      await state.updateProfile(
        name: 'Jane Doe',
        email: 'jane@example.com',
        bio: 'Reading classic gothic novels',
        customUserId: 'BV-7777',
      );

      expect(state.userName, equals('Jane Doe'));
      expect(state.userId, equals('BV-7777'));
      expect(state.userEmail, equals('jane@example.com'));
      expect(state.userBio, equals('Reading classic gothic novels'));
      expect(state.userInitial, equals('J'));

      // Reload from SharedPreferences and ensure all edits are permanent
      final reloadedState = await AppState.load();
      expect(reloadedState.userName, equals('Jane Doe'));
      expect(reloadedState.userId, equals('BV-7777'));
      expect(reloadedState.userEmail, equals('jane@example.com'));
      expect(reloadedState.userBio, equals('Reading classic gothic novels'));
      expect(reloadedState.userInitial, equals('J'));
    });

    test('Real-time daily reading time and books read are tracked per date', () async {
      final state = await AppState.load();
      final now = DateTime.now();
      const book1 = Book(
        id: 'book_1',
        title: 'Frankenstein',
        author: 'Mary Shelley',
        description: 'Sci-Fi Gothic',
        category: 'Sci-Fi',
        rating: 4.7,
        accentColor: Colors.green,
        progress: 0.1,
        chapterTitle: 'Letter 1',
        readingText: '',
        isFavorite: false,
        isSaved: false,
        isCompleted: false,
      );
      const book2 = Book(
        id: 'book_2',
        title: 'Dracula',
        author: 'Bram Stoker',
        description: 'Gothic Horror',
        category: 'Fiction',
        rating: 4.6,
        accentColor: Colors.red,
        progress: 0.2,
        chapterTitle: 'Chapter 1',
        readingText: '',
        isFavorite: false,
        isSaved: false,
        isCompleted: false,
      );

      // Record 120 seconds for Frankenstein
      state.recordReadingTime(book: book1, seconds: 120);

      var record = state.getReadingRecordForDate(now);
      expect(record.seconds, equals(120));
      expect(record.bookTitles, contains('Frankenstein'));

      // Record 180 seconds for Dracula on same date
      state.recordReadingTime(book: book2, seconds: 180);

      record = state.getReadingRecordForDate(now);
      expect(record.seconds, equals(300));
      expect(record.bookTitles, containsAll(['Frankenstein', 'Dracula']));
      expect(state.totalReadingSeconds, equals(300));
      expect(state.totalReadingMinutes, equals(5));

      // Test formatDuration helper
      expect(AppState.formatDuration(45), equals('45 sec'));
      expect(AppState.formatDuration(300), equals('5 mins'));
      expect(AppState.formatDuration(3660), equals('1 hr 1 min'));
    });

    test('Reading time achievements unlock when duration threshold is reached', () async {
      final state = await AppState.load();
      const testBook = Book(
        id: 'book_time',
        title: 'The Time Machine',
        author: 'H.G. Wells',
        description: 'Sci-Fi',
        category: 'Sci-Fi',
        rating: 4.5,
        accentColor: Colors.orange,
        progress: 0.5,
        chapterTitle: 'Chapter 1',
        readingText: '',
        isFavorite: false,
        isSaved: false,
        isCompleted: false,
      );

      // Record 16 minutes of reading time (960 seconds)
      state.recordReadingTime(book: testBook, seconds: 960);
      expect(state.isAchievementUnlocked('time-devotee'), isTrue);

      // Record enough to reach 60 minutes total
      state.recordReadingTime(book: testBook, seconds: 2700);
      expect(state.isAchievementUnlocked('hour-reader'), isTrue);
      expect(state.isAchievementUnlocked('power-session'), isTrue);
    });
  });
}
