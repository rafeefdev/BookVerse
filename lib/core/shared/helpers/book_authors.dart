import 'package:book_verse/core/models/book_model.dart';

String bookAuthors(Book selectedBook, {int maxAuthorsDisplayed = 3}) {
  var authors = selectedBook.authors;
  if (authors.isEmpty) return 'Unknown Author';
  if (authors.length == 1) return authors[0];
  if (authors.length == 2) return '${authors[0]} and ${authors[1]}';
  if (authors.length <= maxAuthorsDisplayed) {
    return '${authors.sublist(0, authors.length - 1).join(', ')}, and ${authors.last}';
  }
  List<String> selectedAuthors = authors.sublist(0, maxAuthorsDisplayed);
  return '${selectedAuthors.join(', ')}, dkk';
}
