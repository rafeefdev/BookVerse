class ReadingSessionModel {
  final String bookId;
  final int durationInSeconds;
  final int endPage;
  final DateTime timestamp;

  const ReadingSessionModel({
    required this.bookId,
    required this.durationInSeconds,
    required this.endPage,
    required this.timestamp,
  });

  ReadingSessionModel copyWith({
    String? bookId,
    int? durationInSeconds,
    int? endPage,
    DateTime? timestamp,
  }) {
    return ReadingSessionModel(
      bookId: bookId ?? this.bookId,
      durationInSeconds: durationInSeconds ?? this.durationInSeconds,
      endPage: endPage ?? this.endPage,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory ReadingSessionModel.fromJson(Map<String, dynamic> json) {
    return ReadingSessionModel(
      bookId: json['bookId'] as String,
      durationInSeconds: json['durationInSeconds'] as int,
      endPage: json['endPage'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      'durationInSeconds': durationInSeconds,
      'endPage': endPage,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReadingSessionModel &&
        other.bookId == bookId &&
        other.durationInSeconds == durationInSeconds &&
        other.endPage == endPage &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(bookId, durationInSeconds, endPage, timestamp);
  }

  @override
  String toString() {
    return 'ReadingSessionModel(bookId: $bookId, durationInSeconds: $durationInSeconds, endPage: $endPage, timestamp: $timestamp)';
  }
}
