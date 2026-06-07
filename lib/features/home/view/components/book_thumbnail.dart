import 'package:book_verse/core/models/book_model.dart';
import 'package:flutter/material.dart';

class BookThumbnail extends StatelessWidget {
  final Book book;
  const BookThumbnail(this.book, {super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return book.thumbnail.isEmpty
        ? AspectRatio(
            aspectRatio: 3 / 4,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.outlineVariant,
                  width: 0.05,
                ),
              ),
              child: const Icon(Icons.print, size: 35),
            ),
          )
        : AspectRatio(
            aspectRatio: 3 / 4,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                border: const Border(
                  top: BorderSide(color: Colors.white, width: 0.2),
                  bottom: BorderSide(color: Colors.white, width: 0.2),
                  left: BorderSide(color: Colors.white, width: 0.2),
                  right: BorderSide(color: Colors.white, width: 0.2),
                ),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(book.thumbnail),
                ),
              ),
            ),
          );
  }
}
