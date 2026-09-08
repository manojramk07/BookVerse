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
  });
}
