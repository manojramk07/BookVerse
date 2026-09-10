import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/services/app_state.dart';
import 'package:my_app/services/local_book_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalBookService Catalogue Tests', () {
    final service = LocalBookService();

    test('Catalogue contains exactly 11 real books including The Psychology of Money', () {
      final allBooks = service.getAllBooks();
      expect(allBooks.length, equals(11));

      final titles = allBooks.map((b) => b.title).toList();
      expect(titles, contains('Pride and Prejudice'));
      expect(titles, contains('The Adventures of Sherlock Holmes'));
      expect(titles, contains("Alice's Adventures in Wonderland"));
      expect(titles, contains('Frankenstein; Or, The Modern Prometheus'));
      expect(titles, contains('Dracula'));
      expect(titles, contains('The Time Machine'));
      expect(titles, contains('The Picture of Dorian Gray'));
      expect(titles, contains('Little Women'));
      expect(titles, contains('The Wonderful Wizard of Oz'));
      expect(titles, contains('A Tale of Two Cities'));
      expect(titles, contains('The Psychology of Money'));
    });

    test('Every book in catalogue has valid metadata and asset path', () {
      final allBooks = service.getAllBooks();
      for (final book in allBooks) {
        expect(book.id, isNotEmpty);
        expect(book.title, isNotEmpty);
        expect(book.author, isNotEmpty);
        expect(book.description, isNotEmpty);
        expect(book.category, isNotEmpty);
        expect(book.assetPath, isNotNull);
        expect(book.assetPath!, startsWith('assets/books/'));
        expect(book.hasGutenbergContent, isTrue);
      }
    });

    test('All 11 book text files exist on disk in assets/books/', () {
      final allBooks = service.getAllBooks();
      for (final book in allBooks) {
        final file = File(book.assetPath!);
        expect(file.existsSync(), isTrue, reason: 'Missing asset file: ${book.assetPath}');
        expect(file.lengthSync(), greaterThan(50000),
            reason: 'Asset file too small or empty: ${book.assetPath}');
      }
    });

    test('Featured books are retrieved correctly', () {
      final featured = service.getFeaturedBooks();
      expect(featured, isNotEmpty);
      expect(featured.length, lessThanOrEqualTo(10));
      for (final b in featured) {
        expect(b.featured, isTrue);
      }
    });

    test('Category filtering maps to appropriate books', () {
      final romance = service.getBooksByCategory('Romance');
      expect(romance.any((b) => b.title.contains('Pride and Prejudice')), isTrue);

      final mystery = service.getBooksByCategory('Mystery');
      expect(mystery.any((b) => b.title.contains('Sherlock Holmes')), isTrue);

      final fantasy = service.getBooksByCategory('Fantasy');
      expect(fantasy.any((b) => b.title.contains('Alice') || b.title.contains('Oz')), isTrue);

      final science = service.getBooksByCategory('Science');
      expect(science.any((b) => b.title.contains('Time Machine') || b.title.contains('Frankenstein')), isTrue);

      final comics = service.getBooksByCategory('Comics');
      expect(comics.any((b) => b.title.contains('Oz') || b.title.contains('Alice')), isTrue);

      final adventure = service.getBooksByCategory('Adventure');
      expect(adventure.any((b) => b.title.contains('Sherlock') || b.title.contains('Oz')), isTrue);

      final scifi = service.getBooksByCategory('Sci-Fi');
      expect(scifi.any((b) => b.title.contains('Time Machine') || b.title.contains('Frankenstein')), isTrue);

      final history = service.getBooksByCategory('History');
      expect(history.any((b) => b.title.contains('Tale of Two Cities')), isTrue);
    });

    test('Search returns matches by title, author, or category', () {
      final searchPride = service.searchBooks('austen');
      expect(searchPride.length, equals(1));
      expect(searchPride.first.title, equals('Pride and Prejudice'));

      final searchHolmes = service.searchBooks('sherlock');
      expect(searchHolmes.length, equals(1));
      expect(searchHolmes.first.author, equals('Arthur Conan Doyle'));

      final searchGothic = service.searchBooks('frankenstein');
      expect(searchGothic.length, equals(1));
      expect(searchGothic.first.title, contains('Frankenstein'));

      final searchCaseInsensitive = service.searchBooks('dRaCuLa');
      expect(searchCaseInsensitive.length, equals(1));
      expect(searchCaseInsensitive.first.title, equals('Dracula'));

      final searchMoney = service.searchBooks('psychology of money');
      expect(searchMoney.length, equals(1));
      expect(searchMoney.first.author, equals('Morgan Housel'));

      final searchEmpty = service.searchBooks('');
      expect(searchEmpty, isEmpty);

      final searchNonexistent = service.searchBooks('xyz123randomnonexistent');
      expect(searchNonexistent, isEmpty);
    });

    test('Full reading and library flow with local catalogue book', () async {
      SharedPreferences.setMockInitialValues({});
      final state = await AppState.load();
      final book = service.getBookById('pride_and_prejudice');
      expect(book, isNotNull);

      // 1. Add to library
      state.toggleLibrary(book!);
      expect(state.isBookInLibrary(book.id), isTrue);
      expect(state.libraryBooks.length, equals(1));

      // 2. Favorite book
      state.toggleFavorite(book);
      expect(state.isBookFavorite(book.id), isTrue);
      expect(state.favoriteBooks.length, equals(1));

      // 3. Start reading & save progress
      state.recordReadingProgress(book: book, progress: 0.35, position: 2400.0);
      expect(state.currentlyReading.length, equals(1));
      expect(state.progressFor(book), equals(0.35));
      expect(state.positionFor(book), equals(2400.0));
      expect(state.currentStreak, equals(1));

      // 4. Complete book
      state.recordReadingProgress(book: book, progress: 1.0, position: 10000.0, isCompleted: true);
      expect(state.currentlyReading, isEmpty);
      expect(state.completedBooks.length, equals(1));
      expect(state.booksRead, equals(1));
      expect(state.isAchievementUnlocked('first-read'), isTrue);
    });
  });
}
