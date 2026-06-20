import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/core/shared/components/booklisttile_component.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final book = Book(
    id: 'b1',
    title: 'Test Book',
    subTitle: '',
    authors: ['Author'],
    publisher: 'Pub',
    publishedDate: '2026',
    description: 'Desc',
    thumbnail: '',
    pageCount: 300,
  );

  Widget wrapBookListTile({
    ReadingProgressModel? readingProgress,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => bookListTile(
            context,
            book,
            readingProgress: readingProgress,
          ),
        ),
      ),
    );
  }

  group('bookListTile progress display', () {
    testWidgets('uses effectivePageCount (userPageCount) when available',
        (tester) async {
      final progress = ReadingProgressModel(
        bookId: 'b1',
        currentPage: 175,
        book: book,
        userPageCount: 350,
      );

      await tester.pumpWidget(wrapBookListTile(readingProgress: progress));

      expect(find.text('175/350 hlm  50%'), findsOneWidget);
      expect(find.text('175/300 hlm  58%'), findsNothing);
    });

    testWidgets('falls back to book.pageCount when userPageCount is null',
        (tester) async {
      final progress = ReadingProgressModel(
        bookId: 'b1',
        currentPage: 150,
        book: book,
      );

      await tester.pumpWidget(wrapBookListTile(readingProgress: progress));

      expect(find.text('150/300 hlm  50%'), findsOneWidget);
    });

    testWidgets('shows Not started when readingProgress is null',
        (tester) async {
      await tester.pumpWidget(wrapBookListTile(readingProgress: null));

      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.textContaining('hlm'), findsNothing);
    });

    testWidgets('shows 0 progress when currentPage is 0', (tester) async {
      final progress = ReadingProgressModel(
        bookId: 'b1',
        currentPage: 0,
        book: book,
        userPageCount: 300,
      );

      await tester.pumpWidget(wrapBookListTile(readingProgress: progress));

      expect(find.text('0/300 hlm  0%'), findsOneWidget);
    });
  });
}
