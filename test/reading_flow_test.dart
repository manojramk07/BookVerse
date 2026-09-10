import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/models/book_model.dart';
import 'package:my_app/screens/book_details_page.dart';
import 'package:my_app/screens/reading_page.dart';
import 'package:my_app/services/app_state.dart';
import 'package:my_app/services/local_book_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppState appState;
  final localBookService = LocalBookService();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    appState = await AppState.load();
  });

  Widget testPdfViewer(BuildContext context, String assetPath, PdfViewerController controller) {
    return Container(
      key: const Key('pdf_viewer_widget'),
      child: Text('PDF Asset: $assetPath'),
    );
  }

  Widget createTestApp(Widget home) {
    return AppStateScope(
      notifier: appState,
      child: MaterialApp(
        home: home,
      ),
    );
  }

  group('Requirement G: Full Reading Flow Tests for Real PDF Books', () {
    testWidgets('Pride and Prejudice: Details -> Read -> Reader -> Real PDF', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final book = localBookService.getBookById('pride_and_prejudice');
      expect(book, isNotNull);
      expect(book!.title, equals('Pride and Prejudice'));
      expect(book.assetPath, equals('assets/books/pride_and_prejudice.pdf'));

      // 1. Open BookDetailsPage
      await tester.pumpWidget(createTestApp(BookDetailsPage(
        book: book,
        pdfViewerBuilder: testPdfViewer,
      )));
      await tester.pumpAndSettle();

      expect(find.text('Pride and Prejudice'), findsWidgets);
      expect(find.textContaining('Jane Austen'), findsWidgets);
      expect(find.textContaining('Full classic book available offline (PDF)'), findsOneWidget);

      // 2. Find and tap 'Read Now'
      final readButton = find.widgetWithText(FilledButton, 'Read Now');
      expect(readButton, findsOneWidget);
      await tester.ensureVisible(readButton);
      await tester.tap(readButton);
      await tester.pumpAndSettle();

      // 3. Verify Reader opened
      expect(find.byType(ReadingPage), findsOneWidget);

      // 4. Verify actual PDF asset path of Pride and Prejudice is loaded
      expect(find.text('PDF Asset: assets/books/pride_and_prejudice.pdf'), findsOneWidget);
      expect(find.byKey(const Key('pdf_viewer_widget')), findsOneWidget);
    });

    testWidgets('Dracula: Details -> Read -> Reader -> Real PDF', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final book = localBookService.getBookById('dracula');
      expect(book, isNotNull);
      expect(book!.title, equals('Dracula'));
      expect(book.assetPath, equals('assets/books/dracula.pdf'));

      // 1. Open BookDetailsPage
      await tester.pumpWidget(createTestApp(BookDetailsPage(
        book: book,
        pdfViewerBuilder: testPdfViewer,
      )));
      await tester.pumpAndSettle();

      expect(find.text('Dracula'), findsWidgets);
      expect(find.textContaining('Bram Stoker'), findsWidgets);

      // 2. Find and tap 'Read Now'
      final readButton = find.widgetWithText(FilledButton, 'Read Now');
      expect(readButton, findsOneWidget);
      await tester.ensureVisible(readButton);
      await tester.tap(readButton);
      await tester.pumpAndSettle();

      // 3. Verify Reader opened
      expect(find.byType(ReadingPage), findsOneWidget);

      // 4. Verify actual PDF asset path of Dracula is loaded
      expect(find.text('PDF Asset: assets/books/dracula.pdf'), findsOneWidget);
    });

    testWidgets('The Adventures of Sherlock Holmes: Details -> Read -> Reader -> Real PDF', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final book = localBookService.getBookById('sherlock_holmes');
      expect(book, isNotNull);
      expect(book!.title, equals('The Adventures of Sherlock Holmes'));
      expect(book.assetPath, equals('assets/books/adventures_of_sherlock_holmes.pdf'));

      // 1. Open BookDetailsPage
      await tester.pumpWidget(createTestApp(BookDetailsPage(
        book: book,
        pdfViewerBuilder: testPdfViewer,
      )));
      await tester.pumpAndSettle();

      expect(find.text('The Adventures of Sherlock Holmes'), findsWidgets);
      expect(find.textContaining('Arthur Conan Doyle'), findsWidgets);

      // 2. Find and tap 'Read Now'
      final readButton = find.widgetWithText(FilledButton, 'Read Now');
      expect(readButton, findsOneWidget);
      await tester.ensureVisible(readButton);
      await tester.tap(readButton);
      await tester.pumpAndSettle();

      // 3. Verify Reader opened
      expect(find.byType(ReadingPage), findsOneWidget);

      // 4. Verify actual PDF asset of Sherlock Holmes is loaded
      expect(find.text('PDF Asset: assets/books/adventures_of_sherlock_holmes.pdf'), findsOneWidget);
    });

    testWidgets('Search -> Book Details -> Read -> Reader flow for Sherlock PDF', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Test Search for Sherlock
      final searchResults = localBookService.searchBooks('Sherlock');
      expect(searchResults, isNotEmpty);
      final foundSherlock = searchResults.first;
      expect(foundSherlock.title, contains('Sherlock Holmes'));

      await tester.pumpWidget(createTestApp(BookDetailsPage(
        book: foundSherlock,
        pdfViewerBuilder: testPdfViewer,
      )));
      await tester.pumpAndSettle();

      final readButton = find.widgetWithText(FilledButton, 'Read Now');
      expect(readButton, findsOneWidget);
      await tester.ensureVisible(readButton);
      await tester.tap(readButton);
      await tester.pumpAndSettle();

      expect(find.byType(ReadingPage), findsOneWidget);
      expect(find.text('PDF Asset: assets/books/adventures_of_sherlock_holmes.pdf'), findsOneWidget);
    });

    testWidgets('User-facing error when asset is unreadable shows "Unable to open this book." with Retry and Back', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const invalidBook = Book(
        id: 'nonexistent_test_book',
        title: 'Missing Book',
        author: 'Ghost Writer',
        description: 'Test book without valid file',
        category: 'Mystery',
        rating: 4.0,
        accentColor: Colors.purple,
        progress: 0.0,
        chapterTitle: 'Chapter 1',
        readingText: '',
        isFavorite: false,
        isSaved: false,
        isCompleted: false,
        assetPath: 'assets/books/nonexistent_file_path.pdf',
      );

      await tester.pumpWidget(createTestApp(const ReadingPage(book: invalidBook)));
      await tester.pumpAndSettle();

      expect(find.text('Unable to open this book.'), findsOneWidget);
      expect(find.textContaining('Could not load the file'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Back'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
      // Verify no "No internet connection" text
      expect(find.textContaining('internet'), findsNothing);
    });
  });
}

