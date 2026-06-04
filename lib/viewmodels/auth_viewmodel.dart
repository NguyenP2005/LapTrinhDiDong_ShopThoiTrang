import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class AuthViewModel extends ChangeNotifier {
  static const String baseUrl = "http://10.0.2.2:3000";
  bool isLoading = false;
  String? errorMessage;
  Map<String, dynamic>? currentUser;

  // Hỗ trợ lấy nhanh role của user hiện tại
  String? get userRole => currentUser?['role'];

  // Biến phục vụ tính năng chống Spam đăng nhập
  int failedAttempts = 0;
  bool isLocked = false;

  // Biến phục vụ luồng Quên mật khẩu (Lưu tạm ID user cần reset)
  String? resetUserId;

  // OTP ngẫu nhiên được tạo mỗi lần gửi yêu cầu reset
  String? _generatedOtp;

  /// Trả về mã OTP đã tạo (dùng cho UI hiển thị mô phỏng SMS)
  String? get generatedOtp => _generatedOtp;

  // 1. Kiểm tra xem user đã đăng nhập từ trước chưa (Auto Login)
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('current_user');
    if (userStr != null) {
      currentUser = jsonDecode(userStr);
      notifyListeners();
    }
  }

  // 2. Logic Đăng nhập (Có kèm bộ đếm chống Spam & Check khóa tài khoản)
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
          // Kiểm tra xem tài khoản có bị Admin khóa không
          if (user['isLocked'] == true) {
            errorMessage = "Tài khoản của bạn đã bị khóa bởi Admin!";
            isLoading = false;
            notifyListeners();
            return false;
          }

          currentUser = user;
          failedAttempts = 0; // Reset số lần sai nếu đăng nhập đúng

          // Lưu thông tin vào bộ nhớ thiết bị để lần sau Auto Login
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('current_user', jsonEncode(user));
          await prefs.setBool('is_logged_in', true);

          isLoading = false;
          notifyListeners();
          return true; // Đăng nhập thành công
        }
      }

      // Xử lý khi sai mật khẩu hoặc sai email
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

  // Hàm khóa đăng nhập tạm thời 30 giây khi spam sai 3 lần
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

  // 3. Logic Đăng ký tài khoản mới (Mặc định quyền là customer)
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
          'phone': phone.trim(),
          'email': cleanEmail,
          'password': password.trim(),
          'avatar': 'https://i.pravatar.cc/150?img=11',
          'role': 'customer', // Mặc định người mới là khách hàng
          'isLocked': false,  // Mặc định không bị khóa
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

  // 4. Cập nhật ảnh đại diện (Avatar) cho User
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
        currentUser!['avatar'] = newAvatarPath; // Cập nhật trạng thái local hiện tại
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_user', jsonEncode(currentUser));
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("Lỗi update avatar: $e");
    }
    return false;
  }

  // 5. Đăng xuất tài khoản
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Xóa sạch dữ liệu phiên làm việc trên thiết bị
    currentUser = null;
    notifyListeners();
  }

  // ==========================================================================
  // LOGIC FORGOT PASSWORD (QUÊN MẬT KHẨU)
  // ==========================================================================

  // Bước A: Kiểm tra Email có tồn tại trong db.json để cấp quyền reset không
  Future<bool> checkEmailForReset(String email) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final cleanEmail = email.trim();
      final res = await http.get(Uri.parse('$baseUrl/users?email=$cleanEmail'));
      final data = jsonDecode(res.body) as List;

      if (data.isNotEmpty) {
        resetUserId = data[0]['id'].toString(); // Ghi nhớ ID user phục vụ cho Bước C

        // Tạo mã OTP ngẫu nhiên 6 số
        _generatedOtp = (100000 + Random().nextInt(900000)).toString();

        isLoading = false;
        notifyListeners();
        return true;
      } else {
        errorMessage = "Email không tồn tại trên hệ thống!";
      }
    } catch (e) {
      errorMessage = "Lỗi kết nối server!";
    }

    isLoading = false;
    notifyListeners();
    return false;
  }

  // Bước B: Xác thực mã OTP (So sánh với mã ngẫu nhiên đã tạo, không hardcode)
  bool verifyOTP(String otp) {
    if (_generatedOtp != null && otp.trim() == _generatedOtp) {
      errorMessage = null;
      notifyListeners();
      return true;
    }
    errorMessage = "Mã OTP không chính xác! Vui lòng kiểm tra tin nhắn SMS.";
    notifyListeners();
    return false;
  }

  // Bước C: Gọi API PATCH cập nhật mật khẩu mới đè lên tài khoản dựa trên resetUserId
  Future<bool> resetPassword(String newPassword) async {
    if (resetUserId == null) return false;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final res = await http.patch(
        Uri.parse('$baseUrl/users/$resetUserId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'password': newPassword.trim()}),
      );

      if (res.statusCode == 200) {
        resetUserId = null; // Đổi thành công thì xóa ID lưu tạm
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        errorMessage = "Lỗi khi cập nhật mật khẩu mới!";
      }
    } catch (e) {
      errorMessage = "Lỗi kết nối server!";
    }

    isLoading = false;
    notifyListeners();
    return false;
  }
}