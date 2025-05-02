import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_book/model/book_model.dart';

class BookCachingSource {
  //save box
  final _box = Hive.box('cacheBox');

  //method to load cached data to UI
  List<Book>? getChacedBooks() {
    //run get method from _box variable and cast it to List?
    final data = _box.get('books') as List<Book>?;
    if (data != null) {
      //return data variable with running cast method
      return data.cast<Book>();
    }
    return null;
  }

  //cache function to save data from API
  void cacheBooks(List<Book> books) {
    //run put method from _box instance
    _box.put('books', books);
  }
}
