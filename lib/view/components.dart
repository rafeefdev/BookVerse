import 'package:BookVerse/helper/push_navigation.dart';
import 'package:BookVerse/view/pages/detail_page.dart';
import 'package:flutter/material.dart';
import 'package:BookVerse/model/book_model.dart';
import 'package:BookVerse/provider/playbook_services_provider.dart';

Widget bookGridTile(Book book, TextTheme textTheme) {
  return AspectRatio(
    aspectRatio: 3 / 4,
    child: Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 0.05, color: Colors.black),
        ),
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            book.thumbnail.isNotEmpty
                ? Expanded(
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black, width: 0.05),
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: NetworkImage(book.thumbnail),
                        ),
                      ),
                    ),
                  ),
                )
                : Expanded(
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black, width: 0.05),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.book,
                          size: 48,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
            Padding(
              padding: const EdgeInsets.only(left: 6, top: 4),
              child: SizedBox(
                height: 72,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.book, color: Colors.grey[600]),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            book.title.length < 25
                                ? book.title
                                : '${book.title.substring(0, 25)}...',
                            style: textTheme.labelLarge,
                            maxLines: 3,
                            overflow: TextOverflow.fade,
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.person, color: Colors.grey[600]),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            bookAuthors(book),
                            maxLines: 1,
                            style: textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Container dotIndicator(bool isIndexed) {
  return Container(
    height: 8,
    width: 8,
    margin: const EdgeInsets.symmetric(horizontal: 2),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: isIndexed ? Colors.deepPurple : Colors.purple,
    ),
  );
}

Widget nextButton(BuildContext context, {required Widget nextScreen}) {
  return Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white,
      border: Border.all(color: Colors.black, width: 0.1),
    ),
    child: IconButton(
      icon: const Icon(Icons.arrow_forward_ios_rounded),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => nextScreen),
        );
      },
    ),
  );
}

Widget simpleSearcBar(
  BuildContext context, {
  required VoidCallback onTap,
  bool isExpanded = false,
}) {
  Widget searchBar = SearchBar(
    padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16)),
    elevation: const WidgetStatePropertyAll(4),
    leading: const Icon(Icons.search),
    hintText: 'Search',
    onTap: onTap,
  );
  return isExpanded ? Expanded(child: searchBar) : searchBar;
}

Widget bookListTile(BuildContext context, Book book, {bool isWrappedByCard = false}) {
  Widget lisTile = InkWell(
    onTap: pushNavigation(context, destinationPage: DetailPage(selectedBookId: book.id)),
    child: ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading:
          book.thumbnail.isNotEmpty
              ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  book.thumbnail,
                  width: 50,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => const Icon(Icons.book),
                ),
              )
              : Container(
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

  return isWrappedByCard
      ? Card(
        elevation: 2.6,
        margin: const EdgeInsets.only(bottom: 12),
        child: lisTile,
      )
      : lisTile;
}
