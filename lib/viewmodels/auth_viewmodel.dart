import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthViewModel extends ChangeNotifier {
  static const String baseUrl = "http://10.0.2.2:3000";
  bool isLoading = false;
  String? errorMessage;

  Future<bool> login(String email, String password) async {
    isLoading = true; notifyListeners();
    final res = await http.get(Uri.parse('$baseUrl/users?email=$email&password=$password'));
    isLoading = false; notifyListeners();
    final data = jsonDecode(res.body);
    if (data.length > 0) return true;
    errorMessage = "Sai email hoặc mật khẩu!"; notifyListeners();
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    isLoading = true; notifyListeners();
    final check = await http.get(Uri.parse('$baseUrl/users?email=$email'));
    final existing = jsonDecode(check.body);
    if (existing.length > 0) {
      errorMessage = "Email đã tồn tại!"; isLoading = false; notifyListeners(); return false;
    }
    final res = await http.post(Uri.parse('$baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}));
    isLoading = false; notifyListeners();
    return res.statusCode == 201;
  }
}