import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart';

class UserManagementViewModel extends ChangeNotifier {
  static const String baseUrl = "http://10.0.2.2:3000";

  List<UserModel> _allUsers = []; // Danh sách gốc từ Server
  List<UserModel> users = [];     // Danh sách đã qua bộ lọc hiển thị lên UI
  bool isLoading = false;

  // Các chỉ số thống kê (Stats)
  int totalCount = 0;
  int adminCount = 0;
  int lockedCount = 0;

  // Trạng thái bộ lọc hiện tại
  String _currentSearchQuery = '';
  String _currentFilterTab = 'all'; // 'all', 'admin', 'locked'

  Future<void> loadUsers() async {
    isLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      final res = await http.get(Uri.parse('$baseUrl/users'));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        _allUsers = data.map((json) => UserModel.fromJson(json)).toList();

        // Tính toán các chỉ số thống kê
        _calculateStats();

        // Áp dụng bộ lọc đang chọn
        _applyFilter();
      }
    } catch (e) {
      debugPrint("Lỗi khi tải danh sách người dùng: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  // Hàm tính toán số liệu thống kê nhanh
  void _calculateStats() {
    totalCount = _allUsers.length;
    adminCount = _allUsers.where((u) => u.role == 'admin').length;
    lockedCount = _allUsers.where((u) => u.isLocked).length;
  }

  // Cập nhật từ khóa tìm kiếm từ UI
  void searchUsers(String query) {
    _currentSearchQuery = query;
    _applyFilter();
  }

  // Cập nhật tab bộ lọc từ UI
  void changeFilterTab(String tab) {
    _currentFilterTab = tab;
    _applyFilter();
  }

  // Logic cốt lõi để kết hợp cả Tìm kiếm và Bộ lọc Tab
  void _applyFilter() {
    List<UserModel> tempFiltered = List.from(_allUsers);

    // 1. Lọc theo Tab trạng thái
    if (_currentFilterTab == 'admin') {
      tempFiltered = tempFiltered.where((u) => u.role == 'admin').toList();
    } else if (_currentFilterTab == 'locked') {
      tempFiltered = tempFiltered.where((u) => u.isLocked).toList();
    }

    // 2. Lọc tiếp theo từ khóa tìm kiếm (Tên hoặc Email)
    if (_currentSearchQuery.isNotEmpty) {
      final query = _currentSearchQuery.toLowerCase();
      tempFiltered = tempFiltered.where((u) =>
        u.name.toLowerCase().contains(query) || u.email.toLowerCase().contains(query)
      ).toList();
    }

    users = tempFiltered;
    notifyListeners();
  }

  // Xử lý bật/tắt khóa tài khoản
  Future<void> toggleUserLock(String userId, bool isCurrentlyLocked) async {
    try {
      final res = await http.patch(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'isLocked': !isCurrentlyLocked}),
      );
      if (res.statusCode == 200) {
        await loadUsers(); // Tải lại để cập nhật toàn bộ số liệu và UI
      }
    } catch (e) {
      debugPrint("Lỗi khóa tài khoản: $e");
    }
  }

  // Xử lý phân quyền Admin/Customer
  Future<void> toggleUserRole(String userId, String currentRole) async {
    String newRole = currentRole == 'admin' ? 'customer' : 'admin';
    try {
      final res = await http.patch(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'role': newRole}),
      );
      if (res.statusCode == 200) {
        await loadUsers();
      }
    } catch (e) {
      debugPrint("Lỗi phân quyền: $e");
    }
  }
}