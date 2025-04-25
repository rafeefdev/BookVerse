import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_book/provider/playbook_services_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:google_book/model/book_model.dart';

part 'bookmark_provider.g.dart';

@riverpod
List<Book> bookmarkedBooks(Ref ref) {
  List<Book> allBooks = ref.watch(bookNotifierProvider).data;
  return allBooks.where((book)=> book.isFavorite == true).toList();
}