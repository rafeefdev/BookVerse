import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/features/library/view/widgets/library_book_list_tab.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LibraryBookListTab', () {
    testWidgets('passes readingProgress with userPageCount to bookListTile', (
      tester,
    ) async {
      final book = Book(
        id: 'b1',
        title: 'Test Book',
        subTitle: '',
        authors: ['Author'],
        publisher: '',
        publishedDate: '',
        description: '',
        thumbnail: '',
        pageCount: 300,
      );
      final progress = ReadingProgressModel(
        bookId: 'b1',
        currentPage: 200,
        totalReadingTimeInSeconds: 3600,
        book: book,
        userPageCount: 350,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LibraryBookListTab(
              books: [progress],
              emptyIcon: Icons.menu_book,
              emptyText: 'No books',
            ),
          ),
        ),
      );

      expect(find.text('200/350 hlm  57%'), findsOneWidget);
      expect(find.text('200/300 hlm  67%'), findsNothing);
    });

    testWidgets('shows fallback page count when userPageCount is null', (
      tester,
    ) async {
      final book = Book(
        id: 'b1',
        title: 'Test Book',
        subTitle: '',
        authors: ['Author'],
        publisher: '',
        publishedDate: '',
        description: '',
        thumbnail: '',
        pageCount: 300,
      );
      final progress = ReadingProgressModel(
        bookId: 'b1',
        currentPage: 150,
        book: book,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LibraryBookListTab(
              books: [progress],
              emptyIcon: Icons.menu_book,
              emptyText: 'No books',
            ),
          ),
        ),
      );

      expect(find.text('150/300 hlm  50%'), findsOneWidget);
    });

    testWidgets('shows empty state when no books', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LibraryBookListTab(
              books: [],
              emptyIcon: Icons.menu_book,
              emptyText: 'No books available',
            ),
          ),
        ),
      );

      expect(find.text('No books available'), findsOneWidget);
    });
  });
}
