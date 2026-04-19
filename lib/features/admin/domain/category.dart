class Category {
  final String id;
  final String name;
  final String imageUrl;

  Category({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  Category copyWith({
    String? id,
    String? name,
    String? imageUrl,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
