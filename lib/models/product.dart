class Product {
  final String id;
  final String name;
  final double price;
  final String image;
  final String description;
  final int catergoryID;
  final double rating;
  final int stock;
  final List<String> sizes;
  final List<String> colors;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.description,
    required this.catergoryID,
    required this.rating,
    required this.stock,
    this.sizes = const [],
    this.colors = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? "",
      price: (json['price'] ?? 0).toDouble(),
      image: json['image'] ?? "",
      description: json['description'] ?? "",
      catergoryID: int.tryParse(json['category_id'].toString()) ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      sizes: json['sizes'] != null ? List<String>.from(json['sizes']) : [],
      colors: json['colors'] != null ? List<String>.from(json['colors']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'image': image,
      'description': description,
      'category_id': catergoryID,
      'rating': rating,
      'stock': stock,
      'sizes': sizes,
      'colors': colors,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? image,
    String? description,
    int? catergoryID,
    double? rating,
    int? stock,
    List<String>? sizes,
    List<String>? colors,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      image: image ?? this.image,
      description: description ?? this.description,
      catergoryID: catergoryID ?? this.catergoryID,
      rating: rating ?? this.rating,
      stock: stock ?? this.stock,
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
    );
  }
}
