import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/book_model.dart';

class GoogleBooksService {
  GoogleBooksService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const String _apiKey = String.fromEnvironment('GOOGLE_BOOKS_API_KEY');

  // Simple in-memory cache for search & category queries
  static final Map<String, List<Book>> _queryCache = {};

  Future<List<Book>> searchBooks(
    String query, {
    int startIndex = 0,
    int maxResults = 20,
  }) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    final cacheKey = 'search_${cleanQuery.toLowerCase()}_${startIndex}_$maxResults';
    if (startIndex == 0 && _queryCache.containsKey(cacheKey)) {
      return _queryCache[cacheKey]!;
    }

    final queryParameters = <String, String>{
      'q': cleanQuery,
      'startIndex': startIndex.toString(),
      'maxResults': maxResults.clamp(1, 40).toString(),
      'printType': 'books',
      if (_apiKey.isNotEmpty) 'key': _apiKey,
    };

    final uri = Uri.https('www.googleapis.com', '/books/v1/volumes', queryParameters);

    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 12));

      if (response.statusCode == 429) {
        throw GoogleBooksQuotaException(
          'Google Books request limit reached. Please wait a moment or configure an API key.',
        );
      }

      if (response.statusCode != 200) {
        throw GoogleBooksException(
          'Google Books service returned HTTP ${response.statusCode}.',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw GoogleBooksException('Invalid response format from Google Books.');
      }

      final items = decoded['items'];
      if (items is! List || items.isEmpty) {
        return [];
      }

      final books = items
          .whereType<Map<String, dynamic>>()
          .map(_bookFromVolume)
          .toList();

      if (startIndex == 0) {
        _queryCache[cacheKey] = books;
      }
      return books;
    } on SocketException catch (_) {
      throw GoogleBooksNetworkException(
        'Unable to connect to Google Books. Please check your internet connection.',
      );
    } on http.ClientException catch (_) {
      throw GoogleBooksNetworkException(
        'Network error communicating with Google Books.',
      );
    } catch (e) {
      if (e is GoogleBooksException ||
          e is GoogleBooksQuotaException ||
          e is GoogleBooksNetworkException) {
        rethrow;
      }
      throw GoogleBooksException('Failed to load books: $e');
    }
  }

  /// Fetches real books for a specific category/subject from Google Books API
  Future<List<Book>> getBooksByCategory(
    String category, {
    int maxResults = 15,
  }) async {
    final query = 'subject:${category.toLowerCase().replaceAll(' ', '+')}';
    final cacheKey = 'cat_${category.toLowerCase()}_$maxResults';
    if (_queryCache.containsKey(cacheKey)) {
      return _queryCache[cacheKey]!;
    }

    final queryParameters = <String, String>{
      'q': query,
      'maxResults': maxResults.clamp(1, 40).toString(),
      'printType': 'books',
      'orderBy': 'relevance',
      if (_apiKey.isNotEmpty) 'key': _apiKey,
    };

    final uri = Uri.https('www.googleapis.com', '/books/v1/volumes', queryParameters);

    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode == 429) {
        throw GoogleBooksQuotaException(
          'Google Books request limit reached.',
        );
      }
      if (response.statusCode != 200) return [];

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return [];

      final items = decoded['items'];
      if (items is! List) return [];

      final books = items
          .whereType<Map<String, dynamic>>()
          .map(_bookFromVolume)
          .toList();

      _queryCache[cacheKey] = books;
      return books;
    } catch (e) {
      debugPrint('[GoogleBooksService] Error fetching category $category: $e');
      return [];
    }
  }

  /// Fetches curated featured books from Google Books
  Future<List<Book>> getFeaturedBooks({int maxResults = 12}) async {
    const cacheKey = 'featured_books';
    if (_queryCache.containsKey(cacheKey)) {
      return _queryCache[cacheKey]!;
    }

    final queryParameters = <String, String>{
      'q': 'subject:classic+literature',
      'maxResults': maxResults.clamp(1, 40).toString(),
      'printType': 'books',
      'orderBy': 'relevance',
      if (_apiKey.isNotEmpty) 'key': _apiKey,
    };

    final uri = Uri.https('www.googleapis.com', '/books/v1/volumes', queryParameters);

    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) return [];

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return [];

      final items = decoded['items'];
      if (items is! List) return [];

      final books = items
          .whereType<Map<String, dynamic>>()
          .map(_bookFromVolume)
          .toList();

      _queryCache[cacheKey] = books;
      return books;
    } catch (e) {
      debugPrint('[GoogleBooksService] Error fetching featured books: $e');
      return [];
    }
  }

  Book _bookFromVolume(Map<String, dynamic> volume) {
    final id = volume['id'] as String? ?? '';
    final info = volume['volumeInfo'] is Map<String, dynamic>
        ? volume['volumeInfo'] as Map<String, dynamic>
        : <String, dynamic>{};

    final authorsList = info['authors'] is List
        ? (info['authors'] as List).whereType<String>().toList()
        : <String>[];
    final categoriesList = info['categories'] is List
        ? (info['categories'] as List).whereType<String>().toList()
        : <String>[];

    final title = _cleanText(info['title'], fallback: 'Untitled Book');
    final author = authorsList.isEmpty ? 'Unknown author' : authorsList.join(', ');
    final description = _cleanText(
      info['description'],
      fallback: 'No description available for this book.',
    );
    final category = categoriesList.isEmpty ? 'General' : categoriesList.first;

    // Rating: only use real rating from API, never invent one
    final rating = info['averageRating'] is num
        ? (info['averageRating'] as num).toDouble()
        : 0.0;
    final ratingCount = info['ratingsCount'] is int ? info['ratingsCount'] as int : 0;

    // Image Links: sanitize and upgrade HTTP to HTTPS
    String? coverUrl;
    if (info['imageLinks'] is Map<String, dynamic>) {
      final images = info['imageLinks'] as Map<String, dynamic>;
      final rawUrl = images['thumbnail'] as String? ??
          images['smallThumbnail'] as String? ??
          images['medium'] as String? ??
          images['large'] as String?;
      if (rawUrl != null && rawUrl.isNotEmpty) {
        coverUrl = rawUrl.replaceFirst('http://', 'https://');
      }
    }

    // ISBN extraction
    String? isbn;
    if (info['industryIdentifiers'] is List) {
      for (final idItem in info['industryIdentifiers']) {
        if (idItem is Map<String, dynamic> && idItem['identifier'] is String) {
          isbn = idItem['identifier'] as String;
          break;
        }
      }
    }

    final publisher = info['publisher'] as String?;
    final publishedDate = info['publishedDate'] as String?;
    final pageCount = info['pageCount'] is int ? info['pageCount'] as int : null;
    final language = info['language'] as String?;

    return Book(
      id: id.isNotEmpty ? id : title.hashCode.abs().toString(),
      googleBooksId: id,
      title: title,
      author: author,
      description: description,
      category: category,
      rating: rating,
      ratingCount: ratingCount,
      accentColor: _accentColor(title),
      progress: 0.0,
      readingPosition: 0.0,
      chapterTitle: 'Full Text',
      readingText: description,
      isFavorite: false,
      isSaved: false,
      isCompleted: false,
      coverUrl: coverUrl,
      publisher: publisher,
      publishedDate: publishedDate,
      isbn: isbn,
      pageCount: pageCount,
      language: language,
    );
  }

  String _cleanText(dynamic value, {required String fallback}) {
    return value is String && value.trim().isNotEmpty ? value.trim() : fallback;
  }

  Color _accentColor(String title) {
    const colors = [
      Colors.indigo,
      Colors.teal,
      Colors.orange,
      Colors.pink,
      Colors.blueGrey,
      Colors.deepPurple,
      Colors.brown,
      Colors.blue,
    ];
    return colors[title.hashCode.abs() % colors.length];
  }
}

class GoogleBooksException implements Exception {
  final String message;
  GoogleBooksException(this.message);
  @override
  String toString() => message;
}

class GoogleBooksQuotaException implements Exception {
  final String message;
  GoogleBooksQuotaException(this.message);
  @override
  String toString() => message;
}

class GoogleBooksNetworkException implements Exception {
  final String message;
  GoogleBooksNetworkException(this.message);
  @override
  String toString() => message;
}
