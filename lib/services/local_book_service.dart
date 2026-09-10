import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;

import '../models/book_model.dart';

class LocalBookService {
  LocalBookService._internal();
  static final LocalBookService _instance = LocalBookService._internal();
  factory LocalBookService() => _instance;

  static const List<Book> _catalogue = [
    Book(
      id: 'pride_and_prejudice',
      gutenbergId: 1342,
      title: 'Pride and Prejudice',
      author: 'Jane Austen',
      description:
          'A timeless romantic masterpiece following the witty Elizabeth Bennet as she navigates issues of manners, upbringing, morality, education, and marriage in British Regency society. Her turbulent relationship with the proud and aloof Mr. Darcy remains one of the most celebrated love stories in English literature.',
      category: 'Romance',
      rating: 4.8,
      ratingCount: 28540,
      accentColor: Color(0xFF5B3E8C),
      progress: 0.0,
      readingPosition: 0.0,
      chapterTitle: 'Chapter 1',
      readingText: '',
      isFavorite: false,
      isSaved: false,
      isCompleted: false,
      featured: true,
      popularity: 1,
      publisher: 'T. Egerton, Military Library',
      publishedDate: '1813',
      isbn: '9780141439518',
      pageCount: 432,
      language: 'en',
      hasGutenbergContent: true,
      gutenbergTextUrl: 'https://www.gutenberg.org/cache/epub/1342/pg1342.txt',
      assetPath: 'assets/books/pride_and_prejudice.pdf',
    ),
    Book(
      id: 'sherlock_holmes',
      gutenbergId: 1661,
      title: 'The Adventures of Sherlock Holmes',
      author: 'Arthur Conan Doyle',
      description:
          'A classic collection of twelve detective mysteries featuring the brilliant consulting detective Sherlock Holmes and his companion Dr. John H. Watson. Includes iconic cases such as "A Scandal in Bohemia", "The Red-Headed League", and "The Speckled Band".',
      category: 'Mystery',
      rating: 4.7,
      ratingCount: 24100,
      accentColor: Color(0xFF2C3E50),
      progress: 0.0,
      readingPosition: 0.0,
      chapterTitle: 'A Scandal in Bohemia',
      readingText: '',
      isFavorite: false,
      isSaved: false,
      isCompleted: false,
      featured: true,
      popularity: 2,
      publisher: 'George Newnes',
      publishedDate: '1892',
      isbn: '9780140437713',
      pageCount: 307,
      language: 'en',
      hasGutenbergContent: true,
      gutenbergTextUrl: 'https://www.gutenberg.org/cache/epub/1661/pg1661.txt',
      assetPath: 'assets/books/adventures_of_sherlock_holmes.pdf',
    ),
    Book(
      id: 'alice_in_wonderland',
      gutenbergId: 11,
      title: "Alice's Adventures in Wonderland",
      author: 'Lewis Carroll',
      description:
          'When young Alice tumbles down a rabbit hole, she enters a fantastical world populated by peculiar, anthropomorphic creatures—the White Rabbit, the Cheshire Cat, the Mad Hatter, and the Queen of Hearts. A landmark of literary fantasy and nonsense.',
      category: 'Fantasy',
      rating: 4.6,
      ratingCount: 19800,
      accentColor: Color(0xFF008080),
      progress: 0.0,
      readingPosition: 0.0,
      chapterTitle: 'Down the Rabbit-Hole',
      readingText: '',
      isFavorite: false,
      isSaved: false,
      isCompleted: false,
      featured: true,
      popularity: 3,
      publisher: 'Macmillan',
      publishedDate: '1865',
      isbn: '9780141439761',
      pageCount: 192,
      language: 'en',
      hasGutenbergContent: true,
      gutenbergTextUrl: 'https://www.gutenberg.org/cache/epub/11/pg11.txt',
      assetPath: 'assets/books/alice_in_wonderland.pdf',
    ),
    Book(
      id: 'frankenstein',
      gutenbergId: 84,
      title: 'Frankenstein; Or, The Modern Prometheus',
      author: 'Mary Shelley',
      description:
          'The gothic masterpiece chronicling the obsessed young scientist Victor Frankenstein, who animates a creature from salvaged bodies. Shunned by mankind, the sensitive creation seeks retribution against his maker in an enduring exploration of hubris and humanity.',
      category: 'Science',
      rating: 4.7,
      ratingCount: 22300,
      accentColor: Color(0xFF2E5A44),
      progress: 0.0,
      readingPosition: 0.0,
      chapterTitle: 'Letter 1',
      readingText: '',
      isFavorite: false,
      isSaved: false,
      isCompleted: false,
      featured: true,
      popularity: 4,
      publisher: 'Lackington, Hughes, Harding, Mavor, & Jones',
      publishedDate: '1818',
      isbn: '9780141439471',
      pageCount: 280,
      language: 'en',
      hasGutenbergContent: true,
      gutenbergTextUrl: 'https://www.gutenberg.org/cache/epub/84/pg84.txt',
      assetPath: 'assets/books/frankenstein.pdf',
    ),
    Book(
      id: 'dracula',
      gutenbergId: 345,
      title: 'Dracula',
      author: 'Bram Stoker',
      description:
          'The seminal epistolary vampire novel that defined modern gothic horror. Follows Count Dracula\'s sinister attempt to relocate from Transylvania to England to spread the undead curse, and the desperate battle waged by Professor Van Helsing and his allies.',
      category: 'Fiction',
      rating: 4.6,
      ratingCount: 21900,
      accentColor: Color(0xFF8B0000),
      progress: 0.0,
      readingPosition: 0.0,
      chapterTitle: 'Jonathan Harker’s Journal',
      readingText: '',
      isFavorite: false,
      isSaved: false,
      isCompleted: false,
      featured: true,
      popularity: 5,
      publisher: 'Archibald Constable and Company',
      publishedDate: '1897',
      isbn: '9780141439846',
      pageCount: 418,
      language: 'en',
      hasGutenbergContent: true,
      gutenbergTextUrl: 'https://www.gutenberg.org/cache/epub/345/pg345.txt',
      assetPath: 'assets/books/dracula.pdf',
    ),
    Book(
      id: 'the_time_machine',
      gutenbergId: 35,
      title: 'The Time Machine',
      author: 'H.G. Wells',
      description:
          'The foundational science fiction story that popularized time travel with an intentional machine. A Victorian scientist journeys forward to A.D. 802,701, uncovering humanity\'s dystopian evolution into the gentle Eloi and sinister Morlocks.',
      category: 'Science',
      rating: 4.5,
      ratingCount: 16700,
      accentColor: Color(0xFFD35400),
      progress: 0.0,
      readingPosition: 0.0,
      chapterTitle: 'Chapter 1',
      readingText: '',
      isFavorite: false,
      isSaved: false,
      isCompleted: false,
      featured: true,
      popularity: 6,
      publisher: 'William Heinemann',
      publishedDate: '1895',
      isbn: '9780141439976',
      pageCount: 118,
      language: 'en',
      hasGutenbergContent: true,
      gutenbergTextUrl: 'https://www.gutenberg.org/cache/epub/35/pg35.txt',
      assetPath: 'assets/books/the_time_machine.pdf',
    ),
    Book(
      id: 'picture_of_dorian_gray',
      gutenbergId: 174,
      title: 'The Picture of Dorian Gray',
      author: 'Oscar Wilde',
      description:
          'Oscar Wilde\'s philosophical tale of beauty, aesthetic decadence, and corruption. The youthful Dorian Gray retains immortal youth while his hidden portrait ages and reflects his moral decay.',
      category: 'Philosophy',
      rating: 4.7,
      ratingCount: 23400,
      accentColor: Color(0xFF4A235A),
      progress: 0.0,
      readingPosition: 0.0,
      chapterTitle: 'The Preface',
      readingText: '',
      isFavorite: false,
      isSaved: false,
      isCompleted: false,
      featured: true,
      popularity: 7,
      publisher: 'Ward, Lock and Company',
      publishedDate: '1890',
      isbn: '9780141439570',
      pageCount: 254,
      language: 'en',
      hasGutenbergContent: true,
      gutenbergTextUrl: 'https://www.gutenberg.org/cache/epub/174/pg174.txt',
      assetPath: 'assets/books/picture_of_dorian_gray.pdf',
    ),
    Book(
      id: 'little_women',
      gutenbergId: 514,
      title: 'Little Women',
      author: 'Louisa May Alcott',
      description:
          'A beloved coming-of-age story centered on the four March sisters—Jo, Meg, Beth, and Amy—growing up in New England during the Civil War. Celebrates sisterhood, creativity, ambition, and the enduring strength of family.',
      category: 'Biography',
      rating: 4.6,
      ratingCount: 26000,
      accentColor: Color(0xFF995D3F),
      progress: 0.0,
      readingPosition: 0.0,
      chapterTitle: 'Playing Pilgrims',
      readingText: '',
      isFavorite: false,
      isSaved: false,
      isCompleted: false,
      featured: true,
      popularity: 8,
      publisher: 'Roberts Brothers',
      publishedDate: '1868',
      isbn: '9780147514011',
      pageCount: 759,
      language: 'en',
      hasGutenbergContent: true,
      gutenbergTextUrl: 'https://www.gutenberg.org/cache/epub/514/pg514.txt',
      assetPath: 'assets/books/little_women.pdf',
    ),
    Book(
      id: 'wizard_of_oz',
      gutenbergId: 55,
      title: 'The Wonderful Wizard of Oz',
      author: 'L. Frank Baum',
      description:
          'Swept away from Kansas by a cyclone, Dorothy Gale and her dog Toto journey along the Yellow Brick Road with the Scarecrow, Tin Woodman, and Cowardly Lion to reach the Emerald City and the Great Oz.',
      category: 'Fantasy',
      rating: 4.5,
      ratingCount: 15200,
      accentColor: Color(0xFF1E8449),
      progress: 0.0,
      readingPosition: 0.0,
      chapterTitle: 'The Cyclone',
      readingText: '',
      isFavorite: false,
      isSaved: false,
      isCompleted: false,
      featured: true,
      popularity: 9,
      publisher: 'George M. Hill Company',
      publishedDate: '1900',
      isbn: '9780141321028',
      pageCount: 140,
      language: 'en',
      hasGutenbergContent: true,
      gutenbergTextUrl: 'https://www.gutenberg.org/cache/epub/55/pg55.txt',
      assetPath: 'assets/books/wizard_of_oz.pdf',
    ),
    Book(
      id: 'tale_of_two_cities',
      gutenbergId: 98,
      title: 'A Tale of Two Cities',
      author: 'Charles Dickens',
      description:
          '"It was the best of times, it was the worst of times." Dickens\'s historic epic set in London and Paris before and during the French Revolution, depicting sacrifice and resurrection in the shadow of the guillotine.',
      category: 'History',
      rating: 4.6,
      ratingCount: 21500,
      accentColor: Color(0xFF6C3483),
      progress: 0.0,
      readingPosition: 0.0,
      chapterTitle: 'The Period',
      readingText: '',
      isFavorite: false,
      isSaved: false,
      isCompleted: false,
      featured: true,
      popularity: 10,
      publisher: 'Chapman & Hall',
      publishedDate: '1859',
      isbn: '9780141439600',
      pageCount: 448,
      language: 'en',
      hasGutenbergContent: true,
      gutenbergTextUrl: 'https://www.gutenberg.org/cache/epub/98/pg98.txt',
      assetPath: 'assets/books/tale_of_two_cities.pdf',
    ),
    Book(
      id: 'psychology_of_money',
      title: 'The Psychology of Money',
      author: 'Morgan Housel',
      description:
          'Doing well with money isn’t necessarily about what you know. It’s about how you behave. And behavior is hard to teach, even to really smart people. In The Psychology of Money, award-winning author Morgan Housel shares 19 short stories exploring the strange ways people think about money and teaches you how to make better sense of one of life’s most important topics.',
      category: 'Philosophy',
      rating: 4.8,
      ratingCount: 38400,
      accentColor: Color(0xFF0D9488),
      progress: 0.0,
      readingPosition: 0.0,
      chapterTitle: 'Introduction: The Greatest Show on Earth',
      readingText: '',
      isFavorite: false,
      isSaved: false,
      isCompleted: false,
      featured: true,
      popularity: 1,
      publisher: 'Harriman House',
      publishedDate: '2020',
      isbn: '9780857197689',
      pageCount: 253,
      language: 'en',
      hasGutenbergContent: true,
      assetPath: 'assets/books/psychology_of_money.pdf',
    ),
  ];

