import 'package:flutter/material.dart';

class Book {
  final String id;
  final String? googleBooksId;
  final int? gutenbergId;
  final String title;
  final String author;
  final String description;
  final String category;
  final double rating;
  final int ratingCount;
  final Color accentColor;
  final double progress;
  final double readingPosition;
  final String chapterTitle;
  final String readingText;
  final bool isFavorite;
  final bool isSaved;
  final bool isCompleted;
  final bool featured;
  final int popularity;
  final String? coverUrl;
  final String? publisher;
  final String? publishedDate;
  final String? isbn;
  final int? pageCount;
  final String? language;
  final bool hasGutenbergContent;
  final String? gutenbergTextUrl;
  final String? assetPath;
  String? get contentAssetPath => assetPath;
  final DateTime? lastReadAt;

  const Book({
    required this.id,
    this.googleBooksId,
    this.gutenbergId,
    required this.title,
    required this.author,
    required this.description,
    required this.category,
    required this.rating,
    this.ratingCount = 0,
    required this.accentColor,
    required this.progress,
    this.readingPosition = 0.0,
    required this.chapterTitle,
    required this.readingText,
    required this.isFavorite,
    required this.isSaved,
    required this.isCompleted,
    this.featured = false,
    this.popularity = 0,
    this.coverUrl,
    this.publisher,
    this.publishedDate,
    this.isbn,
    this.pageCount,
    this.language,
    this.hasGutenbergContent = false,
    this.gutenbergTextUrl,
    String? contentAssetPath,
    String? assetPath,
    this.lastReadAt,
  }) : assetPath = contentAssetPath ?? assetPath;

  Book copyWith({
    String? id,
    String? googleBooksId,
    int? gutenbergId,
    String? title,
    String? author,
    String? description,
    String? category,
    double? rating,
    int? ratingCount,
    Color? accentColor,
    double? progress,
    double? readingPosition,
    String? chapterTitle,
    String? readingText,
    bool? isFavorite,
    bool? isSaved,
    bool? isCompleted,
    bool? featured,
    int? popularity,
    String? coverUrl,
    String? publisher,
    String? publishedDate,
    String? isbn,
    int? pageCount,
    String? language,
    bool? hasGutenbergContent,
    String? gutenbergTextUrl,
    String? contentAssetPath,
    String? assetPath,
    DateTime? lastReadAt,
  }) {
    return Book(
      id: id ?? this.id,
      googleBooksId: googleBooksId ?? this.googleBooksId,
      gutenbergId: gutenbergId ?? this.gutenbergId,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      accentColor: accentColor ?? this.accentColor,
      progress: progress ?? this.progress,
      readingPosition: readingPosition ?? this.readingPosition,
      chapterTitle: chapterTitle ?? this.chapterTitle,
      readingText: readingText ?? this.readingText,
      isFavorite: isFavorite ?? this.isFavorite,
      isSaved: isSaved ?? this.isSaved,
      isCompleted: isCompleted ?? this.isCompleted,
      featured: featured ?? this.featured,
      popularity: popularity ?? this.popularity,
      coverUrl: coverUrl ?? this.coverUrl,
      publisher: publisher ?? this.publisher,
      publishedDate: publishedDate ?? this.publishedDate,
      isbn: isbn ?? this.isbn,
      pageCount: pageCount ?? this.pageCount,
      language: language ?? this.language,
      hasGutenbergContent: hasGutenbergContent ?? this.hasGutenbergContent,
      gutenbergTextUrl: gutenbergTextUrl ?? this.gutenbergTextUrl,
      assetPath: contentAssetPath ?? assetPath ?? this.assetPath,
      lastReadAt: lastReadAt ?? this.lastReadAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'googleBooksId': googleBooksId,
      'gutenbergId': gutenbergId,
      'title': title,
      'author': author,
      'description': description,
      'category': category,
      'rating': rating,
      'ratingCount': ratingCount,
      'accentColorValue': accentColor.toARGB32(),
      'progress': progress,
      'readingPosition': readingPosition,
      'chapterTitle': chapterTitle,
      'readingText': readingText,
      'isFavorite': isFavorite,
      'isSaved': isSaved,
      'isCompleted': isCompleted,
      'featured': featured,
      'popularity': popularity,
      'coverUrl': coverUrl,
      'publisher': publisher,
      'publishedDate': publishedDate,
      'isbn': isbn,
      'pageCount': pageCount,
      'language': language,
      'hasGutenbergContent': hasGutenbergContent,
      'gutenbergTextUrl': gutenbergTextUrl,
      'assetPath': assetPath,
      'contentAssetPath': assetPath,
      'lastReadAt': lastReadAt?.toIso8601String(),
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    final colorVal = json['accentColorValue'] is int
        ? json['accentColorValue'] as int
        : Colors.deepPurple.toARGB32();
    return Book(
      id: json['id'] as String? ?? '',
      googleBooksId: json['googleBooksId'] as String?,
      gutenbergId: json['gutenbergId'] as int?,
      title: json['title'] as String? ?? 'Untitled Book',
      author: json['author'] as String? ?? 'Unknown Author',
      description: json['description'] as String? ?? 'No description available.',
      category: json['category'] as String? ?? 'General',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: json['ratingCount'] as int? ?? 0,
      accentColor: Color(colorVal),
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      readingPosition: (json['readingPosition'] as num?)?.toDouble() ?? 0.0,
      chapterTitle: json['chapterTitle'] as String? ?? 'Full Text',
      readingText: json['readingText'] as String? ?? '',
      isFavorite: json['isFavorite'] as bool? ?? false,
      isSaved: json['isSaved'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      featured: json['featured'] as bool? ?? false,
      popularity: json['popularity'] as int? ?? 0,
      coverUrl: json['coverUrl'] as String?,
      publisher: json['publisher'] as String?,
      publishedDate: json['publishedDate'] as String?,
      isbn: json['isbn'] as String?,
      pageCount: json['pageCount'] as int?,
      language: json['language'] as String?,
      hasGutenbergContent: json['hasGutenbergContent'] as bool? ?? false,
      gutenbergTextUrl: json['gutenbergTextUrl'] as String?,
      assetPath: (json['contentAssetPath'] ?? json['assetPath']) as String?,
      lastReadAt: json['lastReadAt'] != null
          ? DateTime.tryParse(json['lastReadAt'] as String)
          : null,
    );
  }
}

/// Deprecated mock dataset list preserved as empty to prevent compilation issues
/// during refactoring. Real books are fetched live from Google Books & Gutenberg.
const List<Book> sampleBooks = [];
