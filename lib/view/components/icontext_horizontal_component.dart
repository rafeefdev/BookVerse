import 'package:book_verse/model/book_model.dart';
import 'package:book_verse/shared/themes_extension.dart';
import 'package:flutter/material.dart';

Widget iconWithTextHorizontal(
  BuildContext context,
  Book selectedBook, {
  required IconData icon,
  required String text,
}) {
  return Row(
    spacing: 8,
    children: [
      CircleAvatar(radius: 15, child: Icon(icon, size: 17.5)),
      Flexible(
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodyMedium,
        ),
      ),
    ],
  );
}
