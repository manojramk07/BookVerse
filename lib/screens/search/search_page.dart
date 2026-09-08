import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/book_model.dart';
import '../../services/google_books_service.dart';
import '../book_details_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final GoogleBooksService _booksService = GoogleBooksService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Book> searchResults = [];
  String currentQuery = '';
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;
  String? errorMessage;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !isLoading &&
        !isLoadingMore &&
        hasMore &&
        currentQuery.isNotEmpty) {
      _loadMore();
    }
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

    _debounceTimer = Timer(const Duration(milliseconds: 600), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      currentQuery = query;
      isLoading = true;
      errorMessage = null;
      hasMore = true;
    });

    try {
      final results = await _booksService.searchBooks(query, startIndex: 0, maxResults: 20);
      if (!mounted) return;
      setState(() {
        searchResults = results;
        isLoading = false;
        hasMore = results.length >= 20;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        searchResults = [];
        isLoading = false;
        errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _loadMore() async {
    if (isLoadingMore || !hasMore || currentQuery.isEmpty) return;

    setState(() => isLoadingMore = true);

    try {
      final moreBooks = await _booksService.searchBooks(
        currentQuery,
        startIndex: searchResults.length,
        maxResults: 20,
      );
      if (!mounted) return;
      setState(() {
        searchResults.addAll(moreBooks);
        isLoadingMore = false;
        hasMore = moreBooks.length >= 20;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoadingMore = false);
    }
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Search',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onChanged: _onTextChanged,
              onSubmitted: (val) {
                _debounceTimer?.cancel();
                _performSearch(val.trim());
              },
              decoration: InputDecoration(
                hintText: 'Search for books or authors...',
                prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: _clearSearch,
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
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
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.menu_book_rounded,
                                    size: 64,
                                    color: Colors.deepPurple.shade100,
                                  ),
                                  const SizedBox(height: 14),
                                  const Text(
                                    'Discover books by title, author, or keyword',
                                    style: TextStyle(fontSize: 16, color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : searchResults.isEmpty
                              ? Center(
                                  child: Text(
                                    'No books found for "$currentQuery".\nTry a different title or author.',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
                                  ),
                                )
                              : ListView.builder(
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
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
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
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                          book.author,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
                                  },
                                ),
            ),
          ],
        ),
      ),
    );
  }
}
