import 'package:flutter/material.dart';

import 'screens/main_screen.dart';
import 'services/app_state.dart';

class BookVerseApp extends StatefulWidget {
  const BookVerseApp({super.key});

  @override
  State<BookVerseApp> createState() => _BookVerseAppState();
}

class _BookVerseAppState extends State<BookVerseApp> {
  late final Future<AppState> _state = AppState.load();

  // Cached ThemeDatas to prevent recomputing ColorScheme.fromSeed on every rebuild/theme switch
  static final ThemeData _lightTheme = _createTheme(Brightness.light);
  static final ThemeData _darkTheme = _createTheme(Brightness.dark);

  static ThemeData _createTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF673AB7),
      brightness: brightness,
      surface: isLight ? Colors.white : const Color(0xFF181B26),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          isLight ? const Color(0xFFF8F7FC) : const Color(0xFF0F111A),
      cardColor: isLight ? Colors.white : const Color(0xFF181B26),
      dialogTheme: DialogThemeData(
        backgroundColor: isLight ? Colors.white : const Color(0xFF181B26),
      ),
      dividerColor: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF262C3D),
      cardTheme: CardThemeData(
        color: isLight ? Colors.white : const Color(0xFF181B26),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF262C3D),
            width: 1,
          ),
        ),
      ),
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(
          color: isLight ? const Color(0xFF1E1B26) : const Color(0xFFEDEAF4),
        ),
        titleTextStyle: TextStyle(
          color: isLight ? const Color(0xFF1E1B26) : const Color(0xFFEDEAF4),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppState>(
      future: _state,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
        final appState = snapshot.data!;
        return AppStateScope(
          notifier: appState,
          child: ListenableBuilder(
            listenable: appState,
            builder: (context, child) => MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'BookVerse',
              themeMode: appState.themeMode,
              theme: _lightTheme,
              darkTheme: _darkTheme,
              themeAnimationDuration: const Duration(milliseconds: 120),
              themeAnimationCurve: Curves.easeOutCubic,
              home: child,
            ),
            child: const MainScreen(),
          ),
        );
      },
    );
  }
}
