import 'package:hive_flutter/hive_flutter.dart';

part 'book_model.g.dart';

@HiveType(typeId: 1)
class Book {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? subTitle;

  @HiveField(3)
  final List<String> authors;

  @HiveField(4)
  final String publisher;

  @HiveField(5)
  final String publishedDate;

  @HiveField(6)
  final String description;

  @HiveField(7)
  final String thumbnail;
  
  @HiveField(8)
  bool isFavorite;
  
  @HiveField(9)
  int pageCount;

  Book({
    required this.id,
    required this.title,
    required this.subTitle,
    required this.authors,
    required this.publisher,
    required this.publishedDate,
    required this.description,
    required this.thumbnail,
    this.isFavorite = false,
    this.pageCount = 0,
  });

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
