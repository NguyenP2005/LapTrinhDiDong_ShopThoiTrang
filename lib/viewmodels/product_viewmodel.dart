import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../services/api_service.dart';

class ProductViewModel extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Product> products = [];
  List<Category> categories = [];
  bool isLoading = false;

  // Tải song song products + categories
  Future<void> fetchProducts() async {
    isLoading = true;
    notifyListeners();

    try {
      // Gọi song song cho nhanh
      final results = await Future.wait([
        _api.getProducts(),
        _api.getCategories(),
      ]);
      products = results[0] as List<Product>;
      categories = results[1] as List<Category>;
    } catch (e) {
      debugPrint("ERROR FETCH PRODUCTS: $e");
      products = [];
      categories = [];
    }

    isLoading = false;
    notifyListeners();
  }
}
