import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsViewModel extends ChangeNotifier {
  bool isDarkMode = false;
  bool isUSD = false;

  SettingsViewModel() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode = prefs.getBool('is_dark_mode') ?? false;
    isUSD = prefs.getBool('is_usd') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme(bool value) async {
    isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', value);
    notifyListeners();
  }

  Future<void> toggleCurrency(bool value) async {
    isUSD = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_usd', value);
    notifyListeners();
  }
}