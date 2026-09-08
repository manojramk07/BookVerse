import 'dart:async';

import 'package:flutter/material.dart';

import '../models/book_model.dart';
import '../services/app_state.dart';
import '../services/gutenberg_service.dart';
import '../services/local_book_service.dart';

class ReadingPage extends StatefulWidget {
  final Book book;

  const ReadingPage({super.key, required this.book});

  @override
  State<ReadingPage> createState() => _ReadingPageState();
}

class _ReadingPageState extends State<ReadingPage> {
  final GutenbergService _gutenbergService = GutenbergService();
  final LocalBookService _localBookService = LocalBookService();
  late final ScrollController _scrollController;

  bool isLoading = true;
  String? textContent;
  String? errorMessage;
  bool isBookmarked = false;
  double readingProgress = 0.0;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadBookContent();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _saveProgressImmediate();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadBookContent() async {
    final book = widget.book;
    final appState = AppStateScope.of(context);
    readingProgress = appState.progressFor(book);
    isBookmarked = appState.isBookFavorite(book.id);

    // 1. Check local assets (offline-first)
    final localBook = _localBookService.getBookById(book.id);
    final effectiveAssetPath = book.assetPath ?? localBook?.assetPath;
    if (effectiveAssetPath != null && effectiveAssetPath.isNotEmpty) {
      try {
        final targetBook = book.assetPath != null ? book : book.copyWith(assetPath: effectiveAssetPath);
        final text = await _localBookService.loadBookContent(targetBook);
        if (text.isNotEmpty) {
          if (!mounted) return;
          setState(() {
            textContent = text;
            isLoading = false;
          });
          _restoreScrollPosition();
          return;
        }
      } catch (e) {
        debugPrint('[ReadingPage] Error loading local asset: $e');
      }
    }

    // 2. If text is already embedded in the book model
    if (book.readingText.isNotEmpty && book.readingText.length > 500) {
      setState(() {
        textContent = book.readingText;
        isLoading = false;
      });
      _restoreScrollPosition();
      return;
    }

    // 3. Fallback to Project Gutenberg network fetch
    try {
      int? gutenbergId = book.gutenbergId;
      String? textUrl = book.gutenbergTextUrl;

      // If Gutenberg metadata is not yet attached, find it now
      if (gutenbergId == null || textUrl == null) {
        final match = await _gutenbergService.findMatch(
          title: book.title,
          author: book.author,
        );
        if (match != null) {
          gutenbergId = match.gutenbergId;
          textUrl = match.textUrl;
        }
      }

      if (gutenbergId == null || textUrl == null) {
        if (mounted) {
          setState(() {
            isLoading = false;
            errorMessage =
                'Full text is not available for this book.\n\nOnly public-domain books from Project Gutenberg are available for full in-app reading.';
          });
        }
        return;
      }

      final text = await _gutenbergService.fetchBookText(
        gutenbergId: gutenbergId,
        textUrl: textUrl,
      );

      if (!mounted) return;
      setState(() {
        textContent = text;
        isLoading = false;
      });

      _restoreScrollPosition();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load reading content: $e';
      });
    }
  }

  void _restoreScrollPosition() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final savedPos = AppStateScope.of(context).positionFor(widget.book);
      if (savedPos > 0 && savedPos <= _scrollController.position.maxScrollExtent) {
        _scrollController.jumpTo(savedPos);
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return;

    final currentOffset = _scrollController.offset;
    final currentProgress = (currentOffset / maxScroll).clamp(0.0, 1.0);

    setState(() {
      readingProgress = currentProgress;
    });

    // Debounce progress writes to storage/Firestore every 1.5 seconds
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 1500), () {
      _saveProgressImmediate();
    });
  }

  void _saveProgressImmediate() {
    if (!mounted || !_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final offset = _scrollController.offset;
    final progress = maxScroll > 0 ? (offset / maxScroll).clamp(0.0, 1.0) : 0.0;

    // Only record progress if the user actually scrolled/read something
    if (progress > 0.005) {
      AppStateScope.of(context).recordReadingProgress(
        book: widget.book,
        progress: progress,
        position: offset,
        isCompleted: progress >= 0.98,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final appState = AppStateScope.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          book.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            onPressed: () {
              appState.toggleFavorite(book);
              setState(() {
                isBookmarked = appState.isBookFavorite(book.id);
              });
            },
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? Colors.deepPurple : null,
            ),
            tooltip: 'Bookmark book',
          ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Loading book content...',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              )
            : errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_stories_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 18),
                          Text(
                            errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Back to Book Details'),
                          ),
                        ],
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.menu_book_rounded, color: Colors.deepPurple, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  book.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Text(
                                '${(readingProgress * 100).toInt()}%',
                                style: const TextStyle(
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: readingProgress,
                          minHeight: 5,
                          borderRadius: BorderRadius.circular(6),
                          backgroundColor: Colors.grey.shade200,
                          color: Colors.deepPurple,
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            padding: const EdgeInsets.only(bottom: 40, top: 8),
                            child: SelectableText(
                              textContent ?? '',
                              style: TextStyle(
                                fontSize: appState.fontSize,
                                height: 1.8,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
