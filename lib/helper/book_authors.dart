import 'package:book_verse/model/book_model.dart';

String bookAuthors(Book selectedBook, {int maxAuthorsDisplayed = 3}) {
  String result = '';
  var authors = selectedBook.authors;
  if (authors.length == 1 && authors.isNotEmpty) {
    result = authors[0];
  } else if (authors.length > 1) {
    if (authors.length > 3) {
      List<String> selectedAuthors = authors.sublist(0, maxAuthorsDisplayed);
      result = '${selectedAuthors.join(', ')}, dkk';
    } else {
      result = '${authors.join(', ')}, dkk';
    }
  } else {
    result = 'Unknown Author';
  }
  return result;
}
