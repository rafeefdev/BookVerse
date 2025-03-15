import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:google_book/model/book_model.dart';

part 'bookmark_provider.g.dart';

@riverpod
class BookMarkNotifier extends _$BookMarkNotifier {
  @override
  List<Book> build() => [];

  void toggleFavorite(Book newBook) {
    //toggle isFavorite property
    newBook.isFavorite = !newBook.isFavorite;
    //filter oldstate
    List<Book> newState =
        state.where((element) => element.id != newBook.id).toList();
    state = newState;
  }
}
