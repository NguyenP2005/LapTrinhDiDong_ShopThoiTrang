import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'views/main.screen.dart';
import 'views/login_screen.dart';
import 'views/admin_dashboard_screen.dart';
import 'dart:convert';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/cart_viewmodel.dart';
import 'viewmodels/address_viewmodel.dart';
import 'viewmodels/order_viewmodel.dart';
import 'viewmodels/payment_viewmodel.dart';
import 'viewmodels/coupon_viewmodel.dart';
import 'viewmodels/store_viewmodel.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'viewmodels/user_management_viewmodel.dart';
import 'viewmodels/dashboard_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;
  bool isAdmin = false;

  if (isLoggedIn) {
    final userStr = prefs.getString('current_user');
    if (userStr != null) {
      try {
        final user = jsonDecode(userStr);
        if (user['role'] == 'admin') {
          isAdmin = true;
        }
      } catch (e) {
        // Handle json parse error
      }
    }
  }

  runApp(MyApp(isLoggedIn: isLoggedIn, isAdmin: isAdmin));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final bool isAdmin;
  const MyApp({super.key, required this.isLoggedIn, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsViewModel(),
        ), // THÊM DÒNG NÀY
        ChangeNotifierProvider(
          create: (_) => AuthViewModel()..checkLoginStatus(),
        ),
        ChangeNotifierProvider(create: (_) => CartViewModel()..loadCart()),
        ChangeNotifierProvider(create: (_) => AddressViewModel()),
        ChangeNotifierProvider(create: (_) => OrderViewModel()),
        ChangeNotifierProvider(create: (_) => PaymentViewModel()),
        ChangeNotifierProvider(create: (_) => CouponViewModel()),
        ChangeNotifierProvider(create: (_) => StoreViewModel()),
        ChangeNotifierProvider(create: (_) => UserManagementViewModel()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
      ],
      // Dùng Consumer để lắng nghe thay đổi Dark Mode
      child: Consumer<SettingsViewModel>(
        builder: (context, settingsVM, child) {
          return MaterialApp(
            title: 'Flutter Clothing App',
            debugShowCheckedModeBanner: false,
            themeMode: settingsVM.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              brightness: Brightness.light,
              primaryColor: const Color(0xFF2344D1),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primaryColor: const Color(0xFF2344D1),
              useMaterial3: true,
            ),
            home: isLoggedIn
                ? (isAdmin ? const AdminDashboardScreen() : const MainScreen())
                : const LoginScreen(),
          );
        },
      ),
    );
  }
}
