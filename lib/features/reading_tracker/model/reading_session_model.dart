import 'package:freezed_annotation/freezed_annotation.dart';

part 'reading_session_model.freezed.dart';
part 'reading_session_model.g.dart';

@freezed
class ReadingSessionModel with _$ReadingSessionModel {
  const factory ReadingSessionModel({
    required String bookId,
    required int durationInSeconds,
    required int endPage,
    required DateTime timestamp,
  }) = _ReadingSessionModel;

  factory ReadingSessionModel.fromJson(Map<String, dynamic> json) =>
      _$ReadingSessionModelFromJson(json);
}
