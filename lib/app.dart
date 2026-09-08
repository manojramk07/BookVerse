import 'package:flutter/material.dart';

import 'services/app_state.dart';
import 'screens/main_screen.dart';

class BookVerseApp extends StatefulWidget {
  const BookVerseApp({super.key});

  @override
  State<BookVerseApp> createState() => _BookVerseAppState();
}

class _BookVerseAppState extends State<BookVerseApp> {
  late final Future<AppState> _state = AppState.load();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppState>(
      future: _state,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));
        }
        final appState = snapshot.data!;
        return AppStateScope(
          notifier: appState,
          child: AnimatedBuilder(
            animation: appState,
            builder: (context, _) => MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'BookVerse',
              themeMode: appState.themeMode,
              theme: _theme(Brightness.light),
              darkTheme: _theme(Brightness.dark),
              home: const MainScreen(),
            ),
          ),
        );
      },
    );
  }

  ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: brightness);
    return ThemeData(useMaterial3: true, colorScheme: scheme, scaffoldBackgroundColor: brightness == Brightness.light ? const Color(0xFFF8F7FC) : const Color(0xFF15131A), fontFamily: 'Roboto');
  }
}
