import 'package:book_verse/core/models/book_model.dart';

class ReadingProgressModel {
  final String bookId;
  final int currentPage;
  final int totalReadingTimeInSeconds;
  final DateTime? lastRead;
  final Book? book;
  final int? userPageCount;

  const ReadingProgressModel({
    required this.bookId,
    required this.currentPage,
    this.totalReadingTimeInSeconds = 0,
    this.lastRead,
    this.book,
    this.userPageCount,
  });

  int get effectivePageCount => userPageCount ?? book?.pageCount ?? 0;

  ReadingProgressModel copyWith({
    String? bookId,
    int? currentPage,
    int? totalReadingTimeInSeconds,
    DateTime? lastRead,
    Book? book,
    int? userPageCount,
  }) {
    return ReadingProgressModel(
      bookId: bookId ?? this.bookId,
      currentPage: currentPage ?? this.currentPage,
      totalReadingTimeInSeconds:
          totalReadingTimeInSeconds ?? this.totalReadingTimeInSeconds,
      lastRead: lastRead ?? this.lastRead,
      book: book ?? this.book,
      userPageCount: userPageCount ?? this.userPageCount,
    );
  }

  factory ReadingProgressModel.fromJson(Map<String, dynamic> json) {
    return ReadingProgressModel(
      bookId: (json['bookId'] as String?) ?? '',
      currentPage: (json['currentPage'] as int?) ?? 0,
      totalReadingTimeInSeconds:
          (json['totalReadingTimeInSeconds'] as int?) ?? 0,
      lastRead: json['lastRead'] != null
          ? DateTime.tryParse(json['lastRead'] as String)
          : null,
      userPageCount: json['userPageCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      'currentPage': currentPage,
      'totalReadingTimeInSeconds': totalReadingTimeInSeconds,
      'lastRead': lastRead?.toIso8601String(),
      if (userPageCount != null) 'userPageCount': userPageCount,
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
        other.book == book &&
        other.userPageCount == userPageCount;
  }

  @override
  int get hashCode {
    return Object.hash(
      bookId,
      currentPage,
      totalReadingTimeInSeconds,
      lastRead,
      book,
      userPageCount,
    );
  }

  @override
  String toString() {
    return 'ReadingProgressModel(bookId: $bookId, currentPage: $currentPage, totalReadingTimeInSeconds: $totalReadingTimeInSeconds, lastRead: $lastRead, book: $book, userPageCount: $userPageCount)';
  }
}
