import 'package:BookVerse/provider/playbook_services_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:BookVerse/model/book_model.dart';

part 'bookmark_provider.g.dart';

@riverpod
List<Book> bookmarkedBooks(Ref ref) {
  List<Book> allBooks = ref.watch(bookNotifierProvider).data;
  return allBooks.where((book)=> book.isFavorite == true).toList();
}