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

  void changeIsFavorite(Book newBook) {
    // Cari indeks buku
    int index = state.data.indexWhere((item) => item.id == newBook.id);

    // Jika buku tidak ditemukan
    if (index == -1) {
      log('selected book not found');
      return;
    }

    //cek kesamaan id
    String newBookId = newBook.id;
    String oldBookId = state.data[index].id;
    log('isIdentic ? : ${newBookId == oldBookId}');

    // Buat salinan list baru dengan buku yang diperbarui
    final updatedBooks = List<Book>.from(state.data);
    updatedBooks[index] = newBook;

    // Perbarui state dengan list baru
    state = LiveBookState('success', '', [...updatedBooks]);
  }

  bool isFavoriteBook(Book book) {
    int index = state.data.indexWhere((element) => element.id == book.id);
    Book selectedBook = state.data[index];
    return selectedBook.isFavorite;
  }
}

class LiveBookState extends Equatable {
  final String status;
  final String message;
  final List<Book> data;

  const LiveBookState(this.status, this.message, this.data);

  @override
  List<Object?> get props => [status, message, data];
}
