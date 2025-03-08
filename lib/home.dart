import 'package:flutter/material.dart';
import 'package:google_book/book_model.dart';
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
    Provider.of<BookProvider>(context, listen: false).fetchBooks('history');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Consumer<BookProvider>(
          builder: (context, provider, _) {
            List<Book> books = provider.books;
            return GridView.builder(
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
                return Card(
                  elevation: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(width: 0.05, color: Colors.black),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 8.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Center(child: Image.network(book.thumbnail)),
                        ),
                        Text(book.title),
                        Text(
                          book.authors.length > 1
                              ? "${book.authors[0]}, dkk"
                              : book.authors[0],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
