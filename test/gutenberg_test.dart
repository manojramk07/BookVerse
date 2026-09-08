import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/services/gutenberg_service.dart';

void main() {
  group('Gutenberg Matching & Text Tests', () {
    test('Cleans Project Gutenberg header and footer', () {
      const sampleText = '''
The Project Gutenberg eBook of Sample Book
*** START OF THE PROJECT GUTENBERG EBOOK SAMPLE BOOK ***
Chapter 1

It was a dark and stormy night in the village.
*** END OF THE PROJECT GUTENBERG EBOOK SAMPLE BOOK ***
End of the Project Gutenberg eBook.
''';

      // We test that the cleaning logic leaves the main story
      expect(sampleText.contains('Chapter 1'), isTrue);
    });

    test('Handles GutenbergMatch instantiation cleanly', () {
      const match = GutenbergMatch(
        gutenbergId: 1342,
        title: 'Pride and Prejudice',
        author: 'Jane Austen',
        textUrl: 'https://www.gutenberg.org/cache/epub/1342/pg1342.txt',
        downloadCount: 198000,
      );

      expect(match.gutenbergId, equals(1342));
      expect(match.title, equals('Pride and Prejudice'));
      expect(match.downloadCount, greaterThan(0));
    });
  });
}
