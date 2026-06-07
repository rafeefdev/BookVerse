import 'package:flutter_test/flutter_test.dart';
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

    test('effectivePageCount uses userPageCount when available', () {
      final model = ReadingProgressModel(
        bookId: 'b1', currentPage: 10, userPageCount: 300,
      );
      expect(model.effectivePageCount, 300);
    });

    test('effectivePageCount falls back to 0', () {
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
  });
}
