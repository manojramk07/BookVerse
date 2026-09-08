import 'package:flutter/material.dart';

import '../../models/book_model.dart';
import '../../services/app_state.dart';
import '../../widgets/library_book.dart';
import '../book_details_page.dart';

class LibraryPage extends StatelessWidget {
  final ValueChanged<int>? onNavigateTab;

  const LibraryPage({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final currentlyReading = state.currentlyReading;
    final favorites = state.favoriteBooks;
    final completed = state.completedBooks;
    final allSaved = state.libraryBooks;

    final isLibraryCompletelyEmpty =
        currentlyReading.isEmpty && favorites.isEmpty && completed.isEmpty && allSaved.isEmpty;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Library',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Your personal saved books and reading history',
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
            const SizedBox(height: 24),

            if (isLibraryCompletelyEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.collections_bookmark_outlined,
                        size: 72,
                        color: Colors.deepPurple.shade200,
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Your library is empty',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Add books from Search or Home to build your reading collection.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () {
                          if (onNavigateTab != null) {
                            onNavigateTab!(2); // Switch to Search tab
                          }
                        },
                        icon: const Icon(Icons.search),
                        label: const Text('Discover Books'),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // Currently Reading Section
              if (currentlyReading.isNotEmpty) ...[
                _buildSectionTitle('Currently Reading (${currentlyReading.length})'),
                const SizedBox(height: 10),
                ...currentlyReading.map((book) => _buildBookTile(context, book, state)),
                const SizedBox(height: 20),
              ],

              // Favorites Section
              if (favorites.isNotEmpty) ...[
                _buildSectionTitle('Favorite Books (${favorites.length})'),
                const SizedBox(height: 10),
                ...favorites.map((book) => _buildBookTile(context, book, state)),
                const SizedBox(height: 20),
              ],

              // Completed Section
              if (completed.isNotEmpty) ...[
                _buildSectionTitle('Completed Books (${completed.length})'),
                const SizedBox(height: 10),
                ...completed.map((book) => _buildBookTile(context, book, state)),
                const SizedBox(height: 20),
              ],

              // Saved Books
              if (allSaved.isNotEmpty) ...[
                _buildSectionTitle('All Saved Books (${allSaved.length})'),
                const SizedBox(height: 10),
                ...allSaved.map((book) => _buildBookTile(context, book, state)),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildBookTile(BuildContext context, Book book, AppState state) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => BookDetailsPage(book: book)),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: LibraryBook(
          title: book.title,
          author: book.author,
          progress: state.progressFor(book),
          color: book.accentColor,
          coverUrl: book.coverUrl,
        ),
      ),
    );
  }
}
