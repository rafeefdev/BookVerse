import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:google_book/model/book_model.dart';

part 'bookmark_provider.g.dart';

@riverpod
class BookMarkNotifier extends _$BookMarkNotifier {
  @override
  List<Book> build() => [];

  void toggleFavorite(String id) {
    //get book index
    int index = state.indexWhere((element)=> element.id == id);
    //new book object
    Book newBook = state[index];
    //new book list
    List<Book> newBookList = state;
    if(newBook.isFavorite == true) {
      newBook.isFavorite = false;
      newBookList[index] = newBook;
    } else {
      newBook.isFavorite = true;
      newBookList[index] = newBook;
    }
    state = newBookList;
  }
}
