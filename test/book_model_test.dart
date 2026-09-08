import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/models/book_model.dart';

void main() {
  group('Book Model Tests', () {
    test('Serializes to and from JSON correctly', () {
      const original = Book(
        id: 'gbooks_123',
        googleBooksId: 'gbooks_123',
        gutenbergId: 1342,
        title: 'Pride and Prejudice',
        author: 'Jane Austen',
        description: 'A classic novel about manners and marriage.',
        category: 'Fiction',
        rating: 4.8,
        ratingCount: 1500,
        accentColor: Colors.indigo,
        progress: 0.42,
        readingPosition: 1200.0,
        chapterTitle: 'Chapter 1',
        readingText: 'It is a truth universally acknowledged...',
        isFavorite: true,
        isSaved: true,
        isCompleted: false,
        coverUrl: 'https://example.com/cover.jpg',
        publisher: 'Penguin Classics',
        publishedDate: '1813',
        isbn: '9780141439518',
        pageCount: 432,
        language: 'en',
        hasGutenbergContent: true,
        gutenbergTextUrl: 'https://www.gutenberg.org/cache/epub/1342/pg1342.txt',
        assetPath: 'assets/books/pride_and_prejudice.txt',
      );

      final json = original.toJson();
      final deserialized = Book.fromJson(json);

      expect(deserialized.id, equals(original.id));
      expect(deserialized.title, equals(original.title));
      expect(deserialized.author, equals(original.author));
      expect(deserialized.gutenbergId, equals(original.gutenbergId));
      expect(deserialized.progress, equals(original.progress));
      expect(deserialized.readingPosition, equals(original.readingPosition));
      expect(deserialized.assetPath, equals('assets/books/pride_and_prejudice.txt'));
      expect(deserialized.isFavorite, isTrue);
      expect(deserialized.isSaved, isTrue);
      expect(deserialized.hasGutenbergContent, isTrue);
    });

    test('copyWith properly updates specific fields', () {
      const original = Book(
        id: '1',
        title: 'Original Title',
        author: 'Author',
        description: 'Desc',
        category: 'Fiction',
        rating: 4.0,
        accentColor: Colors.blue,
        progress: 0.0,
        chapterTitle: 'Chapter 1',
        readingText: '',
        isFavorite: false,
        isSaved: false,
        isCompleted: false,
      );

      final updated = original.copyWith(
        progress: 0.75,
        isFavorite: true,
        hasGutenbergContent: true,
      );

      expect(updated.id, equals('1'));
      expect(updated.title, equals('Original Title'));
      expect(updated.progress, equals(0.75));
      expect(updated.isFavorite, isTrue);
      expect(updated.hasGutenbergContent, isTrue);
      expect(updated.isCompleted, isFalse);
    });
  });
}
