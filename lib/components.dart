import 'package:flutter/material.dart';
import 'package:google_book/book_model.dart';

Card bookGridTile(Book book, TextTheme textTheme) {
  return Card(
    elevation: 4,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 0.05, color: Colors.black),
      ),
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Center(
              child:
                  book.thumbnail.isNotEmpty
                      ? Image.network(book.thumbnail)
                      : Icon(Icons.broken_image),
            ),
          ),
          Text(
            book.title.length < 30
                ? book.title
                : '${book.title.substring(0, 30)}...',
            style: textTheme.labelLarge,
          ),
          Text(
            book.authors.length > 1
                ? "${book.authors[0]}, dkk"
                : book.authors.isNotEmpty
                ? book.authors[0]
                : book.authors.toString(),
            style: textTheme.bodySmall,
          ),
        ],
      ),
    ),
  );
}
