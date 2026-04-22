import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserManagementViewModel extends ChangeNotifier {
  static const String baseUrl = "http://10.0.2.2:3000";
  List<dynamic> users = [];
  bool isLoading = false;

  // 1. Lấy danh sách tài khoản
  Future<void> loadUsers() async {
    isLoading = true;
    notifyListeners();
    try {
      final res = await http.get(Uri.parse('$baseUrl/users'));
      if (res.statusCode == 200) {
        users = jsonDecode(res.body);
      }
    } catch (e) {
      print("Lỗi load users: $e");
    }
    isLoading = false;
    notifyListeners();
  }

  // 2. Khóa / Mở khóa tài khoản
  Future<void> toggleUserLock(String userId, bool isCurrentlyLocked) async {
    try {
      final res = await http.patch(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'isLocked': !isCurrentlyLocked}),
      );
      if (res.statusCode == 200) {
        await loadUsers(); // Load lại danh sách sau khi sửa
      }
    } catch (e) {
      print("Lỗi khóa tài khoản: $e");
    }
  }

  // 3. Phân quyền Quản trị / Khách hàng
  Future<void> toggleUserRole(String userId, String currentRole) async {
    String newRole = currentRole == 'admin' ? 'user' : 'admin';
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
      print("Lỗi phân quyền: $e");
    }
  }
}