import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/core/shared/components/bookgridtile_component.dart';
import 'package:book_verse/core/shared/components/booklisttile_component.dart';
import 'package:book_verse/core/shared/themes_extension.dart';
import 'package:book_verse/features/bookmarks/viewmodel/bookmark_viewmodel.dart';
import 'package:book_verse/features/home/view/pages/detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ViewMode { grid, list }

// Provider using Riverpod code generation
final viewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.list);

class SavedbookPage extends ConsumerWidget {
  const SavedbookPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;
    final viewMode = ref.watch(viewModeProvider);
    final bookmarkedBooks = ref.watch(bookmarkNotifierProvider);

    return bookmarkedBooks.when(
      data: (data) {
        return _buildSavedBooksPage(screenHeight, context, viewMode, ref, data);
      },
      loading: () => _buildLoadingIndicatorPage(),
      error: (error, stack) {
        return _buildErrorInfo(error, stack);
      },
    );
  }

  Widget _buildLoadingIndicatorPage() {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Books Page')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorInfo(Object error, StackTrace stack) {
    debugPrintStack(label: error.toString(), stackTrace: stack);
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Books Page')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded),
            Text('Error Occured'),
            Text('$error : $stack'),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedBooksPage(
    double screenHeight,
    BuildContext context,
    ViewMode viewMode,
    WidgetRef ref,
    List<Book> data,
  ) {
    return Scaffold(
      body: Column(
        children: [
          // Top section - 20% of screen height
          Container(
            height: screenHeight * 0.15,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8,
              children: [
                // Title on the left
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Favorite Book List',
                        style: context.textTheme.titleLarge,
                      ),
                      Text(
                        'Your favorite book will displayed below',
                        style: context.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 180,
                    child: SegmentedButton<ViewMode>(
                      segments: const [
                        ButtonSegment<ViewMode>(
                          value: ViewMode.grid,
                          icon: Icon(Icons.grid_view),
                          label: Text('Grid'),
                        ),
                        ButtonSegment<ViewMode>(
                          value: ViewMode.list,
                          icon: Icon(Icons.view_list),
                          label: Text('List'),
                        ),
                      ],
                      selected: {viewMode},
                      onSelectionChanged: (Set<ViewMode> value) {
                        ref.read(viewModeProvider.notifier).state = value.first;
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          data.isEmpty
              ? Expanded(child: Center(child: Text('Data is empty')))
              :
              // Book list/grid view - remaining screen space
              Expanded(
                child:
                    viewMode == ViewMode.grid
                        ? _buildGridView(data)
                        : _buildListView(data),
              ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<Book> books) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        return _buildBookCard(context, books[index]);
      },
    );
  }

  Widget _buildListView(List<Book> books) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: books.length,
      itemBuilder: (context, index) {
        return bookListTile(
          context,
          books[index],
          isWrappedByCard: true,
          isTemporarySource: false,
        );
      },
    );
  }

  Widget _buildBookCard(BuildContext context, Book book) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => DetailPage(
                  selectedBookId: book.id,
                  isTemporarySource: false,
                ),
          ),
        );
      },
      child: bookGridTile(book: book, textTheme: Theme.of(context).textTheme),
    );
  }
}
