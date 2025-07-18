import 'dart:convert';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:book_verse/model/book_model.dart';
import 'package:http/http.dart' as http;

class PlaybookServices {
  static int statusCode = 0;

  static Uri generateUrl({
    String? query,
    int maxResult = 30,
    String? author,
    String? title,
    String? publisher,
  }) {
    String apiKey = dotenv.env['API_KEY'] ?? 'default_value';
    const String baseUrl = "https://www.googleapis.com/books/v1/volumes";

    String baseQuery = query ?? '';
    String authorQuery = author == null ? '' : '+inauthor:$author';
    String titleQuery = title == null ? '' : '+intitle:$title';
    String publisherQuery = publisher == null ? '' : '+inpublisher:$publisher';

    return Uri.parse(
      "$baseUrl?q=$baseQuery$authorQuery$publisherQuery$titleQuery&printType=books&maxResults=$maxResult&key=$apiKey",
    );
  }

  Future<List<Book>?> searchBooks(String query) async {
    return getBookData(query: query);
  }

  Future<List<Book>?> getBookData({
    String? query,
    int maxResult = 30,
    String? author,
    String? title,
    String? publisher
  }) async {
    List<Book> result = [];
    try {
      final response = await http.get(generateUrl(
        query: query,
        maxResult: maxResult,
        author: author,
        title: title,
        publisher: publisher,
      ));
      
      statusCode = response.statusCode;
      log('status code : ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final bookList = jsonDecode(response.body);
        if (bookList['items'] != null) {
          result = (bookList['items'] as List)
              .map((item) => Book.fromJson(item))
              .toList();
          return result;
        }
        return [];
      } else {
        throw Exception('Failed to load books: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching books: $e');
      throw Exception('Failed to load books: $e');
    }
  }
}
