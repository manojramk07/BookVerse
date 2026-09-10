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
    final libraryBooks = state.libraryBooks;
    final currentlyReading = state.currentlyReading;
    final favorites = state.favoriteBooks;
    final completed = state.completedBooks;

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

            // Section 1: Saved in Library
            _buildSectionHeader(
              title: 'Saved Library Books',
              count: libraryBooks.length,
              icon: Icons.bookmark_rounded,
              iconColor: const Color(0xFF5E35B1),
            ),
            const SizedBox(height: 12),
            if (libraryBooks.isNotEmpty)
              ...libraryBooks.map((book) => _buildBookTile(context, book, state))
            else
              _buildEmptySectionCard(
                context,
                icon: Icons.bookmark_border_rounded,
                title: 'No saved books yet',
                subtitle: 'Tap "Add to Library" on any book details page to save books here.',
                actionLabel: 'Discover Books',
                onAction: onNavigateTab != null ? () => onNavigateTab!(2) : null,
              ),

            const SizedBox(height: 28),

            // Section 2: Currently Reading Books
            _buildSectionHeader(
              title: 'Currently Reading Books',
              count: currentlyReading.length,
              icon: Icons.auto_stories,
              iconColor: const Color(0xFFD97706),
            ),
            const SizedBox(height: 12),
            if (currentlyReading.isNotEmpty)
              ...currentlyReading.map((book) => _buildBookTile(context, book, state))
            else
              _buildEmptySectionCard(
                context,
                icon: Icons.auto_stories_outlined,
                title: 'No books currently in progress',
                subtitle: 'Select any book from Home or Search to start reading.',
                actionLabel: 'Start Reading',
                onAction: onNavigateTab != null ? () => onNavigateTab!(0) : null,
              ),

            const SizedBox(height: 28),

            // Section 3: Favourite Books
            _buildSectionHeader(
              title: 'Favourite Books',
              count: favorites.length,
              icon: Icons.favorite,
              iconColor: Colors.redAccent,
            ),
            const SizedBox(height: 12),
            if (favorites.isNotEmpty)
              ...favorites.map((book) => _buildBookTile(context, book, state))
            else
              _buildEmptySectionCard(
                context,
                icon: Icons.favorite_border,
                title: 'No favourite books yet',
                subtitle: 'Tap the heart icon on any book details page to save it to your favourites.',
                actionLabel: 'Browse Books',
                onAction: onNavigateTab != null ? () => onNavigateTab!(2) : null,
              ),

            if (completed.isNotEmpty) ...[
              const SizedBox(height: 28),
              _buildSectionHeader(
                title: 'Completed Books',
                count: completed.length,
                icon: Icons.check_circle_outline,
                iconColor: const Color(0xFF10B981),
              ),
              const SizedBox(height: 12),
              ...completed.map((book) => _buildBookTile(context, book, state)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required int count,
    required IconData icon,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptySectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181B26) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF262C3D) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: onAction,
              child: Text(actionLabel, style: const TextStyle(fontSize: 12)),
            ),
          ],
        ],
      ),
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
