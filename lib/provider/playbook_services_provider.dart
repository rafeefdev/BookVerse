import 'dart:developer';

import 'package:google_book/model/livebookstate_model.dart';
import 'package:google_book/source/playbook_local.dart';
import 'package:google_book/source/playbook_remote.dart';
import 'package:google_book/source/playbook_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../model/book_model.dart';

part 'playbook_services_provider.g.dart';

@riverpod
class BookNotifier extends _$BookNotifier {
  @override
  LiveBookState build() => const LiveBookState('', '', []);

  Future<void> fetchBooks({
    String query = '',
    int maxResult = 20,
    bool isRefetch = false,
  }) async {
    //loading state
    state = LiveBookState('loading', '', []);
    await Future.delayed(Duration(seconds: 1));

    //declare book repo object
    BookRepository bookRepo = BookRepository(
      remoteSource: PlaybookServices(),
      localSource: BookCachingSource(),
    );

    if (isRefetch == true) {
      //refetch data  from playbook API
      final refetchedBookList = await PlaybookServices.getBookData(
        query,
        maxResult,
      );
      //empty checking
      if (refetchedBookList!.isEmpty) {
        state = LiveBookState(
          'failed',
          'Something went wrong : ${bookRepo.statusCode()}',
          const [],
        );
      } else {
        state = LiveBookState('succes', '', refetchedBookList);
      }
    } else {
      //get book data from book repo service
      final bookList = await bookRepo.getBooks(
        query: query,
        maxItem: maxResult,
      );
      //empty checking
      if (bookList.isEmpty) {
        state = LiveBookState(
          'failed',
          'Something went wrong : ${bookRepo.statusCode()}',
          const [],
        );
      } else {
        state = LiveBookState('succes', '', bookList);
      }
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
