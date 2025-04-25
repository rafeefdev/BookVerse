import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_book/model/book_model.dart';
import 'package:google_book/provider/bookmark_provider.dart';
import 'package:google_book/provider/playbook_services_provider.dart';
import 'package:google_book/view/components.dart';
import 'package:google_book/view/pages/detail_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:google_book/provider/bookmark_provider.dart';

enum ViewMode { grid, list }

// Provider using Riverpod code generation
final viewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.list);

class SavedbookPage extends ConsumerWidget {
  const SavedbookPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;
    final viewMode = ref.watch(viewModeProvider);
    final List<Book> bookmarkedBooks = ref.watch(bookmarkedBooksProvider);

    return Scaffold(
      body: Column(
        children: [
          // Top section - 20% of screen height
          Container(
            height: screenHeight * 0.1,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title on the left
                    const Text(
                      'Favorite Book List',
                      style: TextStyle(
                        fontSize: 24, // Material Design headline4 size
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Segmented button on the right
                    SegmentedButton<ViewMode>(
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
                  ],
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
        return _buildBookListTile(books[index]);
      },
    );
  }

  Widget _buildBookCard(BuildContext context, Book book) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(selectedBookId: book.id),
          ),
        );
      },
      child: bookGridTile(book, Theme.of(context).textTheme),
    );
  }

  Widget _buildBookListTile(Book book) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(child: Icon(Icons.book, color: Colors.grey[600])),
        ),
        title: Text(
          book.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(bookAuthors(book)),
      ),
    );
  }
}
