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

  // Biến phục vụ tính năng chống Spamđăng nhập
  int failedAttempts = 0;
  bool isLocked = false;

  // Biến phục vụ luồng Quên mật khẩu (Lưu tạm ID user cần reset)
  String? resetUserId;

  // OTP ngẫu nhiênđược tạo mỗi lần gửi yêu cầu reset
  String? _generatedOtp;

  /// Trả về mã OTPđã tạo (dùng cho UI hiển thị mô phỏng SMS)
  String? get generatedOtp => _generatedOtp;

  // 1. Kiểm tra xem userđãđăng nhập từ trước chưa (Auto Login)
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('current_user');
    if (userStr != null) {
      currentUser = jsonDecode(userStr);
      notifyListeners();
    }
  }

  // 2. Logic Đăng nhập (Có kèm bộđếm chống Spam & Check khóa tài khoản)
  Future<bool> login(String email, String password) async {
    if (isLocked) {
      errorMessage = "Nhập sai quá nhiều. Vui lòngđợi 30 giây!";
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final cleanEmail = email.trim();
      final cleanPassword = password.trim();

      final res = await http
          .get(Uri.parse('$baseUrl/users?email=$cleanEmail'))
          .timeout(const Duration(seconds: 10));
      final data = jsonDecode(res.body) as List;

      if (data.isNotEmpty) {
        final user = data[0];
        if (user['password'].toString() == cleanPassword) {
          // Kiểm tra xem tài khoản có bị Admin khóa không
          if (user['isLocked'] == true) {
            errorMessage = "Tài khoản của bạnđã bị khóa bởi Admin!";
            isLoading = false;
            notifyListeners();
            return false;
          }

          currentUser = user;
          failedAttempts = 0; // Reset số lần sai nếuđăng nhậpđúng

          // Lưu thông tin vào bộ nhớ thiết bịđể lần sau Auto Login
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
    } on TimeoutException {
      errorMessage = "Kết nối quá thời gian! Server chưa chạy hoặc mạng yếu.";
    } catch (e) {
      errorMessage = "Lỗi kết nối server! Hãy chắc chắn json-serverđang chạy.";
    }

    isLoading = false;
    notifyListeners();
    return false;
  }

  // Hàm khóađăng nhập tạm thời 30 giây khi spam sai 3 lần
  void _lockLogin() {
    isLocked = true;
    errorMessage = "Khóađăng nhập 30 giây do sai quá nhiều lần.";
    notifyListeners();
    Timer(const Duration(seconds: 30), () {
      isLocked = false;
      failedAttempts = 0;
      errorMessage = null;
      notifyListeners();
    });
  }

  // 3. Logic Đăng ký tài khoản mới (Mặcđịnh quyền là customer)
  Future<bool> register(String name, String phone, String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final cleanEmail = email.trim();
      final check = await http.get(Uri.parse('$baseUrl/users?email=$cleanEmail'));
      final existing = jsonDecode(check.body) as List;

      if (existing.isNotEmpty) {
        errorMessage = "Emailđã tồn tại!";
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
          'role': 'customer', // Mặcđịnh người mới là khách hàng
          'isLocked': false,  // Mặcđịnh không bị khóa
        }),
      );

      if (res.statusCode == 201) {
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        errorMessage = "Lỗi khiđăng ký!";
      }
    } catch (e) {
      errorMessage = "Lỗi kết nối server!";
    }

    isLoading = false;
    notifyListeners();
    return false;
  }

  // 4. Cập nhật ảnhđại diện (Avatar) cho User
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

  // Hàm mới: Cập nhật thông tin profile (Tên, SĐT)
  Future<bool> updateUserProfile({required String name, required String phone}) async {
    if (currentUser == null) return false;

    try {
      final userId = currentUser!['id'];
      final response = await http.patch(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'phone': phone,
        }),
      );

      if (response.statusCode == 200) {
        // Cập nhật lại dữ liệuđang hiển thị và lưu xuống local
        currentUser!['name'] = name;
        currentUser!['phone'] = phone;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_user', jsonEncode(currentUser));
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Lỗi cập nhật profile: $e");
      return false;
    }
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

  // Bước A: Kiểm tra Email có tồn tại trong db.jsonđể cấp quyền reset không
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

  // Bước B: Xác thực mã OTP (So sánh với mã ngẫu nhiênđã tạo, không hardcode)
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

  // Bước C: Gọi API PATCH cập nhật mật khẩu mớiđè lên tài khoản dựa trên resetUserId
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