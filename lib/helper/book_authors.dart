
import 'package:BookVerse/model/book_model.dart';

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
