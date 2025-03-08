class Book {
  final String id;
  final String title;
  final List<String> authors;
  final String publisher;
  final String publishedDate;
  final String description;
  final String thumbnail;

  Book({
    required this.id,
    required this.title,
    required this.authors,
    required this.publisher,
    required this.publishedDate,
    required this.description,
    required this.thumbnail,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['volumeInfo']['title'] ?? "No Title",
      authors:
          (json['volumeInfo']['authors'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      publisher: json['volumeInfo']['publisher'] ?? "Unknown Publisher",
      publishedDate: json['volumeInfo']['publishedDate'] ?? "Unknown Date",
      description: json['volumeInfo']['description'] ?? "No Description",
      thumbnail: json['volumeInfo']['imageLinks']?['thumbnail'] ?? "",
    );
  }
}
