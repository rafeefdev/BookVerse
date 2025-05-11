import 'package:flutter/material.dart';
import 'package:google_book/model/book_model.dart';
import 'package:google_book/provider/playbook_services_provider.dart';

Widget bookGridTile(Book book, TextTheme textTheme) {
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
        mainAxisSize: MainAxisSize.min,
        children: [
          book.thumbnail.isNotEmpty
              ? Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black, width: 0.2),
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: NetworkImage(book.thumbnail),
                    ),
                  ),
                ),
              )
              : Expanded(
                flex: 3,
                child: Container(
                  color: Colors.grey[300],
                  child: Center(
                    child: Icon(Icons.book, size: 48, color: Colors.grey[600]),
                  ),
                ),
              ),
          Padding(
            padding: const EdgeInsets.only(left: 6, top: 4),
            child: SizedBox(
              height: 72,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.book, color: Colors.grey),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          book.title.length < 30
                              ? book.title
                              : '${book.title.substring(0, 30)}...',
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
                      Icon(Icons.person, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        bookAuthors(book),
                        maxLines: 1,
                        style: textTheme.bodySmall,
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
  );
}
