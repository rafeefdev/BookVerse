import 'package:google_book/model/book_model.dart';
import 'package:google_book/source/playbook_local.dart';
import 'package:google_book/source/playbook_remote.dart';

class BookRepository {
  //call remote and local (caching) repo
  final BookCachingSource localSource;
  final PlaybookServices remoteSource;

  BookRepository({required this.remoteSource, required this.localSource});

  Future<List<Book>> getBooks() async {
    final cached = localSource.getChacedBooks();
    //check if the cached variable is empty and not null
    if(cached != null && cached.isNotEmpty) {
      return cached;
    }

    //run fetching method with await
    final fetchData = await PlaybookServices.getBookData('', 20);
    //save fetched data with running saving caching method from localSource property 
    localSource.cacheBooks(fetchData!);
    return fetchData;
  } 
}
