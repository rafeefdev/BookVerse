import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_book/model/book_model.dart';
import 'package:google_book/provider/playbook_services_provider.dart';
import 'package:google_book/view/components.dart';
import 'package:google_book/view/pages/detail_page.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var textTheme = Theme.of(context).textTheme;
    List<Book> books = ref.watch(bookNotifierProvider);
    bool isLoading = ref.watch(bookNotifierProvider.notifier).isLoading;

    // Panggil fetchBooks() hanya saat pertama kali widget dibangun
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (books.isEmpty) {
        ref.watch(bookNotifierProvider.notifier).fetchBooks('', 20);
      }
    });

    return Scaffold(
      appBar: AppBar(
        actionsPadding: EdgeInsets.only(right: 16),
        title: SizedBox(
          height: 45,
          child: SearchBar(
            elevation: WidgetStatePropertyAll(4),
            leading: Icon(Icons.search),
            hintText: 'Search',
          ),
        ),
        actions: [
          IconButton.filledTonal(onPressed: () {}, icon: Icon(Icons.settings)),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(bookNotifierProvider.notifier).fetchBooks('', 20);
        },
        child:
            isLoading
                ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
                : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                              builder:
                                  (context) => DetailPage(selectedBook: book),
                            ),
                          );
                        },
                        child: bookGridTile(book, textTheme),
                      );
                    },
                    itemCount: books.length,
                  ),
                ),
      ),
    );
  }
}
