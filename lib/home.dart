import 'package:flutter/material.dart';
import 'package:google_book/book_model.dart';
import 'package:google_book/components.dart';
import 'package:google_book/detail_page.dart';
import 'package:google_book/playbook_services.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    Provider.of<BookProvider>(context, listen: false).fetchBooks('economy', 30);
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Consumer<BookProvider>(
          builder: (context, provider, _) {
            List<Book> books = provider.books;
            return RefreshIndicator(
              onRefresh: () async {
                await provider.fetchBooks('indonesia', 30);
              },
              child:
                  provider.isLoading
                      ? Center(child: CircularProgressIndicator())
                      : GridView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: books.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          mainAxisSpacing: 6,
                          crossAxisSpacing: 6,
                          crossAxisCount: 2,
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
                                      (context) =>
                                          DetailPage(selectedBook: book),
                                ),
                              );
                            },
                            child: bookGridTile(book, textTheme),
                          );
                        },
                      ),
            );
          },
        ),
      ),
    );
  }
}
