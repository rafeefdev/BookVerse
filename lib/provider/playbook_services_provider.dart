import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_book/source/playbook_services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../model/book_model.dart';

part 'playbook_services_provider.g.dart';

@riverpod
class BookNotifier extends _$BookNotifier {
  @override
  LiveBookState build() => const LiveBookState('', '', []);
  Future<void> fetchBooks(String query, int maxResult) async {
    //loading state
    state = LiveBookState('loading', '', []);
    await Future.delayed(Duration(seconds: 1));
    //run getBookData method with await
    final bookList = await PlaybookServices.getBookData(query, maxResult);
    if (bookList == null) {
      state = LiveBookState(
        'failed',
        'Something went wrong : ${PlaybookServices.statusCode}',
        const [],
      );
    } else {
      state = LiveBookState('succes', '', bookList);
    }
  }

  void changeIsFavorite(String id) {
    // Cari indeks buku
    int index = state.data.indexWhere((item) => item.id == id);
    // Jika buku tidak ditemukan
    if (index == -1) {
      log('selected book not found');
      return;
    }
    // Buat salinan list baru dengan buku yang diperbarui
    final newBookList = List<Book>.from(state.data);
    //create new book object
    Book newBook = state.data[index];
    newBookList[index] = newBook;
    log('newBook state : ${newBook.isFavorite}');
    if (newBook.isFavorite == false) {
      log(
        'newBook state changed from : ${newBook.isFavorite} to ${!newBook.isFavorite}',
      );
      //toggle favorite
      newBook.isFavorite = true;
      //replace with new object
      newBookList[index] = newBook;
    } else if (newBook.isFavorite == true) {
      //toggle favorite
      newBook.isFavorite = false;
      log(
        'newBook state changed from : ${newBook.isFavorite} to ${newBook.isFavorite}',
      );
      //replace with new object
      newBookList[index] = newBook;
    }

    // Perbarui state dengan list baru
    state = LiveBookState('success', '', [...newBookList]);
  }

  bool isFavoriteBook(String id) {
    int index = state.data.indexWhere((element) => element.id == id);
    Book selectedBook = state.data[index];
    return selectedBook.isFavorite;
  }
}

String bookAuthors(Book selectedBook) {
  String result = '';
  selectedBook.authors.length == 1 && selectedBook.authors.isNotEmpty
      ? result = selectedBook.authors[0]
      : result = '${selectedBook.authors.join(', ')}, dkk';
  return result;
}

class LiveBookState extends Equatable {
  final String status;
  final String message;
  final List<Book> data;

  const LiveBookState(this.status, this.message, this.data);

  @override
  List<Object?> get props => [status, message, data];
}
