import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GutenbergMatch {
  final int gutenbergId;
  final String title;
  final String author;
  final String textUrl;
  final int downloadCount;

  const GutenbergMatch({
    required this.gutenbergId,
    required this.title,
    required this.author,
    required this.textUrl,
    required this.downloadCount,
  });
}

class GutenbergService {
  GutenbergService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const String _gutendexBase = 'https://gutendex.com/books';

  // In-memory cache for book text and matches to avoid redundant network calls
  static final Map<int, String> _textCache = {};
  static final Map<String, GutenbergMatch?> _matchCache = {};

  /// Normalizes a string for fuzzy matching (lowercase, alphanumeric only)
  static String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'^(the|a|an)\s+', caseSensitive: false), '')
        .replaceAll(RegExp(r'[:\-–—].*$'), '') // Remove subtitle
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .trim();
  }

  /// Extracts individual words for keyword intersection matching
  static Set<String> _words(String input) {
    return _normalize(input)
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 2)
        .toSet();
  }

  /// Attempts to find a confident Project Gutenberg match for a given title and author.
  Future<GutenbergMatch?> findMatch({
    required String title,
    required String author,
  }) async {
    final cacheKey = '$title::$author'.toLowerCase();
    if (_matchCache.containsKey(cacheKey)) {
      return _matchCache[cacheKey];
    }

    try {
      final cleanAuthor = author.toLowerCase() == 'unknown author' ? '' : author;
      final searchQuery = cleanAuthor.isNotEmpty ? '$title $cleanAuthor' : title;
      final uri = Uri.parse('$_gutendexBase/?search=${Uri.encodeComponent(searchQuery)}');

      final response = await _client.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        _matchCache[cacheKey] = null;
        return null;
      }

      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic> || data['results'] is! List) {
        _matchCache[cacheKey] = null;
        return null;
      }

      final results = data['results'] as List;
      final targetTitleWords = _words(title);
      final targetAuthorWords = _words(cleanAuthor);

      for (final item in results) {
        if (item is! Map<String, dynamic>) continue;

        final itemTitle = item['title'] as String? ?? '';
        final itemTitleWords = _words(itemTitle);

        // Check title word overlap
        final sharedTitleWords = targetTitleWords.intersection(itemTitleWords);
        final titleRatio = targetTitleWords.isEmpty
            ? 0.0
            : sharedTitleWords.length / targetTitleWords.length;

        // Author matching: check authors list
        final authorsList = item['authors'] as List? ?? [];
        final itemAuthorNames = authorsList
            .map((a) => (a is Map ? a['name'] as String? ?? '' : ''))
            .join(' ');
        final itemAuthorWords = _words(itemAuthorNames);

        bool authorMatches = false;
        if (targetAuthorWords.isEmpty) {
          authorMatches = true; // Author was unspecified
        } else {
          final sharedAuthorWords = targetAuthorWords.intersection(itemAuthorWords);
          authorMatches = sharedAuthorWords.isNotEmpty;
        }

        // Strict criteria: at least 60% of title words match AND author matches (or high title match > 80%)
        if ((titleRatio >= 0.6 && authorMatches) || titleRatio >= 0.85) {
          final formats = item['formats'] as Map<String, dynamic>? ?? {};
          final id = item['id'] as int? ?? 0;

          // Find text format
          String? textUrl = formats['text/plain; charset=utf-8'] as String? ??
              formats['text/plain; charset=us-ascii'] as String? ??
              formats['text/plain'] as String?;

          // Fallback to standard Gutenberg archive text URL
          if (textUrl == null && id > 0) {
            textUrl = 'https://www.gutenberg.org/cache/epub/$id/pg$id.txt';
          }

          if (textUrl != null) {
            final match = GutenbergMatch(
              gutenbergId: id,
              title: itemTitle,
              author: itemAuthorNames,
              textUrl: textUrl,
              downloadCount: item['download_count'] as int? ?? 0,
            );
            _matchCache[cacheKey] = match;
            return match;
          }
        }
      }

      _matchCache[cacheKey] = null;
      return null;
    } catch (e) {
      debugPrint('[GutenbergService] Error searching Gutenberg: $e');
      return null;
    }
  }

  /// Downloads, cleans, and caches the plain text of a Project Gutenberg book.
  Future<String> fetchBookText({
    required int gutenbergId,
    required String textUrl,
  }) async {
    // 1. Check in-memory cache
    if (_textCache.containsKey(gutenbergId)) {
      return _textCache[gutenbergId]!;
    }

    // 2. Check local SharedPreferences cache
    final prefs = await SharedPreferences.getInstance();
    final prefKey = 'gutenberg_text_$gutenbergId';
    final savedText = prefs.getString(prefKey);
    if (savedText != null && savedText.isNotEmpty) {
      _textCache[gutenbergId] = savedText;
      return savedText;
    }

    // 3. Download over network
    try {
      final response = await _client.get(Uri.parse(textUrl)).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw GutenbergException('HTTP ${response.statusCode}: Failed to fetch book text from Project Gutenberg.');
      }

      final rawText = utf8.decode(response.bodyBytes, allowMalformed: true);
      final cleanedText = _cleanGutenbergBoilerplate(rawText);

      // Cache locally
      _textCache[gutenbergId] = cleanedText;
      // Truncate if extremely large for prefs safety (max 2MB per book in prefs)
      if (cleanedText.length < 2000000) {
        await prefs.setString(prefKey, cleanedText);
      }

      return cleanedText;
    } catch (e) {
      if (e is GutenbergException) rethrow;
      throw GutenbergException('Network error loading book text: $e');
    }
  }

  /// Strips the Project Gutenberg legal header and footer boilerplate.
  static String _cleanGutenbergBoilerplate(String text) {
    var content = text;

    // Header pattern
    final startPatterns = [
      RegExp(r'\*\*\*\s*START OF TH(E|IS) PROJECT GUTENBERG EBOOK[^\r\n]*\*\*\*', caseSensitive: false),
      RegExp(r'\*\*\*\s*START OF PROJECT GUTENBERG EBOOK[^\r\n]*\*\*\*', caseSensitive: false),
    ];

    for (final pattern in startPatterns) {
      final match = pattern.firstMatch(content);
      if (match != null) {
        content = content.substring(match.end).trim();
        break;
      }
    }

    // Footer pattern
    final endPatterns = [
      RegExp(r'\*\*\*\s*END OF TH(E|IS) PROJECT GUTENBERG EBOOK[^\r\n]*\*\*\*', caseSensitive: false),
      RegExp(r'\*\*\*\s*END OF PROJECT GUTENBERG EBOOK[^\r\n]*\*\*\*', caseSensitive: false),
      RegExp(r'End of the Project Gutenberg', caseSensitive: false),
    ];

    for (final pattern in endPatterns) {
      final match = pattern.firstMatch(content);
      if (match != null) {
        content = content.substring(0, match.start).trim();
        break;
      }
    }

    return content;
  }
}

class GutenbergException implements Exception {
  final String message;
  GutenbergException(this.message);

  @override
  String toString() => message;
}
