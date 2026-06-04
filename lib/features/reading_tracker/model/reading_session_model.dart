class ReadingSessionModel {
  final String bookId;
  final int durationInSeconds;
  final int endPage;
  final DateTime timestamp;
  final int? startPage;

  const ReadingSessionModel({
    required this.bookId,
    required this.durationInSeconds,
    required this.endPage,
    required this.timestamp,
    this.startPage,
  });

  ReadingSessionModel copyWith({
    String? bookId,
    int? durationInSeconds,
    int? endPage,
    DateTime? timestamp,
    int? startPage,
  }) {
    return ReadingSessionModel(
      bookId: bookId ?? this.bookId,
      durationInSeconds: durationInSeconds ?? this.durationInSeconds,
      endPage: endPage ?? this.endPage,
      timestamp: timestamp ?? this.timestamp,
      startPage: startPage ?? this.startPage,
    );
  }

  factory ReadingSessionModel.fromJson(Map<String, dynamic> json) {
    return ReadingSessionModel(
      bookId: (json['bookId'] as String?) ?? '',
      durationInSeconds: (json['durationInSeconds'] as int?) ?? 0,
      endPage: (json['endPage'] as int?) ?? 0,
      timestamp: json['timestamp'] != null
          ? (DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now())
          : DateTime.now(),
      startPage: json['startPage'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      'durationInSeconds': durationInSeconds,
      'endPage': endPage,
      'timestamp': timestamp.toIso8601String(),
      if (startPage != null) 'startPage': startPage,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReadingSessionModel &&
        other.bookId == bookId &&
        other.durationInSeconds == durationInSeconds &&
        other.endPage == endPage &&
        other.timestamp == timestamp &&
        other.startPage == startPage;
  }

  @override
  int get hashCode {
    return Object.hash(
      bookId,
      durationInSeconds,
      endPage,
      timestamp,
      startPage,
    );
  }

  @override
  String toString() {
    return 'ReadingSessionModel(bookId: $bookId, durationInSeconds: $durationInSeconds, endPage: $endPage, timestamp: $timestamp, startPage: $startPage)';
  }
}
