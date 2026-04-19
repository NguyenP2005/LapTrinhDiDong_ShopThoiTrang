import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductViewModel extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Product> products = [];
  bool isLoading = false;
  Future<void> fetchProducts() async {
    isLoading = true;
    notifyListeners();

    try {
      products = await _api.getProducts();
    } catch (e) {
      print(" ERROR FETCH PRODUCTS: $e");
      products = [];
    }

    isLoading = false;
    notifyListeners();
  }
}
