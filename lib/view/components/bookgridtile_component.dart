
import 'package:BookVerse/helper/book_authors.dart';
import 'package:BookVerse/model/book_model.dart';
import 'package:flutter/material.dart';

Widget bookGridTile({
  required Book book,
  required TextTheme textTheme,
  double? aspectRatio,
}) {
  return AspectRatio(
    aspectRatio: aspectRatio ?? 3 / 4,
    child: Card(
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
          mainAxisSize: MainAxisSize.min,
          children: [
            book.thumbnail.isNotEmpty
                ? Expanded(
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black, width: 0.05),
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: NetworkImage(book.thumbnail),
                        ),
                      ),
                    ),
                  ),
                )
                : Expanded(
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black, width: 0.05),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.book,
                          size: 48,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
            Padding(
              padding: const EdgeInsets.only(left: 6, top: 4),
              child: SizedBox(
                height: 72,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.book, color: Colors.grey[600]),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            book.title.length < 25
                                ? book.title
                                : '${book.title.substring(0, 25)}...',
                            style: textTheme.labelLarge,
                            maxLines: 3,
                            overflow: TextOverflow.fade,
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.person, color: Colors.grey[600]),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            bookAuthors(book, maxAuthorsDisplayed: 1),
                            maxLines: 1,
                            style: textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
