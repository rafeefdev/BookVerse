import 'package:flutter_test/flutter_test.dart';
import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';

void main() {
  group('ReadingProgressModel', () {
    test('fromJson / toJson roundtrip', () {
      final json = {
        'bookId': 'b1',
        'currentPage': 42,
        'totalReadingTimeInSeconds': 3600,
        'lastRead': '2025-01-15T10:00:00.000',
      };
      final model = ReadingProgressModel.fromJson(json);
      expect(model.bookId, 'b1');
      expect(model.currentPage, 42);
      expect(model.totalReadingTimeInSeconds, 3600);
      expect(model.lastRead, DateTime(2025, 1, 15, 10));

      final output = model.toJson();
      expect(output['bookId'], 'b1');
      expect(output['currentPage'], 42);
    });

    test('fromJson with userPageCount', () {
      final json = {
        'bookId': 'b1',
        'currentPage': 50,
        'userPageCount': 400,
      };
      final model = ReadingProgressModel.fromJson(json);
      expect(model.userPageCount, 400);
      expect(model.effectivePageCount, 400);
    });

    test('fromJson with null lastRead', () {
      final json = {
        'bookId': 'b1',
        'currentPage': 0,
      };
      final model = ReadingProgressModel.fromJson(json);
      expect(model.lastRead, isNull);
    });

    test('effectivePageCount uses userPageCount when available', () {
      final model = ReadingProgressModel(
        bookId: 'b1', currentPage: 10, userPageCount: 300,
      );
      expect(model.effectivePageCount, 300);
    });

    test('effectivePageCount falls back to book.pageCount', () {
      final book = Book(
        id: 'b1',
        title: 'Test',
        subTitle: '',
        authors: [],
        publisher: '',
        publishedDate: '',
        description: '',
        thumbnail: '',
        pageCount: 250,
      );
      final model = ReadingProgressModel(
        bookId: 'b1', currentPage: 10, book: book,
      );
      expect(model.effectivePageCount, 250);
    });

    test('effectivePageCount falls back to 0 when neither available', () {
      final model = ReadingProgressModel(bookId: 'b1', currentPage: 10);
      expect(model.effectivePageCount, 0);
    });

    test('copyWith', () {
      final original = ReadingProgressModel(bookId: 'b1', currentPage: 10);
      final updated = original.copyWith(currentPage: 20);
      expect(updated.currentPage, 20);
      expect(updated.bookId, 'b1');
    });

    test('equality', () {
      final a = ReadingProgressModel(bookId: 'b1', currentPage: 10);
      final b = ReadingProgressModel(bookId: 'b1', currentPage: 10);
      expect(a, equals(b));
    });

    group('invariants', () {
      test('currentPage is never negative', () {
        final model = ReadingProgressModel(bookId: 'b1', currentPage: 0);
        expect(model.currentPage, greaterThanOrEqualTo(0));
      });

      test('currentPage does not exceed effectivePageCount', () {
        final model = ReadingProgressModel(
          bookId: 'b1',
          currentPage: 200,
          userPageCount: 300,
        );
        expect(model.currentPage, lessThanOrEqualTo(model.effectivePageCount));
      });
    });
  });
}