  static final Map<String, List<String>> _categoryTags = {
    'fiction': [
      'pride_and_prejudice',
      'sherlock_holmes',
      'frankenstein',
      'dracula',
      'the_time_machine',
      'picture_of_dorian_gray',
      'little_women',
      'wizard_of_oz',
      'tale_of_two_cities',
      'alice_in_wonderland',
      'psychology_of_money',
    ],
    'romance': ['pride_and_prejudice', 'little_women'],
    'comics': ['wizard_of_oz', 'alice_in_wonderland', 'the_time_machine', 'sherlock_holmes'],
    'adventure': ['the_time_machine', 'wizard_of_oz', 'sherlock_holmes', 'dracula'],
    'mystery': ['sherlock_holmes', 'dracula', 'picture_of_dorian_gray'],
    'fantasy': ['alice_in_wonderland', 'wizard_of_oz'],
    'sci-fi': ['the_time_machine', 'frankenstein'],
    'classics': ['pride_and_prejudice', 'dracula', 'tale_of_two_cities', 'picture_of_dorian_gray', 'little_women', 'sherlock_holmes'],
    'science': ['the_time_machine', 'frankenstein', 'psychology_of_money'],
    'philosophy': ['psychology_of_money', 'picture_of_dorian_gray', 'frankenstein'],
    'history': ['tale_of_two_cities', 'pride_and_prejudice'],
    'biography': ['psychology_of_money', 'little_women', 'pride_and_prejudice'],
  };

