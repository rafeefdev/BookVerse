import 'package:flutter/material.dart';
import 'package:google_book/model/book_model.dart';

class DetailPage extends StatelessWidget {
  final Book selectedBook;

  const DetailPage({required this.selectedBook, super.key});

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    String bookAuthors() {
      String result = '';
      selectedBook.authors.length == 1 && selectedBook.authors.isNotEmpty
          ? result = selectedBook.authors[0]
          : result = '${selectedBook.authors.join(', ')}, dkk';
      return result;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail'),
        actionsPadding: EdgeInsets.only(right: 16),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.bookmark))],
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
                      ? Center(child: Icon(Icons.print, size: 35))
                      : Container(
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
            SizedBox(height: 12),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceAround,
            //   children: [
            //     Column(
            //       children: [
            //         IconButton(onPressed: () {}, icon: Icon(Icons.save)),
            //         Text('save'),
            //       ],
            //     ),
            //     Column(
            //       children: [
            //         IconButton(onPressed: () {}, icon: Icon(Icons.save)),
            //         Text('save'),
            //       ],
            //     ),
            //   ],
            // ),
            // SizedBox(height: 12),
            ListTile(
              title: Text(bookAuthors()),
              subtitle: Text('Author'),
              leading: Icon(Icons.person),
            ),
            ListTile(
              title: Text(selectedBook.publishedDate),
              subtitle: Text('Published date'),
              leading: Icon(Icons.calendar_month),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
