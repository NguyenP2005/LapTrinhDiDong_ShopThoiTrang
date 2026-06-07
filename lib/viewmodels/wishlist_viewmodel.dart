import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class WishlistViewModel extends ChangeNotifier {
  List<Product> _wishlistItems = [];

  List<Product> get wishlistItems => _wishlistItems;

  WishlistViewModel() {
    loadWishlist();
  }

  // Load dữ liệu từ bộ nhớ máy
  Future<void> loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final String? wishlistString = prefs.getString('user_wishlist');

    if (wishlistString != null) {
      List<dynamic> decoded = jsonDecode(wishlistString);
      _wishlistItems = decoded.map((item) => Product.fromJson(item)).toList();
      notifyListeners();
    }
  }

  // Lưu dữ liệu xuống bộ nhớ máy
  Future<void> _saveWishlist() async {
    final prefs = await SharedPreferences.getInstance();

    // Đã xóa dòng categoryIdđể khớp với Model Product của nhóm
    List<Map<String, dynamic>> encodedList = _wishlistItems.map((item) => {
      'id': item.id,
      'name': item.name,
      'image': item.image,
      'price': item.price,
      'rating': item.rating,
      'description': item.description,
    }).toList();

    await prefs.setString('user_wishlist', jsonEncode(encodedList));
  }

  // Kiểm tra xem sản phẩmđã có trong wishlist chưa
  bool isFavorite(String productId) {
    return _wishlistItems.any((item) => item.id == productId);
  }

  // Bấm tim (Thêm hoặc Xóa)
  void toggleFavorite(Product product) {
    if (isFavorite(product.id)) {
      _wishlistItems.removeWhere((item) => item.id == product.id);
    } else {
      _wishlistItems.add(product);
    }
    _saveWishlist();
    notifyListeners();
  }
}