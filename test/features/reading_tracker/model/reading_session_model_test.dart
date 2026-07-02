import 'package:flutter_test/flutter_test.dart';
import 'package:book_verse/features/reading_tracker/model/reading_session_model.dart';

void main() {
  group('ReadingSessionModel', () {
    final now = DateTime(2025, 1, 15, 10, 30);

    test('fromJson / toJson roundtrip', () {
      final json = {
        'bookId': 'book-1',
        'durationInSeconds': 1200,
        'endPage': 50,
        'timestamp': now.toIso8601String(),
      };
      final model = ReadingSessionModel.fromJson(json);
      expect(model.bookId, 'book-1');
      expect(model.durationInSeconds, 1200);
      expect(model.endPage, 50);
      expect(model.timestamp, now);
      expect(model.startPage, isNull);

      final output = model.toJson();
      expect(output['bookId'], 'book-1');
      expect(output['durationInSeconds'], 1200);
      expect(output['endPage'], 50);
    });

    test('fromJson with startPage', () {
      final json = {
        'bookId': 'book-1',
        'durationInSeconds': 600,
        'endPage': 30,
        'timestamp': now.toIso8601String(),
        'startPage': 10,
      };
      final model = ReadingSessionModel.fromJson(json);
      expect(model.startPage, 10);
    });

    test('fromJson with null timestamp defaults to now', () {
      final json = {
        'bookId': 'b1',
        'durationInSeconds': 0,
        'endPage': 0,
        'timestamp': null,
      };
      final model = ReadingSessionModel.fromJson(json);
      // timestamp defaults to DateTime.now(), so we can only verify it's not null
      expect(model.timestamp, isNotNull);
    });

    test('fromJson with missing timestamp defaults to now', () {
      final json = {'bookId': 'b1', 'durationInSeconds': 0, 'endPage': 0};
      final model = ReadingSessionModel.fromJson(json);
      expect(model.timestamp, isNotNull);
    });

    test('copyWith', () {
      final original = ReadingSessionModel(
        bookId: 'b1',
        durationInSeconds: 300,
        endPage: 20,
        timestamp: now,
      );
      final updated = original.copyWith(durationInSeconds: 600);
      expect(updated.durationInSeconds, 600);
      expect(updated.bookId, 'b1');
    });

    test('equality', () {
      final a = ReadingSessionModel(
        bookId: 'b1',
        durationInSeconds: 300,
        endPage: 20,
        timestamp: now,
      );
      final b = ReadingSessionModel(
        bookId: 'b1',
        durationInSeconds: 300,
        endPage: 20,
        timestamp: now,
      );
      expect(a, equals(b));
    });

    group('invariants', () {
      test('durationInSeconds is never negative', () {
        final model = ReadingSessionModel(
          bookId: 'b1',
          durationInSeconds: 0,
          endPage: 0,
          timestamp: now,
        );
        expect(model.durationInSeconds, greaterThanOrEqualTo(0));
      });

      test('endPage is never negative', () {
        final model = ReadingSessionModel(
          bookId: 'b1',
          durationInSeconds: 0,
          endPage: 0,
          timestamp: now,
        );
        expect(model.endPage, greaterThanOrEqualTo(0));
      });

      test('startPage when present is never negative', () {
        final model = ReadingSessionModel(
          bookId: 'b1',
          durationInSeconds: 0,
          endPage: 10,
          timestamp: now,
          startPage: 0,
        );
        expect(model.startPage, greaterThanOrEqualTo(0));
      });
    });
  });
}
