import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_book/model/book_model.dart';
import 'package:google_book/provider/playbook_services_provider.dart';
import 'package:google_book/view/components.dart';
import 'package:google_book/view/pages/detail_page.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
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
      appBar: AppBar(
        actionsPadding: const EdgeInsets.only(right: 16),
        title: SizedBox(
          height: 45,
          child: SearchBar(
            elevation: const WidgetStatePropertyAll(4),
            leading: const Icon(Icons.search),
            hintText: 'Search',
          ),
        ),
        actions: [
          IconButton.filledTonal(
            onPressed: () {},
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
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
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  Book book = books[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(selectedBook: book),
                        ),
                      );
                    },
                    child: bookGridTile(book, textTheme),
                  );
                },
                itemCount: books.length,
              ),
            );
          },
        ),
      ),
    );
  }
}
