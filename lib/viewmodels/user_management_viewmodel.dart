import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart'; // Đừng quên import Model

class UserManagementViewModel extends ChangeNotifier {
  static const String baseUrl = "http://10.0.2.2:3000";

  List<UserModel> users = []; // Đổi từ dynamic sang UserModel
  bool isLoading = false;

  Future<void> loadUsers() async {
    isLoading = true;
    // Dùng Future.microtask để tránh lỗi "setState or markNeedsBuild called during build"
    Future.microtask(() => notifyListeners());

    try {
      final res = await http.get(Uri.parse('$baseUrl/users'));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        users = data.map((json) => UserModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint("Lỗi load users: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> toggleUserLock(String userId, bool isCurrentlyLocked) async {
    try {
      final res = await http.patch(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'isLocked': !isCurrentlyLocked}),
      );
      if (res.statusCode == 200) {
        await loadUsers(); // Gọi lại danh sách để update UI
      }
    } catch (e) {
      debugPrint("Lỗi khóa tài khoản: $e");
    }
  }

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