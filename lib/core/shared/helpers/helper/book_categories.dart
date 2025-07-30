import 'package:book_verse/core/models/book_model.dart';

String bookCategories(Book selectedBook) {
  List? bookCategories = selectedBook.categories;
  String result = 'Unknown Category';

  if (bookCategories!.length == 1) {
    result = bookCategories[0];
    return result;
  } else if (bookCategories.length > 1) {
    result = '${selectedBook.categories!.join(', ')}, etc';
  }
  return result;
}
