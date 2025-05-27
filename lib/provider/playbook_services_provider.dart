import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:BookVerse/model/livebookstate_model.dart';
import 'package:BookVerse/source/playbook_services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../model/book_model.dart';

part 'playbook_services_provider.g.dart';

@Riverpod(keepAlive: true)
class BookNotifier extends _$BookNotifier {
  var playbookService = PlaybookServices();

  @override
  LiveBookState build() => const LiveBookState('', '', []);

  Future<void> fetchBooks({
    String? query,
    String? author,
    int maxResult = 20,
    String? publisher,
    String? title,
  }) async {
    //loading state
    state = LiveBookState('loading', '', []);
    await Future.delayed(Duration(seconds: 1));
    //run getBookData method with await
    final bookList = await playbookService.getBookData(
      query: query,
      author: author,
      maxResult: maxResult,
      publisher: publisher,
      title: title,
    );
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
  if (selectedBook.authors.length == 1 && selectedBook.authors.isNotEmpty) {
    result = selectedBook.authors[0];
  } else if (selectedBook.authors.length > 1) {
    result = '${selectedBook.authors.join(', ')}, dkk';
  } else {
    result = 'Unknown Author';
  }
  return result;
}
