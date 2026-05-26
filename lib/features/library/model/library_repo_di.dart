import 'package:book_verse/features/library/model/library_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'library_repo_di.g.dart';

@riverpod
LibraryRepo libraryRepo(Ref ref) {
  return LibraryRepo();
}
