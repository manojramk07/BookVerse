import 'package:flutter/material.dart';

import '../../models/book_model.dart';
import '../../services/app_state.dart';
import '../../services/google_books_service.dart';
import '../../widgets/book_card.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/popular_book_card.dart';
import '../../widgets/recently_added_book.dart';
import '../../widgets/section_title.dart';
import '../achievement_page.dart';
import '../book_details_page.dart';
import '../reading_page.dart';
import '../streak_page.dart';

class HomePage extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const HomePage({super.key, this.onNavigateTab});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GoogleBooksService _booksService = GoogleBooksService();

  bool isLoadingFeatured = true;
  bool isLoadingCategory = false;
  String? featuredError;
  String? categoryError;

  List<Book> featuredBooks = [];
  List<Book> categoryBooks = [];
  String selectedCategory = 'Fiction';

  final List<String> categories = const [
    'Fiction',
    'Science',
    'History',
    'Mystery',
    'Philosophy',
    'Romance',
    'Fantasy',
    'Biography',
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      isLoadingFeatured = true;
      featuredError = null;
    });

    try {
      final featured = await _booksService.getFeaturedBooks(maxResults: 10);
      final catBooks = await _booksService.getBooksByCategory(selectedCategory, maxResults: 10);

      if (!mounted) return;
      setState(() {
        featuredBooks = featured;
        categoryBooks = catBooks;
        isLoadingFeatured = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoadingFeatured = false;
        featuredError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _onSelectCategory(String category) async {
    if (selectedCategory == category && categoryBooks.isNotEmpty) return;

    setState(() {
      selectedCategory = category;
      isLoadingCategory = true;
      categoryError = null;
    });

    try {
      final books = await _booksService.getBooksByCategory(category, maxResults: 10);
      if (!mounted) return;
      setState(() {
        categoryBooks = books;
        isLoadingCategory = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoadingCategory = false;
        categoryError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final continueReading = appState.currentlyReading;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadInitialData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: Welcome Greeting + Compact Streak & Achievements Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome to BookVerse',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Find your next favorite read',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Compact Streak Button
                      InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const StreakPage()),
                        ),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.local_fire_department,
                                color: Colors.deepOrange,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${appState.currentStreak}',
                                style: const TextStyle(
                                  color: Colors.deepOrange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Compact Achievements Button
                      InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AchievementPage()),
                        ),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.emoji_events_outlined,
                            color: Colors.deepPurple,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Search Input Container (Tapping directs to Search)
              InkWell(
                onTap: () {
                  if (widget.onNavigateTab != null) {
                    widget.onNavigateTab!(2); // Switch to Search tab
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.deepPurple),
                      const SizedBox(width: 12),
                      Text(
                        'Search books, authors...',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),

              // Continue Reading Section (Only shown if user actually has reading in progress)
              if (continueReading.isNotEmpty) ...[
                const SectionTitle(title: 'Continue Reading'),
                const SizedBox(height: 12),
                SizedBox(
                  height: 230,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: continueReading.length,
                    itemBuilder: (context, index) {
                      final book = continueReading[index];
                      return BookCard(
                        title: book.title,
                        author: book.author,
                        color: book.accentColor,
                        progress: appState.progressFor(book),
                        coverUrl: book.coverUrl,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReadingPage(book: book),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Featured / Curated Books from Google Books API
              const SectionTitle(title: 'Featured Classics'),
              const SizedBox(height: 12),
              if (isLoadingFeatured)
                const SizedBox(
                  height: 230,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (featuredError != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Text(
                        featuredError!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _loadInitialData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              else if (featuredBooks.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('No featured books found.'),
                )
              else
                SizedBox(
                  height: 250,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: featuredBooks.length,
                    itemBuilder: (context, index) {
                      final book = featuredBooks[index];
                      return PopularBookCard(
                        rank: '${index + 1}',
                        title: book.title,
                        author: book.author,
                        rating: book.rating > 0 ? book.rating.toStringAsFixed(1) : '—',
                        color: book.accentColor,
                        coverUrl: book.coverUrl,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookDetailsPage(book: book),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              const SizedBox(height: 26),

              // Categories Exploration
              const Text(
                'Explore by Genre',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((cat) {
                  return CategoryChip(
                    title: cat,
                    icon: _iconForCategory(cat),
                    isSelected: selectedCategory == cat,
                    onTap: () => _onSelectCategory(cat),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Category Books Feed
              if (isLoadingCategory)
                const SizedBox(
                  height: 160,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (categoryError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    categoryError!,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                )
              else if (categoryBooks.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text('No books found for $selectedCategory.'),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categoryBooks.length,
                  itemBuilder: (context, index) {
                    final book = categoryBooks[index];
                    return RecentlyAddedBook(
                      title: book.title,
                      author: book.author,
                      date: book.category,
                      color: book.accentColor,
                      coverUrl: book.coverUrl,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookDetailsPage(book: book),
                          ),
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'fiction':
        return Icons.auto_stories;
      case 'science':
        return Icons.science;
      case 'history':
        return Icons.history_edu;
      case 'mystery':
        return Icons.search;
      case 'philosophy':
        return Icons.psychology;
      case 'romance':
        return Icons.favorite;
      case 'fantasy':
        return Icons.auto_awesome;
      case 'biography':
        return Icons.person;
      default:
        return Icons.book;
    }
  }
}
