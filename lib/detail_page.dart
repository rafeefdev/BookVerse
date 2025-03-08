import 'package:flutter/material.dart';
import 'package:google_book/book_model.dart';

class DetailPage extends StatelessWidget {
  final Book selectedBook;

  const DetailPage({required this.selectedBook, super.key});

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                image: DecorationImage(
                  image: NetworkImage(selectedBook.thumbnail),
                ),
              ),
            ),
            Text(selectedBook.title, style: textTheme.titleLarge),
            Text(
              selectedBook.authors.length == 1 &&
                      selectedBook.authors.isNotEmpty
                  ? selectedBook.authors[0]
                  : '${selectedBook.authors.toString()}, dkk',
              style: textTheme.bodyLarge,
            ),
            SizedBox(height: 12),
            Text(selectedBook.description, style: textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
