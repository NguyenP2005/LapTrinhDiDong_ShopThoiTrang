import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/cart_item.dart';
import '../services/cart_service.dart';

class CartViewModel extends ChangeNotifier {
  final CartService _cartService = CartService();
  List<CartItem> _items = [];

  static const String _baseUrl = "http://10.0.2.2:3000";

  List<CartItem> get items => _items;
  int get totalCount => _items.fold(0, (sum, e) => sum + e.quantity);
  double get totalPrice =>
      _items.fold(0, (sum, e) => sum + e.price * e.quantity);

  Future<void> loadCart() async {
    _items = await _cartService.getCartItems();
    notifyListeners();
  }

  /// Lấy số lượng tồn kho từ serverđể kiểm tra trước khi thêm/cập nhật
  Future<int> _fetchStock(String productId) async {
    try {
      final res = await http.get(Uri.parse('$_baseUrl/products/$productId'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return (data['stock'] as num?)?.toInt() ?? 0;
      }
    } catch (_) {}
    return 0;
  }

  /// Thêm sản phẩm vào giỏ hàng với kiểm tra tồn kho
  Future<void> addToCart(CartItem item) async {
    // Lấy số lượng hiện tại trong giỏ (nếu sản phẩmđã tồn tại)
    final existingItem = _items.firstWhere(
      (e) => e.productId == item.productId,
      orElse: () => CartItem(
        productId: '',
        name: '',
        price: 0,
        image: '',
        quantity: 0,
      ),
    );
    final currentQtyInCart =
        existingItem.productId.isNotEmpty ? existingItem.quantity : 0;
    final requestedTotal = currentQtyInCart + item.quantity;

    // Kiểm tra tồn kho thực tế từ server
    final stock = await _fetchStock(item.productId);
    if (requestedTotal > stock) {
      throw Exception(
        'Số lượng vượt quá tồn kho! Còn lại: $stock, trong giỏ: $currentQtyInCart',
      );
    }

    await _cartService.addToCart(item);
    await loadCart();
  }

  Future<void> removeFromCart(String productId) async {
    await _cartService.removeFromCart(productId);
    await loadCart();
  }

  /// Cập nhật số lượng với kiểm tra tồn kho
  Future<void> updateQuantity(String productId, int newQuantity) async {
    // Kiểm tra tồn kho thực tế từ server
    final stock = await _fetchStock(productId);
    if (newQuantity > stock) {
      throw Exception(
        'Số lượng vượt quá tồn kho! Tồn kho hiện tại: $stock',
      );
    }

    await _cartService.updateQuantity(productId, newQuantity);
    await loadCart();
  }

  /// Xóa toàn bộ giỏ hàng an toàn (không dùng vòng lặpđể tránh ConcurrentModificationError)
  Future<void> clearCart() async {
    await _cartService.clearCart();
    await loadCart();
  }
}