  /// Returns all 10 real public-domain books
  List<Book> getAllBooks() => List.unmodifiable(_catalogue);

  /// Returns featured classic books
  List<Book> getFeaturedBooks({int maxResults = 10}) {
    final list = _catalogue.where((b) => b.featured).toList();
    return list.take(maxResults).toList();
  }

  /// Returns books matching a category tab
  List<Book> getBooksByCategory(String category, {int maxResults = 10}) {
    final catKey = category.trim().toLowerCase();
    final ids = _categoryTags[catKey];
    if (ids != null && ids.isNotEmpty) {
      final matched = _catalogue.where((b) => ids.contains(b.id)).toList();
      if (matched.isNotEmpty) return matched.take(maxResults).toList();
    }

    // Direct category field match fallback
    final direct = _catalogue
        .where((b) => b.category.toLowerCase().contains(catKey) || catKey.contains(b.category.toLowerCase()))
        .toList();
    if (direct.isNotEmpty) return direct.take(maxResults).toList();

    return _catalogue.take(maxResults).toList();
  }

  /// Searches the local catalogue by title, author, description, or category
  List<Book> searchBooks(
    String query, {
    int startIndex = 0,
    int maxResults = 20,
  }) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return [];

    final terms = cleanQuery.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

    final matches = _catalogue.where((book) {
      final title = book.title.toLowerCase();
      final author = book.author.toLowerCase();
      final category = book.category.toLowerCase();
      final description = book.description.toLowerCase();

      return terms.every((term) =>
          title.contains(term) ||
          author.contains(term) ||
          category.contains(term) ||
          description.contains(term));
    }).toList();

