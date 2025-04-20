import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_book/model/book_model.dart';
import 'package:google_book/provider/playbook_services_provider.dart';
import 'package:google_book/view/components.dart';
import 'package:google_book/view/pages/detail_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomeState();
}

class _HomeState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    // Panggil fetchBooks() hanya saat pertama kali widget dibangun
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentState = ref.read(bookNotifierProvider);
      if (currentState.data.isEmpty) {
        ref.read(bookNotifierProvider.notifier).fetchBooks('', 20);
      }
    });

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(bookNotifierProvider.notifier)
              .fetchBooks('flutter', 30);
        },
        child: Consumer(
          builder: (context, ref, _) {
            final state = ref.watch(bookNotifierProvider);
            if (state.status == 'loading') {
              return const Center();
            }
            if (state.status == 'failed') {
              return Center(child: Text(state.message));
            }
            List<Book> books = state.data ?? [];
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 140,
                  collapsedHeight: 140,
                  pinned: true,
                  //snap: true,
                  floating: true,
                  flexibleSpace: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        Text(
                          'BookVerse App',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: SearchBar(
                                padding: WidgetStatePropertyAll(
                                  EdgeInsets.symmetric(horizontal: 16),
                                ),
                                elevation: const WidgetStatePropertyAll(4),
                                leading: const Icon(Icons.search),
                                hintText: 'Search',
                              ),
                            ),
                            IconButton(
                              splashColor: Colors.red,
                              onPressed: () {},
                              icon: CircleAvatar(
                                radius: 25,
                                child: Icon(Icons.settings, size: 30),
                              ),
                            ),
                            IconButton(
                              splashColor: Colors.red,
                              onPressed: () {},
                              icon: CircleAvatar(
                                radius: 25,
                                child: Icon(Icons.person_2, size: 30),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      Book book = books[index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      DetailPage(selectedBookId: book.id),
                            ),
                          );
                        },
                        child: bookGridTile(book, textTheme),
                      );
                    }, childCount: books.length),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
