class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String categoryId;
  final List<String> images;
  final bool isActive;
  final double avgRating;
  final String brandName;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.categoryId,
    required this.images,
    required this.brandName,
    this.isActive = true,
    this.avgRating = 0.0,
  });

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? categoryId,
    List<String>? images,
    String? brandName,
    bool? isActive,
    double? avgRating,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      categoryId: categoryId ?? this.categoryId,
      images: images ?? this.images,
      brandName: brandName ?? this.brandName,
      isActive: isActive ?? this.isActive,
      avgRating: avgRating ?? this.avgRating,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock'] as int? ?? 0,
      categoryId: json['categoryId'] as String? ?? '',
      images: (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      brandName: json['brandName'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      avgRating: (json['avgRating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'categoryId': categoryId,
      'images': images,
      'brandName': brandName,
      'isActive': isActive,
      'avgRating': avgRating,
    };
  }
}
