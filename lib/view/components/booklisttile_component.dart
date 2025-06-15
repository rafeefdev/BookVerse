import 'package:BookVerse/helper/book_authors.dart';
import 'package:BookVerse/helper/push_navigation.dart';
import 'package:BookVerse/model/book_model.dart';
import 'package:BookVerse/view/pages/new_detailpage.dart';
import 'package:flutter/material.dart';

Widget bookListTile(
  BuildContext context,
  Book book, {
  bool isWrappedByCard = false,
  bool isTemporarySource = false,
}) {
  Widget lisTile = InkWell(
    onTap: pushNavigation(
      context,
      destinationPage: NewDetailpage(
        selectedBookId: book.id,
        isTemporarySource: isTemporarySource,
      )
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading:
          book.thumbnail.isNotEmpty
              ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  book.thumbnail,
                  width: 50,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => const Icon(Icons.book),
                ),
              )
              : Container(
                width: 50,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(child: Icon(Icons.book, color: Colors.grey[600])),
              ),
      title: Text(
        book.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(bookAuthors(book)),
    ),
  );

  return isWrappedByCard
      ? Card(
        elevation: 2.6,
        margin: const EdgeInsets.only(bottom: 12),
        child: lisTile,
      )
      : lisTile;
}
