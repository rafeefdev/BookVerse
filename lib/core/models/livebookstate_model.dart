import 'package:book_verse/core/models/book_model.dart';
import 'package:equatable/equatable.dart';

class LiveBookState extends Equatable {
  final String status;
  final String message;
  final List<Book> data;

  const LiveBookState(this.status, this.message, this.data);

  @override
  List<Object?> get props => [status, message, data];
}
