import 'package:uuid/uuid.dart';
import 'dart:convert';

class Book {
  final String id;
  final String title;
  final String? subTitle;
  final List<String> authors;
  final String publisher;
  final String publishedDate;
  final String description;
  final String thumbnail;
  bool isFavorite = false;
  int pageCount = 0;
  List? categories;

  Book({
    required this.id,
    required this.title,
    required this.subTitle,
    required this.authors,
    required this.publisher,
    required this.publishedDate,
    required this.description,
    required this.thumbnail,
    bool isFavorite = false,
    required this.pageCount,
    this.categories,
  });

  static String generateInternalId(String googleBooksId) {
    return Uuid().v5(Namespace.url.value, 'google-books-$googleBooksId');
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    // Handles both nested data from Google API ('volumeInfo') and flat data from local DB.
    final info = json['volumeInfo'] as Map<String, dynamic>? ?? json;

    // Handles fields that might be Lists or JSON-encoded Strings (from local DB).
    List<String> parseList(dynamic value) {
      if (value is String) {
        try {
          // Try to decode the string as a JSON list.
          final decoded = jsonDecode(value);
          if (decoded is List) {
            return decoded.map((e) => e.toString()).toList();
          }
        } catch (e) {
          // If decoding fails, return an empty list.
          return [];
        }
      }
      if (value is List) {
        // If it's already a list, use it directly.
        return value.map((e) => e.toString()).toList();
      }
      // Default to an empty list if it's null or an unexpected type.
      return [];
    }

    return Book(
      id: json['id'],
      title: info['title'] ?? "No Title",
      subTitle: info['subtitle'] ?? info['subTitle'] ?? '',
      authors: parseList(info['authors']),
      pageCount: info['pageCount'] ?? 0,
      publisher: info['publisher'] ?? "Unknown Publisher",
      categories: parseList(info['categories']),
      publishedDate: info['publishedDate'] ?? "Unknown Date",
      description: info['description'] ?? "No Description",
      thumbnail: info['imageLinks']?['thumbnail'] ?? info['thumbnail'] ?? "",
      isFavorite: (info['isFavorite'] == 1 || info['isFavorite'] == true),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subTitle': subTitle,
      'authors': jsonEncode(authors), // simpan sebagai string JSON
      'pageCount': pageCount,
      'publisher': publisher,
      'categories': jsonEncode(categories ?? []), // simpan sebagai string JSON
      'publishedDate': publishedDate,
      'description': description,
      'thumbnail': thumbnail,
      'isFavorite':
          isFavorite ? 1 : 0, // simpan sebagai int (SQLite tidak punya bool)
    };
  }

  Book copyWith({
    String? id,
    String? title,
    String? subTitle,
    List<String>? authors,
    String? publisher,
    String? publishedDate,
    String? description,
    String? thumbnail,
    bool? isFavorite,
    int? pageCount,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      subTitle: subTitle ?? this.subTitle,
      authors: authors ?? this.authors,
      publisher: publisher ?? this.publisher,
      publishedDate: publishedDate ?? this.publishedDate,
      description: description ?? this.description,
      thumbnail: thumbnail ?? this.thumbnail,
      isFavorite: isFavorite ?? this.isFavorite,
      pageCount: pageCount ?? this.pageCount,
    );
  }
}
