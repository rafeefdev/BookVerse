import 'package:uuid/uuid.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
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

  static String _generateInternalId(String googleBooksId) {
    return Uuid().v5(Namespace.url.value, 'google-books-$googleBooksId');
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['volumeInfo']['title'] ?? "No Title",
      subTitle: json['volumeInfo']['subtitle'] ?? '',
      authors:
          (json['volumeInfo']['authors'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      pageCount: json['volumeInfo']['pageCount'] ?? 0,
      publisher: json['volumeInfo']['publisher'] ?? "Unknown Publisher",
      categories: json['volumeInfo']['categories'] ?? <String>[],
      publishedDate: json['volumeInfo']['publishedDate'] ?? "Unknown Date",
      description: json['volumeInfo']['description'] ?? "No Description",
      thumbnail: json['volumeInfo']['imageLinks']?['thumbnail'] ?? "",
    );
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
