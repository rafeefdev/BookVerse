import 'package:book_verse/core/models/book_model.dart';

class ReadingProgressModel {
  final String bookId;
  final int currentPage;
  final int totalReadingTimeInSeconds;
  final DateTime? lastRead;
  final Book? book;

  const ReadingProgressModel({
    required this.bookId,
    required this.currentPage,
    this.totalReadingTimeInSeconds = 0,
    this.lastRead,
    this.book,
  });

  ReadingProgressModel copyWith({
    String? bookId,
    int? currentPage,
    int? totalReadingTimeInSeconds,
    DateTime? lastRead,
    Book? book,
  }) {
    return ReadingProgressModel(
      bookId: bookId ?? this.bookId,
      currentPage: currentPage ?? this.currentPage,
      totalReadingTimeInSeconds:
          totalReadingTimeInSeconds ?? this.totalReadingTimeInSeconds,
      lastRead: lastRead ?? this.lastRead,
      book: book ?? this.book,
    );
  }

  factory ReadingProgressModel.fromJson(Map<String, dynamic> json) {
    return ReadingProgressModel(
      bookId: json['bookId'] as String,
      currentPage: json['currentPage'] as int,
      totalReadingTimeInSeconds: json['totalReadingTimeInSeconds'] as int? ?? 0,
      lastRead: json['lastRead'] != null
          ? DateTime.parse(json['lastRead'] as String)
          : null,
      // book is not included in JSON serialization
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      'currentPage': currentPage,
      'totalReadingTimeInSeconds': totalReadingTimeInSeconds,
      'lastRead': lastRead?.toIso8601String(),
      // book is not included in JSON serialization
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReadingProgressModel &&
        other.bookId == bookId &&
        other.currentPage == currentPage &&
        other.totalReadingTimeInSeconds == totalReadingTimeInSeconds &&
        other.lastRead == lastRead &&
        other.book == book;
  }

  @override
  int get hashCode {
    return Object.hash(
      bookId,
      currentPage,
      totalReadingTimeInSeconds,
      lastRead,
      book,
    );
  }

  @override
  String toString() {
    return 'ReadingProgressModel(bookId: $bookId, currentPage: $currentPage, totalReadingTimeInSeconds: $totalReadingTimeInSeconds, lastRead: $lastRead, book: $book)';
  }
}
