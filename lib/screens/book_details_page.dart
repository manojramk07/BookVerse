import 'package:flutter/material.dart';

import '../models/book_model.dart';
import '../services/app_state.dart';
import '../services/gutenberg_service.dart';
import 'reading_page.dart';

class BookDetailsPage extends StatefulWidget {
  final Book book;

  const BookDetailsPage({super.key, required this.book});

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  final GutenbergService _gutenbergService = GutenbergService();
  late Book currentBook;
  bool isCheckingGutenberg = true;
  GutenbergMatch? gutenbergMatch;

  @override
  void initState() {
    super.initState();
    currentBook = widget.book;
    _checkGutenbergAvailability();
  }

  Future<void> _checkGutenbergAvailability() async {
    // If book already knows its gutenberg status, skip search
    if (currentBook.hasGutenbergContent && currentBook.gutenbergTextUrl != null) {
      if (mounted) setState(() => isCheckingGutenberg = false);
      return;
    }

    final match = await _gutenbergService.findMatch(
      title: currentBook.title,
      author: currentBook.author,
    );

    if (mounted) {
      setState(() {
        isCheckingGutenberg = false;
        gutenbergMatch = match;
        if (match != null) {
          currentBook = currentBook.copyWith(
            hasGutenbergContent: true,
            gutenbergId: match.gutenbergId,
            gutenbergTextUrl: match.textUrl,
          );
        }
      });
    }
  }

  void _onReadTapped(BuildContext context) {
    if (currentBook.hasGutenbergContent && currentBook.gutenbergTextUrl != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReadingPage(book: currentBook),
        ),
      );
    } else {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Full Text Unavailable'),
          content: const Text(
            'Full text is not available for this book.\n\n'
            'Only public-domain books catalogued on Project Gutenberg can be read inside the app.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Understood'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final isInLibrary = appState.isBookInLibrary(currentBook.id);
    final isFavorite = appState.isBookFavorite(currentBook.id);
    final progress = appState.progressFor(currentBook);
    final isPartiallyRead = progress > 0.01 && progress < 0.99;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Book Details'),
        actions: [
          IconButton(
            onPressed: () => appState.toggleFavorite(currentBook),
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
            tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Hero(
                  tag: 'book_cover_${currentBook.id}',
                  child: Container(
                    width: 180,
                    height: 250,
                    decoration: BoxDecoration(
                      color: currentBook.accentColor,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: currentBook.accentColor.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: currentBook.coverUrl != null && currentBook.coverUrl!.isNotEmpty
                          ? Image.network(
                              currentBook.coverUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Center(
                                child: Icon(
                                  Icons.menu_book_rounded,
                                  size: 64,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            )
                          : Center(
                              child: Icon(
                                Icons.menu_book_rounded,
                                size: 64,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                currentBook.title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'by ${currentBook.author}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 14),

              // Metadata Chips Row
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (currentBook.rating > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            currentBook.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          if (currentBook.ratingCount > 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              '(${currentBook.ratingCount})',
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      currentBook.category,
                      style: const TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (currentBook.pageCount != null && currentBook.pageCount! > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${currentBook.pageCount} pages',
                        style: const TextStyle(color: Colors.black87, fontSize: 13),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),

              // Gutenberg Availability Status Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isCheckingGutenberg
                      ? Colors.grey.shade100
                      : currentBook.hasGutenbergContent
                          ? Colors.green.shade50
                          : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCheckingGutenberg
                        ? Colors.grey.shade300
                        : currentBook.hasGutenbergContent
                            ? Colors.green.shade200
                            : Colors.orange.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    if (isCheckingGutenberg)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Icon(
                        currentBook.hasGutenbergContent
                            ? Icons.check_circle_outline
                            : Icons.info_outline,
                        size: 18,
                        color: currentBook.hasGutenbergContent
                            ? Colors.green.shade700
                            : Colors.orange.shade800,
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isCheckingGutenberg
                            ? 'Checking Project Gutenberg reader availability...'
                            : currentBook.hasGutenbergContent
                                ? 'Full text available via Project Gutenberg'
                                : 'Full text not available (metadata only)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isCheckingGutenberg
                              ? Colors.grey.shade700
                              : currentBook.hasGutenbergContent
                                  ? Colors.green.shade800
                                  : Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (progress > 0) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Your Progress',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                currentBook.description,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),

              if (currentBook.publisher != null || currentBook.publishedDate != null) ...[
                const SizedBox(height: 20),
                const Text(
                  'Publication Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                if (currentBook.publisher != null)
                  Text(
                    'Publisher: ${currentBook.publisher}',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                if (currentBook.publishedDate != null)
                  Text(
                    'Published: ${currentBook.publishedDate}',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                if (currentBook.isbn != null)
                  Text(
                    'ISBN: ${currentBook.isbn}',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
              ],

              const SizedBox(height: 28),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _onReadTapped(context),
                      icon: const Icon(Icons.menu_book_rounded),
                      label: Text(
                        isPartiallyRead ? 'Continue Reading' : 'Read Now',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    appState.toggleLibrary(currentBook);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isInLibrary
                              ? 'Removed from your library'
                              : 'Added to your library',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: Icon(
                    isInLibrary ? Icons.bookmark_remove : Icons.library_add,
                    color: isInLibrary ? Colors.red : Colors.deepPurple,
                  ),
                  label: Text(
                    isInLibrary ? 'Remove from Library' : 'Add to Library',
                    style: TextStyle(
                      color: isInLibrary ? Colors.red : Colors.deepPurple,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
