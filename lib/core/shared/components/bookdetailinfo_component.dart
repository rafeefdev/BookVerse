import 'package:book_verse/core/shared/themes_extension.dart';
import 'package:flutter/material.dart';

Widget bookDetailInfoTile(
  BuildContext context, {
  required String title,
  required String data,
  required IconData icon,
  bool isFullWidth = false,
  int dataMaxLines = 2,
}) {
  var mainComponent = SizedBox(
    height: 180,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.only(top: 24, left: 8, right: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(radius: 25, child: Icon(icon, size: 25)),
            SizedBox(height: 8),
            Text(
              data,
              textAlign: TextAlign.center,
              maxLines: dataMaxLines,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium,
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.textTheme.labelMedium,
            ),
          ],
        ),
      ),
    ),
  );
  return isFullWidth
      ? Expanded(child: mainComponent)
      : Flexible(fit: FlexFit.tight, child: mainComponent);
}
