import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthViewModel extends ChangeNotifier {
  static const String baseUrl = "http://10.0.2.2:3000";
  bool isLoading = false;
  String? errorMessage;

  Map<String, dynamic>? currentUser;

  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final cleanEmail = email.trim();
      final cleanPassword = password.trim();

      final res = await http.get(Uri.parse('$baseUrl/users?email=$cleanEmail'));
      final data = jsonDecode(res.body) as List;

      if (data.isNotEmpty) {
        final user = data[0];

        if (user['password'].toString() == cleanPassword) {
          // LƯU Ý 2: LƯU LẠI THÔNG TIN VÀO BIẾN SAU KHI CHECK PASS ĐÚNG
          currentUser = user;

          isLoading = false;
          notifyListeners();
          return true; // ĐĂNG NHẬP THÀNH CÔNG!
        }
      }

      errorMessage = "Sai email hoặc mật khẩu!";
    } catch (e) {
      errorMessage = "Lỗi kết nối server!";
    }

    isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Cắt sạch khoảng trắng lúc đăng ký
      final cleanEmail = email.trim();
      final check = await http.get(
        Uri.parse('$baseUrl/users?email=$cleanEmail'),
      );
      final existing = jsonDecode(check.body) as List;

      if (existing.isNotEmpty) {
        errorMessage = "Email đã tồn tại!";
        isLoading = false;
        notifyListeners();
        return false;
      }

      final res = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name.trim(),
          'email': cleanEmail,
          'password': password.trim(),
          'avatar': 'https://i.pravatar.cc/150', // Tự động thêm avatar
          'role': 'user', // Tự động cấp quyền user
        }),
      );

      if (res.statusCode == 201) {
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        errorMessage = "Lỗi khi đăng ký!";
      }
    } catch (e) {
      errorMessage = "Lỗi kết nối server!";
    }

    isLoading = false;
    notifyListeners();
    return false;
  }
}
