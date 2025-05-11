import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_book/model/book_model.dart';
import 'package:google_book/provider/playbook_services_provider.dart';

class DetailPage extends ConsumerWidget {
  final String selectedBookId;

  const DetailPage({required this.selectedBookId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var textTheme = Theme.of(context).textTheme;
    //get selected book data
    List<Book> books = ref.watch(bookNotifierProvider).data;
    int index = books.indexWhere((book) => book.id == selectedBookId);
    Book selectedBook = ref.watch(bookNotifierProvider).data[index];

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail'),
        actionsPadding: EdgeInsets.only(right: 16),
        actions: [
          Consumer(
            builder: (context, wiRef, child) {
              return IconButton(
                onPressed: () {
                  wiRef
                      .read(bookNotifierProvider.notifier)
                      .changeIsFavorite(selectedBookId);
                },
                icon: Icon(
                  selectedBook.isFavorite
                      ? Icons.bookmark
                      : Icons.bookmark_border_rounded,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title:
                  selectedBook.thumbnail.isEmpty
                      ? Center(
                        child: AspectRatio(
                          aspectRatio: 3 / 4,
                          child: Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.black,
                                width: 0.05,
                              ),
                            ),
                            child: Icon(Icons.print, size: 35),
                          ),
                        ),
                      )
                      : AspectRatio(
                        aspectRatio: 3 / 4,
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            border: Border.all(color: Colors.black, width: 0.2),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(selectedBook.thumbnail),
                            ),
                          ),
                        ),
                      ),
            ),
            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                spacing: 8,
                children: [
                  Text(
                    selectedBook.title,
                    style: TextStyle(
                      height: 1.2,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Visibility(
                    visible: selectedBook.subTitle != null,
                    child: Text(
                      selectedBook.subTitle!,
                      style: TextStyle(height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text(bookAuthors(selectedBook)),
              subtitle: Text('Author'),
              leading: Icon(Icons.person),
            ),
            ListTile(
              title: Text(selectedBook.publishedDate),
              subtitle: Text('Published date'),
              leading: Icon(Icons.calendar_month),
            ),
            ListTile(
              title: Text('${selectedBook.pageCount}'),
              subtitle: Text('Page count'),
              leading: Icon(Icons.menu_book_rounded),
            ),
            ListTile(
              title: Text(bookCategories(selectedBook)),
              subtitle: Text('Categories'),
              leading: Icon(Icons.file_copy),
            ),
            ListTile(
              title: Text(selectedBook.publisher),
              subtitle: Text('Publisher'),
              leading: Icon(Icons.print_rounded),
            ),
            ListTile(
              subtitle: Text(
                selectedBook.description,
                style: textTheme.bodyMedium,
                textAlign: TextAlign.justify,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
}
