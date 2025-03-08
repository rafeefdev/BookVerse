import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'book_model.dart';

class BookProvider with ChangeNotifier {
  List<Book> _books = [];
  bool _isLoading = false;
  int statusCode = 0;

  //declare getter
  List<Book> get books => _books;
  bool get isLoading => _isLoading;

  static const String _apiKey = "AIzaSyBG-P8d1130vH1HBR-Gq_rz9eOOeUQ_4OA";
  static const String _baseUrl = "https://www.googleapis.com/books/v1/volumes";

  Future<void> fetchBooks(String query, int maxResult) async {
    //set ui to loading state to fetch data
    _isLoading = true;

    try {
      //parse String url to Uri
      Uri url = Uri.parse(
        "$_baseUrl?q=subject:$query&printType=books&maxResults=$maxResult&key=$_apiKey",
      );
      //save response JSON file to a variable
      final response = await http.get(url);

      //if status code show that request is succesfull
      if (response.statusCode == 200) {
        statusCode = response.statusCode;
        log('status code : $statusCode');
        //decode json response and save data to a variabel
        final data = json.decode(response.body);
        if (data['items'] != null) {
          _books =
              (data['items'] as List)
                  .map((item) => Book.fromJson(item))
                  .toList();
        } else {
          _books = [];
        }
      } else {
        throw Exception("Gagal mengambil data buku");
      }
    } catch (error) {
      _books = [];
      log("Error: $error");
    }

    _isLoading = false;
    notifyListeners();
  }
}
