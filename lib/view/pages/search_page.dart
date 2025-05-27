import 'dart:async';

import 'package:BookVerse/model/book_model.dart';
import 'package:BookVerse/provider/playbook_services_provider.dart';
import 'package:BookVerse/provider/search_provider.dart';
import 'package:BookVerse/view/components.dart';
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

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 80,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: BackButton(),
                ),
                Flexible(
                  child: TextField(
                    controller: queryController,
                    onChanged: onSearchChange,
                    decoration: InputDecoration(
                      hintText: 'Input title, authors, publisher name',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (searchState.isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (searchState.error != null)
            Expanded(
              child: Center(
                child: Text(
                  searchState.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            )
          else if (searchState.result.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: searchState.result.length,
                itemBuilder: (context, index) {
                  Book book = searchState.result[index];
                  return ListTile(
                    leading: book.thumbnail.isNotEmpty
                        ? Image.network(
                            book.thumbnail,
                            width: 50,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.book),
                          )
                        : const Icon(Icons.book),
                    title: Text(book.title),
                    subtitle: Text(
                      book.authors.isNotEmpty
                          ? book.authors.join(', ')
                          : 'Unknown Author',
                    ),
                  );
                },
              ),
            )
          else if (searchState.query.isNotEmpty)
            const Expanded(
              child: Center(
                child: Text('No books found'),
              ),
            ),
        ],
      ),
    );
  }
}
