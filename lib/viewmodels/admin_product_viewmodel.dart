import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class AdminProductViewModel extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Product> _allProducts = [];
  List<Product> products = [];
  List<Category> categories = [];

  bool isLoading = false;
  String? errorMessage;
  String _searchQuery = '';
  int? _selectedCategoryId; // null = Tất cả

  String get searchQuery => _searchQuery;
  int? get selectedCategoryId => _selectedCategoryId;

  // ─── LOAD DATA ────────────────────────────────────────────────────────────

  Future<void> fetchAll() async {
    isLoading = true;
    errorMessage = null;
    Future.microtask(() => notifyListeners());

    try {
      final results = await Future.wait([
        _api.getProducts(),
        _api.getCategories(),
      ]);
      _allProducts = results[0] as List<Product>;
      categories = results[1] as List<Category>;
      _applyFilters();
    } catch (e) {
      errorMessage = 'Không thể tải dữ liệu: $e';
    }

    isLoading = false;
    notifyListeners();
  }

  // ─── SEARCH & FILTER ──────────────────────────────────────────────────────

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setCategory(int? categoryId) {
    _selectedCategoryId = categoryId;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    List<Product> result = List.from(_allProducts);

    if (_selectedCategoryId != null) {
      result = result.where((p) => p.catergoryID == _selectedCategoryId).toList();
    }

    if (_searchQuery.isNotEmpty) {
      result = result
          .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    products = result;
  }

  // ─── CRUD ─────────────────────────────────────────────────────────────────

  Future<bool> addProduct(Map<String, dynamic> data) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final newProduct = await _api.createProduct(data);
      if (newProduct != null) {
        _allProducts.add(newProduct);
        _applyFilters();
        isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      errorMessage = 'Thêm sản phẩm thất bại: $e';
    }

    isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> editProduct(String id, Map<String, dynamic> data) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final updated = await _api.updateProduct(id, data);
      if (updated != null) {
        final idx = _allProducts.indexWhere((p) => p.id == id);
        if (idx != -1) {
          _allProducts[idx] = updated;
        }
        _applyFilters();
        isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      errorMessage = 'Cập nhật sản phẩm thất bại: $e';
    }

    isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> removeProduct(String id) async {
    errorMessage = null;

    try {
      final success = await _api.deleteProduct(id);
      if (success) {
        _allProducts.removeWhere((p) => p.id == id);
        _applyFilters();
        notifyListeners();
        return true;
      }
    } catch (e) {
      errorMessage = 'Xóa sản phẩm thất bại: $e';
      notifyListeners();
    }

    return false;
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────

  String getCategoryName(int categoryId) {
    final cat = categories.where(
      (c) => int.tryParse(c.id) == categoryId,
    ).firstOrNull;
    return cat?.name ?? 'Khác';
  }

  String formatPrice(double price) {
    return '${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ';
  }
}
