import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/book_model.dart';
import '../../services/local_book_service.dart';
import '../book_details_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final LocalBookService _localBookService = LocalBookService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Book> searchResults = [];
  String currentQuery = '';
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMore = false;
  String? errorMessage;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    _debounceTimer?.cancel();
    final query = value.trim();
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        currentQuery = '';
        errorMessage = null;
        isLoading = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 150), () {
      _performSearch(query);
    });
  }

  void _performSearch(String query) {
    if (query.isEmpty) return;

    final results = _localBookService.searchBooks(query);
    setState(() {
      currentQuery = query;
      searchResults = results;
      isLoading = false;
      errorMessage = null;
      hasMore = false;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      searchResults = [];
      currentQuery = '';
      errorMessage = null;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalAppBooks = _localBookService.getAllBooks().length;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Search',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF211D36) : const Color(0xFFEDE7F6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? const Color(0xFF3A315C) : const Color(0xFFD1C4E9),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.menu_book, size: 16, color: Colors.deepPurple),
                      const SizedBox(width: 6),
                      Text(
                        'Total: $totalAppBooks Books',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Browse all $totalAppBooks books available offline',
              style: TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              onChanged: _onTextChanged,
              onSubmitted: (val) {
                _debounceTimer?.cancel();
                _performSearch(val.trim());
              },
              decoration: InputDecoration(
                hintText: 'Search books, authors, or genres...',
                hintStyle: TextStyle(
                  color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade500,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: isDark ? const Color(0xFF94A3B8) : Colors.grey),
                        onPressed: _clearSearch,
                      )
                    : null,
                filled: true,
                fillColor: isDark ? const Color(0xFF181B26) : Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF262C3D) : const Color(0xFFE2E8F0),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.deepPurple, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.red.shade400,
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 16, height: 1.4),
                                ),
                                const SizedBox(height: 16),
                                FilledButton.icon(
                                  onPressed: () => _performSearch(currentQuery),
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Retry Search'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : currentQuery.isEmpty
                          ? _buildDefaultBooksSection(context)
                          : searchResults.isEmpty
                              ? Center(
                                  child: Text(
                                    'No books found for "$currentQuery".\nTry a different title or author.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                                      height: 1.5,
                                    ),
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Text(
                                        'Found ${searchResults.length} of $totalAppBooks books',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: ListView.builder(
                                        controller: _scrollController,
                                        itemCount: searchResults.length + (isLoadingMore ? 1 : 0),
                                        itemBuilder: (context, index) {
                                          if (index == searchResults.length) {
                                            return const Padding(
                                              padding: EdgeInsets.symmetric(vertical: 16),
                                              child: Center(child: CircularProgressIndicator()),
                                            );
                                          }

                                          final book = searchResults[index];
                                          return _buildBookItemCard(context, book);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultBooksSection(BuildContext context) {
    final allBooks = _localBookService.getAllBooks();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.explore_outlined, color: Colors.deepPurple, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'All Books in App',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF211D36) : Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${allBooks.length} available',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...allBooks.map((book) => _buildBookItemCard(context, book)),
      ],
    );
  }

  Widget _buildBookItemCard(BuildContext context, Book book) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? const Color(0xFF181B26) : Colors.white,
      elevation: isDark ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDark ? const Color(0xFF262C3D) : const Color(0xFFE2E8F0),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 48,
            height: 64,
            decoration: BoxDecoration(
              color: book.accentColor,
            ),
            child: book.coverUrl != null && book.coverUrl!.isNotEmpty
                ? Image.network(
                    book.coverUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.book, color: Colors.white),
                    ),
                  )
                : const Center(
                    child: Icon(Icons.book, color: Colors.white),
                  ),
          ),
        ),
        title: Text(
          book.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                book.author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withValues(alpha: isDark ? 0.25 : 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                book.category,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? const Color(0xFFB39DDB) : Colors.deepPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookDetailsPage(book: book),
            ),
          );
        },
      ),
    );
  }
}
