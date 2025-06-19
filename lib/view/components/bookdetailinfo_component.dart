import 'package:book_verse/shared/themes_extension.dart';
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
    height: 156,
    child: Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          CircleAvatar(radius: 25, child: Icon(icon, size: 25)),
          SizedBox(height: 8),
          Text(
            data,
            textAlign: TextAlign.center,
            maxLines: dataMaxLines,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.titleMedium,
          ),
          Text(title, style: context.textTheme.bodyMedium),
        ],
      ),
    ),
  );
  return isFullWidth
      ? Expanded(child: mainComponent)
      : Flexible(fit: FlexFit.tight, child: mainComponent);
}
