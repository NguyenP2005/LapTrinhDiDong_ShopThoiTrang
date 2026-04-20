import 'dart:io'; // Để dùng File load ảnh local
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../viewmodels/auth_viewmodel.dart';
import 'login_screen.dart';
import 'my_orders_screen.dart';
import 'settings_screen.dart';
import 'shipping_address_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Hàm chọn ảnh từ thư viện điện thoại
  Future<void> _pickImage(BuildContext context, AuthViewModel authVM) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      await authVM.updateAvatar(pickedFile.path); // Lưu đường dẫn ảnh local vào db
    }
  }

  // Hàm hiển thị Avatar (Hỗ trợ cả link web lẫn file local)
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
            letterSpacing: 1.5,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[200], height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- THÔNG TIN CÁ NHÂN ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                      image: DecorationImage(
                        image: _getAvatarProvider(user?['avatar']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?['name']?.toUpperCase() ?? 'GUEST',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 4),
                        Text(user?['email'] ?? '', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                        const SizedBox(height: 2),
                        if (user?['phone'] != null) Text(user!['phone'], style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  // Nút Đổi Avatar
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.grey),
                    onPressed: () => _pickImage(context, authVM),
                  )
                ],
              ),
            ),

            Divider(thickness: 8, color: isDark ? Colors.grey[900] : Colors.grey[100]),

            // --- MENU ---
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

            Divider(thickness: 8, color: isDark ? Colors.grey[900] : Colors.grey[100]),

            _buildSectionTitle('SETTINGS'),
            _buildMenuItem(context, Icons.settings_outlined, 'App Settings', onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            }),
            _buildMenuItem(context, Icons.help_outline, 'Help & Support', onTap: () {}),

            Divider(thickness: 1, color: isDark ? Colors.grey[800] : Colors.grey[200]),

            // --- ĐĂNG XUẤT ---
            InkWell(
              onTap: () async {
                await authVM.logout();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Color(0xFFD32F2F)),
                    SizedBox(width: 16),
                    Text('Log Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFD32F2F))),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 24, bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, {required VoidCallback onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Icon(icon, color: Theme.of(context).iconTheme.color),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}