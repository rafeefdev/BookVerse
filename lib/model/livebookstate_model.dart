import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:BookVerse/model/book_model.dart';

class LiveBookState extends Equatable {
  final String status;
  final String message;
  final List<Book> data;

  const LiveBookState(this.status, this.message, this.data);

  @override
  List<Object?> get props => [status, message, data];
}
