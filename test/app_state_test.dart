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
  });
}
