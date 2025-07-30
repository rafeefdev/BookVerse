import 'dart:async';
import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/core/shared/components/booklisttile_component.dart';
import 'package:book_verse/core/shared/themes_extension.dart';
import 'package:book_verse/features/search/viewmodel/search_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final queryController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    queryController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void onSearchChange(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(searchNotifierProvider.notifier).onQueryChanged(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchNotifierProvider);
    bool isDarkMode = context.theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: 'searchBar',
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: queryController,
                autofocus: true,
                decoration: InputDecoration.collapsed(hintText: 'Search...'),
                onChanged: onSearchChange,
              ),
            ),
          ),
        ),
        backgroundColor: isDarkMode ? Colors.grey[600] : Colors.grey.shade200,
        elevation: 0,
      ),
      body:
          searchState.result.isEmpty
              ? Center(child: const Text('Book will appear here'))
              : ListView.builder(
                itemCount: searchState.result.length,
                physics: BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  List<Book> result = ref.watch(searchNotifierProvider).result;
                  Book book = result[index];
                  return bookListTile(context, book, isTemporarySource: true);
                },
              ),
    );
  }
}
