import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../viewmodels/auth_viewmodel.dart';
import 'login_screen.dart';
import 'my_orders_screen.dart';
import 'settings_screen.dart';
import 'shipping_address_screen.dart';
import 'admin_users_screen.dart'; // Import đúng file màn hình mới

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Hàm xử lý chọn ảnh từ thư viện
  Future<void> _pickImage(BuildContext context, AuthViewModel authVM) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      bool success = await authVM.updateAvatar(pickedFile.path);
      if (context.mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật ảnh đại diện thành công!')),
        );
      }
    }
  }

  // Hàm xử lý hiển thị ảnh (từ URL hoặc từ file máy)
  ImageProvider _getAvatarProvider(String? avatarPath) {
    if (avatarPath == null || avatarPath.isEmpty) {
      return const NetworkImage('https://i.pravatar.cc/150');
    }
    if (avatarPath.startsWith('http')) {
      return NetworkImage(avatarPath);
    } else {
      return FileImage(File(avatarPath));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final user = authVM.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        title: Text(
          'PROFILE',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0, // Tăng nhẹ khoảng cách chữ cho sang trọng
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: isDark ? Colors.grey[850] : Colors.grey[200], height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- THÔNG TIN TÀI KHOẢN ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  // Khu vực Avatar
                  GestureDetector(
                    onTap: () => _pickImage(context, authVM),
                    child: Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey[300]!, width: 1),
                            image: DecorationImage(
                              image: _getAvatarProvider(user?['avatar']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Thông tin Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?['name']?.toUpperCase() ?? 'GUEST',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?['email'] ?? '',
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                        if (user?['phone'] != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            user!['phone'],
                            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Divider(thickness: 8, color: isDark ? Colors.grey[900] : Colors.grey[50]),

            // --- NGHIỆP VỤ MUA SẮM ---
            _buildSectionTitle('SHOPPING'),
            _buildMenuItem(context, Icons.shopping_bag_outlined, 'My Orders', onTap: () {
              final userId = user?['id']?.toString() ?? "";
              if (userId.isNotEmpty) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => MyOrdersScreen(userId: userId)));
              }
            }),
            _buildMenuItem(context, Icons.favorite_border_outlined, 'Wishlist', onTap: () {}),
            _buildMenuItem(context, Icons.location_on_outlined, 'Shipping Addresses', onTap: () {
              final userId = user?['id']?.toString() ?? "";
              if (userId.isNotEmpty) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ShippingAddressScreen(userId: userId)));
              }
            }),

            Divider(thickness: 8, color: isDark ? Colors.grey[900] : Colors.grey[50]),

            // --- CÀI ĐẶT ỨNG DỤNG ---
            _buildSectionTitle('SETTINGS'),
            _buildMenuItem(context, Icons.settings_outlined, 'App Settings', onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            }),
            _buildMenuItem(context, Icons.help_outline, 'Help & Support', onTap: () {}),

            // --- QUẢN TRỊ VIÊN (Chỉ hiện khi tài khoản là Admin) ---
            if (user?['role'] == 'admin') ...[
              Divider(thickness: 8, color: isDark ? Colors.grey[900] : Colors.grey[50]),
              _buildSectionTitle('ADMINISTRATION'),
              _buildMenuItem(
                context,
                Icons.people_outline,
                'User Management',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminUsersScreen())
                  );
                }
              ),
            ],

            Divider(thickness: 8, color: isDark ? Colors.grey[900] : Colors.grey[50]),

            // --- ĐĂNG XUẤT ---
            InkWell(
              onTap: () async {
                await authVM.logout();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Row(
                  children: [
                    const Icon(Icons.logout, color: Colors.black87), // Chuyển nút đỏ sang đen cho đúng concept Minimalist
                    const SizedBox(width: 16),
                    Text(
                      'Log Out',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Widget phụ trợ tạo tiêu đề mục
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 24, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5),
      ),
    );
  }

  // Widget phụ trợ tạo các dòng menu
  Widget _buildMenuItem(BuildContext context, IconData icon, String title, {required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      leading: Icon(icon, color: isDark ? Colors.white70 : Colors.black87, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }
}