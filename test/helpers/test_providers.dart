import 'package:book_verse/core/utils/clock.dart';
import 'package:book_verse/features/bookmarks/data/bookmark_datasource.dart';
import 'package:book_verse/features/library/data/library_folder_datasource.dart';
import 'package:book_verse/features/library/model/library_repo.dart';
import 'package:book_verse/features/reading_tracker/data/reading_tracker_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

class MockClock extends Mock implements Clock {}

class MockReadingTrackerDatasource extends Mock
    implements ReadingTrackerDatasource {}

class MockBookmarkDatasource extends Mock implements BookmarkDatasource {}

class MockLibraryFolderDatasource extends Mock
    implements LibraryFolderDatasource {}

class MockLibraryRepo extends Mock implements LibraryRepo {}

ProviderContainer createTestContainer({
  Clock? clock,
  ReadingTrackerDatasource? readingTrackerDatasource,
  BookmarkDatasource? bookmarkDatasource,
  LibraryFolderDatasource? libraryFolderDatasource,
  List<Override> additionalOverrides = const [],
}) {
  return ProviderContainer(
    overrides: [
      if (clock != null) clockProvider.overrideWithValue(clock),
      if (readingTrackerDatasource != null)
        readingTrackerDatasourceProvider.overrideWithValue(
          readingTrackerDatasource,
        ),
      if (bookmarkDatasource != null)
        bookmarkDatasourceProvider.overrideWithValue(bookmarkDatasource),
      if (libraryFolderDatasource != null)
        libraryFolderDatasourceProvider.overrideWithValue(
          libraryFolderDatasource,
        ),
      ...additionalOverrides,
    ],
  );
}
