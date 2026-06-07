import 'dart:async';
import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/core/shared/components/booklisttile_component.dart';
import 'package:book_verse/core/theme/themes_extension.dart';
import 'package:book_verse/features/search/model/entities/searchstate_model.dart';
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
    _debounce?.cancel();
    queryController.dispose();
    super.dispose();
  }

  void onSearchChange(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        ref.read(searchNotifierProvider.notifier).onQueryChanged(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: 'searchBar',
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerHighest,
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
        backgroundColor: context.colorScheme.surfaceContainerHighest,
        elevation: 0,
      ),
      body: _buildBody(searchState),
    );
  }

  Widget _buildBody(SearchState searchState) {
    if (searchState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (searchState.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: context.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                searchState.error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: context.colorScheme.error),
              ),
            ],
          ),
        ),
      );
    }

    if (searchState.query.isEmpty) {
      return const Center(child: Text('Start typing to search books'));
    }

    if (searchState.result.isEmpty) {
      return const Center(child: Text('No books found'));
    }

    return ListView.builder(
      itemCount: searchState.result.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        List<Book> result = ref.watch(searchNotifierProvider).result;
        Book book = result[index];
        return bookListTile(context, book, isTemporarySource: true);
      },
    );
  }
}
