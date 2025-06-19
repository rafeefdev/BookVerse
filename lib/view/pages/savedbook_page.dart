import 'package:book_verse/shared/themes_extension.dart';
import 'package:book_verse/view/components/bookgridtile_component.dart';
import 'package:book_verse/view/components/booklisttile_component.dart';
import 'package:book_verse/view/pages/detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_verse/model/book_model.dart';
import 'package:book_verse/provider/bookmark_provider.dart';

enum ViewMode { grid, list }

// Provider using Riverpod code generation
final viewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.list);

class SavedbookPage extends ConsumerWidget {
  const SavedbookPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;
    final viewMode = ref.watch(viewModeProvider);
    final List<Book> bookmarkedBooks = ref.watch(bookmarkNotifierProvider);

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
          bookmarkedBooks.isEmpty
              ? Expanded(child: Center(child: Text('Data is empty')))
              :
              // Book list/grid view - remaining screen space
              Expanded(
                child:
                    viewMode == ViewMode.grid
                        ? _buildGridView(bookmarkedBooks)
                        : _buildListView(bookmarkedBooks),
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
