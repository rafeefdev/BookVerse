import 'dart:convert';
import 'dart:developer';
import 'package:book_verse/core/models/book_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class PlaybookServices {
  static const _apiKeyName = 'GOOGLE_BOOKS_API_KEY';
  static const _baseUrl = "https://www.googleapis.com/books/v1/volumes";

  Uri generateUrl({
    String? query,
    int maxResult = 30,
    String? author,
    String? title,
    String? publisher,
  }) {
    final apiKey = dotenv.env[_apiKeyName];
    if (apiKey == null || apiKey.isEmpty || apiKey == 'default_value') {
      throw Exception(
        'Google Books API key not found. Set $_apiKeyName in .env file.',
      );
    }

    String baseQuery = query ?? '';
    String authorQuery = author == null ? '' : '+inauthor:$author';
    String titleQuery = title == null ? '' : '+intitle:$title';
    String publisherQuery = publisher == null ? '' : '+inpublisher:$publisher';

    return Uri.parse(
      "$_baseUrl?q=$baseQuery$authorQuery$publisherQuery$titleQuery&printType=books&maxResults=$maxResult&key=$apiKey",
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
    String? publisher,
  }) async {
    try {
      final response = await http.get(
        generateUrl(
          query: query,
          maxResult: maxResult,
          author: author,
          title: title,
          publisher: publisher,
        ),
      );

      log('Google Books API status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final bookList = jsonDecode(response.body);
        if (bookList['items'] != null) {
          return (bookList['items'] as List)
              .map((item) => Book.fromJson(item))
              .toList();
        }
        return [];
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception(
          'API authentication failed. Check your Google Books API key.',
        );
      }

      throw Exception('Failed to load books: ${response.statusCode}');
    } on Exception {
      rethrow;
    } catch (e) {
      log('Unexpected error fetching books: $e');
      throw Exception('Failed to load books: $e');
    }
  }
}
