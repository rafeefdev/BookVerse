import 'package:book_verse/features/bookmarks/data/bookmark_datasource.dart';
import 'package:book_verse/features/bookmarks/model/bookmark_repo.dart';
import 'package:book_verse/features/reading_tracker/data/reading_tracker_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bookmarkRepoProvider = Provider<BookmarkRepo>((ref) {
  return BookmarkRepo(
    bookmarkDatasource: ref.watch(bookmarkDatasourceProvider),
    readingTrackerDatasource: ref.watch(readingTrackerDatasourceProvider),
  );
});
