import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;
import '../model/book_model.dart';

part 'playbook_services_provider.g.dart';

@riverpod
class BookNotifier extends _$BookNotifier {
  @override
  List<Book> build() => [];

  bool _isLoading = false;
  int statusCode = 0;

  //declare getter
  List<Book> get books => state;
  bool get isLoading => _isLoading;

  //store apikey and base url
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
          state =
              (data['items'] as List)
                  .map((item) => Book.fromJson(item))
                  .toList();
          List<Book> newState = [...state];
          state = newState;
        } else {
          state = [];
        }
      } else {
        throw Exception("Gagal mengambil data buku");
      }
    } catch (error) {
      state = [];
      log("Error: $error");
    }

    _isLoading = false;
  }
}
