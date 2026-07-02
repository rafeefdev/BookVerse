import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/features/bookmarks/model/bookmark_repo.dart';
import 'package:book_verse/features/bookmarks/model/bookmarkrepo_di.dart';
import 'package:book_verse/features/home/view/sections/reading_progress_section.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockBookmarkRepo extends Mock implements BookmarkRepo {}

void main() {
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

  Widget wrapWithProviders({
    required BookmarkRepo bookmarkRepo,
    required Widget child,
  }) {
    return ProviderScope(
      overrides: [bookmarkRepoProvider.overrideWithValue(bookmarkRepo)],
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  group('ReadingProgressSection', () {
    testWidgets('uses effectivePageCount when userPageCount is set', (
      tester,
    ) async {
      final mockRepo = _MockBookmarkRepo();
      final progress = ReadingProgressModel(
        bookId: 'b1',
        currentPage: 175,
        book: book,
        userPageCount: 350,
      );

      when(
        () => mockRepo.getReadingProgressWithBooks(),
      ).thenAnswer((_) async => [progress]);

      await tester.pumpWidget(
        wrapWithProviders(
          bookmarkRepo: mockRepo,
          child: ReadingProgressSection(book),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('175 / 350 pages'), findsOneWidget);
      expect(find.text('175 / 300 pages'), findsNothing);
    });

    testWidgets('uses book.pageCount when userPageCount is null', (
      tester,
    ) async {
      final mockRepo = _MockBookmarkRepo();
      final progress = ReadingProgressModel(
        bookId: 'b1',
        currentPage: 150,
        book: book,
      );

      when(
        () => mockRepo.getReadingProgressWithBooks(),
      ).thenAnswer((_) async => [progress]);

      await tester.pumpWidget(
        wrapWithProviders(
          bookmarkRepo: mockRepo,
          child: ReadingProgressSection(book),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('150 / 300 pages'), findsOneWidget);
    });

    testWidgets('shows Save to Library when not bookmarked', (tester) async {
      final mockRepo = _MockBookmarkRepo();

      when(
        () => mockRepo.getReadingProgressWithBooks(),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(
        wrapWithProviders(
          bookmarkRepo: mockRepo,
          child: ReadingProgressSection(book),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Save to My Library'), findsOneWidget);
      expect(find.text('150 / 300 pages'), findsNothing);
    });
  });
}
