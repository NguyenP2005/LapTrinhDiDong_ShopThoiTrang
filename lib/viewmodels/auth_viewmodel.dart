import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class AuthViewModel extends ChangeNotifier {
  static const String baseUrl = "http://10.0.2.2:3000";
  bool isLoading = false;
  String? errorMessage;
  Map<String, dynamic>? currentUser;

  // Chống Spam
  int failedAttempts = 0;
  bool isLocked = false;

  // Kiểm tra xem user đã đăng nhập từ trước chưa (Auto Login)
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('current_user');
    if (userStr != null) {
      currentUser = jsonDecode(userStr);
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    if (isLocked) {
      errorMessage = "Nhập sai quá nhiều. Vui lòng đợi 30 giây!";
      notifyListeners();
      return false;
    }

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
          currentUser = user;
          failedAttempts = 0; // Reset số lần sai

          // Lưu thông tin vào bộ nhớ thiết bị để lần sau Auto Login
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('current_user', jsonEncode(user));
          await prefs.setBool('is_logged_in', true);

          isLoading = false;
          notifyListeners();
          return true; // THÀNH CÔNG
        }
      }

      // Xử lý sai mật khẩu/email (Spam counter)
      failedAttempts++;
      if (failedAttempts >= 3) {
        _lockLogin();
      } else {
        errorMessage = "Sai email hoặc mật khẩu! (Sai $failedAttempts/3 lần)";
      }
    } catch (e) {
      errorMessage = "Lỗi kết nối server!";
    }

    isLoading = false;
    notifyListeners();
    return false;
  }

  // Khóa 30 giây
  void _lockLogin() {
    isLocked = true;
    errorMessage = "Khóa đăng nhập 30 giây do sai quá nhiều lần.";
    notifyListeners();
    Timer(const Duration(seconds: 30), () {
      isLocked = false;
      failedAttempts = 0;
      errorMessage = null;
      notifyListeners();
    });
  }

  // 2. HÀM ĐĂNG KÝ (Đã thêm Phone)
    Future<bool> register(String name, String phone, String email, String password) async {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      try {
        final cleanEmail = email.trim();
        final check = await http.get(Uri.parse('$baseUrl/users?email=$cleanEmail'));
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
            'phone': phone.trim(), // LƯU THÊM SỐ ĐIỆN THOẠI
            'email': cleanEmail,
            'password': password.trim(),
            'avatar': 'https://i.pravatar.cc/150?img=11', // Lấy avatar ngẫu nhiên cho đẹp
            'role': 'user',
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

// Cập nhật Avatar
  Future<bool> updateAvatar(String newAvatarPath) async {
    if (currentUser == null) return false;
    final userId = currentUser!['id'];

    try {
      final res = await http.patch(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'avatar': newAvatarPath}),
      );

      if (res.statusCode == 200) {
        currentUser!['avatar'] = newAvatarPath; // Cập nhật local
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_user', jsonEncode(currentUser));
        notifyListeners();
        return true;
      }
    } catch (e) {
      print("Lỗi update avatar: $e");
    }
    return false;
  }

  // Đăng xuất
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Xóa sạch dữ liệu phiên đăng nhập
    currentUser = null;
    notifyListeners();
  }
}