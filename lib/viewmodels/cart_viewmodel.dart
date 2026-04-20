import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';

class CartViewModel extends ChangeNotifier {
  final CartService _cartService = CartService();
  List<CartItem> _items = [];

  List<CartItem> get items => _items;
  int get totalCount => _items.fold(0, (sum, e) => sum + e.quantity);
  double get totalPrice =>
      _items.fold(0, (sum, e) => sum + e.price * e.quantity);

  Future<void> loadCart() async {
    _items = await _cartService.getCartItems();
    notifyListeners();
  }

  Future<void> addToCart(CartItem item) async {
    await _cartService.addToCart(item);
    await loadCart();
  }

  Future<void> removeFromCart(String productId) async {
    await _cartService.removeFromCart(productId);
    await loadCart();
  }

  // cập nhật số lượng trực tiếp
  Future<void> updateQuantity(String productId, int newQuantity) async {
    await _cartService.updateQuantity(productId, newQuantity);
    await loadCart();
  }
}
