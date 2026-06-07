import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:3000";

  Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<Product?> getProductById(String productId) async {
    final response = await http.get(Uri.parse('$baseUrl/products/$productId'));
    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    }
    return null;
  }

  /// Trừ tồn kho sau khi đặt hàng thành công
  Future<void> updateProductStock(String productId, int newStock) async {
    await http.patch(
      Uri.parse('$baseUrl/products/$productId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'stock': newStock}),
    );
  }

  Future<List<Product>> getProductsByCategory(int categoryId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/products?category_id=$categoryId'));
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((e) => Product.fromJson(e)).toList();
    }
    return [];
  }
}
