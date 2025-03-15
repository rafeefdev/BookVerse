import 'dart:convert';
import 'dart:developer';

import 'package:google_book/model/book_model.dart';
import 'package:http/http.dart' as http;

class PlaybookServices {
  static int statusCode = 0;

  static Uri generateUrl(String query, int maxResult) {
    const String apiKey = "AIzaSyBG-P8d1130vH1HBR-Gq_rz9eOOeUQ_4OA";
    const String baseUrl = "https://www.googleapis.com/books/v1/volumes";
    return Uri.parse(
      "$baseUrl?q=subject:$query&printType=books&maxResults=$maxResult&key=$apiKey",
    );
  }

  static Future<List<Book>?> getBookData(String query, int maxResult) async {
    List<Book> result = [];
    //run http get method with await and save result to a variabel
    try {
      final response = await http.get(generateUrl(query, maxResult));
      if (response.statusCode == 200) {
        statusCode = response.statusCode;
        log('status code : ${response.statusCode}');
        //decode response
        final bookList = jsonDecode(response.body);
        if (bookList['items'] != null) {
          result =
              (bookList['items'] as List)
                  .map((item) => Book.fromJson(item))
                  .toList();
          return result;
        }
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
