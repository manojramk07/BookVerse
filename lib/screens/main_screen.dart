import 'package:flutter/material.dart';

import 'home/home_page.dart';
import 'library/library_page.dart';
import 'profile/profile_page.dart';
import 'search/search_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  void _onNavigateTab(int index) {
    setState(() {
      selectedIndex = index.clamp(0, 3);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(onNavigateTab: _onNavigateTab),
      LibraryPage(onNavigateTab: _onNavigateTab),
      const SearchPage(),
      ProfilePage(onNavigateTab: _onNavigateTab),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF262C3D) : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: _onNavigateTab,
          backgroundColor: isDark ? const Color(0xFF12141F) : Colors.white,
          indicatorColor: isDark ? const Color(0xFF31265B) : const Color(0xFFEDE7F6),
          surfaceTintColor: Colors.transparent,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_books_outlined),
            selectedIcon: Icon(Icons.library_books),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        ),
      ),
    );
  }
}
