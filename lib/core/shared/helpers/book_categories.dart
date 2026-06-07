import 'package:book_verse/core/models/book_model.dart';

String bookCategories(Book selectedBook) {
  final bookCategories = selectedBook.categories;
  if (bookCategories == null || bookCategories.isEmpty) {
    return 'Unknown Category';
  }
  if (bookCategories.length == 1) return bookCategories[0];
  return '${bookCategories.join(', ')}, etc';
}
