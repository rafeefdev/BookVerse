import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/features/bookmarks/model/local_bookmark_service.dart';

class BookmarkRepo {
  final LocalBookmarkService localBookmarkService;

  BookmarkRepo({required this.localBookmarkService});

  Future<List<Map<String, dynamic>>> getBookmarkedBooks() async {
    // TODO : implement conflict resolution between cloud and local here
    return localBookmarkService.getBookmarkedBooks();
  }

  Future<void> addToBookmark(Book book) async {
    // add bookmark to local storage
    localBookmarkService.addToBookmark(book.toMap());
    // TODO : add bookmark to cloud storage
  }

  Future<void> removeBookmark(String bookId) async {
    // remove bookmark locally
    localBookmarkService.removeBookmark(bookId);
    // TODO : remove bookmark on cloud storage
  }

  Future<bool> isBookmarked(String id) async {
    // TODO : conflict resolution between cloud and local
    return localBookmarkService.isBookmarked(id);
  }
}