    if (startIndex >= matches.length) return [];
    return matches.skip(startIndex).take(maxResults).toList();
  }

  /// Finds a book by its ID, with fallback for normalized IDs or title/path matches
  Book? getBookById(String id) {
    try {
      return _catalogue.firstWhere((b) => b.id == id);
    } catch (_) {
      try {
        final norm = id.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
        return _catalogue.firstWhere((b) {
          final bNorm = b.id.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
          return bNorm == norm ||
              (b.assetPath != null && b.assetPath!.contains(id)) ||
              b.title.toLowerCase() == id.toLowerCase();
        });
      } catch (_) {
        return null;
      }
    }
  }

  /// In-memory cache for loaded asset text
  static final Map<String, String> _textCache = {};

  /// Loads raw byte data of a book from local assets
  Future<Uint8List> loadBookBytes(Book book) async {
    final path = book.assetPath ?? book.contentAssetPath ?? getBookById(book.id)?.assetPath;
    if (path != null && path.isNotEmpty) {
      final ByteData data = await rootBundle.load(path);
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    }
    throw Exception('Content for "${book.title}" could not be loaded from local assets (path: $path).');
  }

  /// Loads the readable text or representation of a book from local assets
  Future<String> loadBookContent(Book book) async {
    // 1. In-memory cache
    if (_textCache.containsKey(book.id)) {
      return _textCache[book.id]!;
    }

    // 2. Pre-embedded text
    if (book.readingText.isNotEmpty && book.readingText.length > 500) {
      _textCache[book.id] = book.readingText;
      return book.readingText;
    }

    // 3. Local asset file
    final path = book.assetPath ?? book.contentAssetPath ?? getBookById(book.id)?.assetPath;
    if (path != null && path.isNotEmpty) {
      if (path.toLowerCase().endsWith('.txt')) {
        try {
          final ByteData data = await rootBundle.load(path);
          final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
          final content = utf8.decode(bytes, allowMalformed: true);
          if (content.trim().isNotEmpty) {
            _textCache[book.id] = content;
            return content;
          }
        } catch (e) {
          debugPrint('[LocalBookService] ByteData load error for $path ($e), trying loadString');
          try {
            final content = await rootBundle.loadString(path, cache: false);
            if (content.trim().isNotEmpty) {
              _textCache[book.id] = content;
              return content;
            }
          } catch (e2) {
            debugPrint('[LocalBookService] loadString also failed for $path: $e2');
            rethrow;
          }
        }
      } else {
        // PDF binary file
        final ByteData data = await rootBundle.load(path);
        if (data.lengthInBytes > 0) {
          final content = '[PDF Document: ${book.title}]';
          _textCache[book.id] = content;
          return content;
        }
      }
    }

    throw Exception('Content for "${book.title}" could not be loaded from local assets (path: $path).');
  }
}
