import 'package:uuid/uuid.dart';

class LibraryFolder {
  final String id;
  final String name;
  final String icon;
  final int sortOrder;
  final DateTime createdAt;
  final int bookCount;

  const LibraryFolder({
    required this.id,
    required this.name,
    this.icon = 'folder',
    this.sortOrder = 0,
    required this.createdAt,
    this.bookCount = 0,
  });

  static String generateId() => const Uuid().v4();

  LibraryFolder copyWith({
    String? id,
    String? name,
    String? icon,
    int? sortOrder,
    DateTime? createdAt,
    int? bookCount,
  }) {
    return LibraryFolder(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      bookCount: bookCount ?? this.bookCount,
    );
  }

  factory LibraryFolder.fromMap(Map<String, dynamic> map, {int bookCount = 0}) {
    return LibraryFolder(
      id: map['id'] as String,
      name: map['name'] as String,
      icon: (map['icon'] as String?) ?? 'folder',
      sortOrder: (map['sort_order'] as int?) ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      bookCount: bookCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibraryFolder &&
          id == other.id &&
          name == other.name &&
          bookCount == other.bookCount &&
          sortOrder == other.sortOrder;

  @override
  int get hashCode => Object.hash(id, name, bookCount, sortOrder);
}
