import 'package:flutter/material.dart';

Widget simpleSearcBar(
  BuildContext context, {
  required VoidCallback onTap,
  bool isExpanded = false,
}) {
  Widget searchBar = SearchBar(
    padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16)),
    elevation: const WidgetStatePropertyAll(4),
    leading: const Icon(Icons.search),
    hintText: 'Search',
    onTap: onTap,
  );
  return isExpanded ? Expanded(child: searchBar) : searchBar;
}
