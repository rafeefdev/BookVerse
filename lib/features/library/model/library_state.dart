import 'package:book_verse/features/library/model/library_folder_model.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';

class LibraryState {
  final List<ReadingProgressModel> currentlyReading;
  final List<ReadingProgressModel> finished;
  final List<LibraryFolder> folders;
  final bool isLoading;
  final String? error;

  const LibraryState({
    this.currentlyReading = const [],
    this.finished = const [],
    this.folders = const [],
    this.isLoading = false,
    this.error,
  });

  LibraryState copyWith({
    List<ReadingProgressModel>? currentlyReading,
    List<ReadingProgressModel>? finished,
    List<LibraryFolder>? folders,
    bool? isLoading,
    String? error,
  }) {
    return LibraryState(
      currentlyReading: currentlyReading ?? this.currentlyReading,
      finished: finished ?? this.finished,
      folders: folders ?? this.folders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
