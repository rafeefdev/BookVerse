import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:book_verse/core/models/book_model.dart'; // Corrected import

part 'reading_progress_model.freezed.dart';
part 'reading_progress_model.g.dart';

@freezed
class ReadingProgressModel with _$ReadingProgressModel {
  const factory ReadingProgressModel({
    required String bookId,
    required int currentPage,
    @Default(0) int totalReadingTimeInSeconds,
    DateTime? lastRead,
    Book? book, // Changed BookModel to Book
  }) = _ReadingProgressModel;

  factory ReadingProgressModel.fromJson(Map<String, dynamic> json) =>
      _$ReadingProgressModelFromJson(json);
}
