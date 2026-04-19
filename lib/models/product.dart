class Product {
  final String id;
  final String name;
  final double price;
  final String image;
  final String description;
  final int catergoryID;
  final double rating;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.description,
    required this.catergoryID,
    required this.rating,
    required this.stock,
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
    );
  }
}
