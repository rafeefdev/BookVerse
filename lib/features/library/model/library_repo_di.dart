import 'package:book_verse/features/bookmarks/data/bookmark_datasource.dart';
import 'package:book_verse/features/library/data/library_folder_datasource.dart';
import 'package:book_verse/features/library/model/library_repo.dart';
import 'package:book_verse/features/reading_tracker/data/reading_tracker_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final libraryRepoProvider = Provider<LibraryRepo>((ref) {
  return LibraryRepo(
    bookmarkDatasource: ref.watch(bookmarkDatasourceProvider),
    libraryFolderDatasource: ref.watch(libraryFolderDatasourceProvider),
    readingTrackerDatasource: ref.watch(readingTrackerDatasourceProvider),
  );
});
