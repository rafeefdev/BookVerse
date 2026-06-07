import 'package:book_verse/core/models/book_model.dart';

class Author {
  final String name;
  final List<Book> books;

  const Author({required this.name, required this.books});
}
