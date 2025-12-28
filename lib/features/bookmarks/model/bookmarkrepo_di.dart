import 'package:book_verse/features/bookmarks/model/bookmark_repo.dart';
import 'package:book_verse/features/bookmarks/model/local_bookmark_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bookmarkrepo_di.g.dart';

@riverpod
BookmarkRepo bookmarkRepo(Ref ref) {
  return BookmarkRepo(localBookmarkService: LocalBookmarkService());
}
