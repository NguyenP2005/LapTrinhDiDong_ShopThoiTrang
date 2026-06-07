import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import 'wishlist_screen.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'login_screen.dart';
import 'my_orders_screen.dart';
import 'settings_screen.dart';
import 'shipping_address_screen.dart';
import 'admin_users_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // ─────────────────────── XỬ LÝ ẢNH ĐẠI DIỆN ───────────────────────
  Future<void> _pickImage(BuildContext context, AuthViewModel authVM) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      bool success = await authVM.updateAvatar(pickedFile.path);
      if (context.mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật ảnh đại diện thành công!'),
            backgroundColor: Color(0xFF4361EE),
          ),
        );
      }
    }
  }

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

  // ─────────────────────── DIALOG CHỈNH SỬA THÔNG TIN ───────────────────────
  void _showEditProfileDialog(
    BuildContext context,
    AuthViewModel authVM,
    Map<String, dynamic>? user,
  ) {
    final nameController = TextEditingController(text: user?['name'] ?? '');
    final phoneController = TextEditingController(text: user?['phone'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Chỉnh sửa thôngত্তিn",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF4361EE),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Họ và tên",
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: Color(0xFF4361EE),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF4361EE),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Số điện thoại",
                  prefixIcon: const Icon(
                    Icons.phone_outlined,
                    color: Color(0xFF4361EE),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF4361EE),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy", style: TextStyle(color: Colors.black54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4361EE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                bool success = await authVM.updateUserProfile(
                  name: nameController.text,
                  phone: phoneController.text,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Cập nhật thông tin thành công!'
                            : 'Lỗi cập nhật!',
                      ),
                      backgroundColor: success
                          ? const Color(0xFF4361EE)
                          : Colors.red,
                    ),
                  );
                }
              },
              child: const Text(
                "Lưu thay đổi",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final user = authVM.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5), // Đồng bộ nền xám nhạt với Home
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF4361EE),
                Color(0xff4A00E0),
              ], // Đồng bộ Gradient Tím với Home
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          "Tài khoản",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // --- HEADER: THÔNG TIN USER ---
            _buildProfileCard(context, authVM, user),

            const SizedBox(height: 20),

            // --- ĐƠN HÀNG & ĐỊA CHỈ ---
            _buildMenuCard(
              children: [
                _buildMenuItem(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Đơn hàng của tôi',
                  onTap: () {
                    final userId = user?['id']?.toString() ?? "";
                    if (userId.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MyOrdersScreen(userId: userId),
                        ),
                      );
                    }
                  },
                ),
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.favorite_border_outlined,
                  title: 'Sản phẩm yêu thích',
                  onTap: () {
                    // ĐĐã vá lỗi chuyển trang ởđây nha!
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const WishlistScreen()),
                    );
                  },
                ),
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.location_on_outlined,
                  title: 'Địa chỉ giao hàng',
                  onTap: () {
                    final userId = user?['id']?.toString() ?? "";
                    if (userId.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ShippingAddressScreen(userId: userId),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- CÀI ĐẶT ---
            _buildMenuCard(
              children: [
                _buildMenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Cài đặt ứng dụng',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.help_outline,
                  title: 'Trung tâm hỗ trợ',
                  onTap: () {},
                ),
              ],
            ),

            // --- ADMIN (Chỉ hiện nếu là admin) ---
            if (user?['role'] == 'admin') ...[
              const SizedBox(height: 20),
              _buildMenuCard(
                children: [
                  _buildMenuItem(
                    icon: Icons.admin_panel_settings_outlined,
                    title: 'Quản lý người dùng',
                    iconColor: const Color(
                      0xffEE4D2D,
                    ), // Màu cam nổi bật cho Admin
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminUsersScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],

            const SizedBox(height: 30),

            // --- NÚT ĐĂNG XUẤT ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.redAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Colors.redAccent, width: 1),
                    ),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    "Đăng xuất",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    await authVM.logout();
                    if (!context.mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ─────────────────────── WIDGET UI ĐỒNG BỘ TRANG CHỦ ───────────────────────

  Widget _buildProfileCard(
    BuildContext context,
    AuthViewModel authVM,
    Map<String, dynamic>? user,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _pickImage(context, authVM),
            child: Stack(
              children: [
                Container(
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF4361EE),
                      width: 2,
                    ),
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
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Color(0xFF4361EE),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?['name'] ?? 'Khách',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?['email'] ?? 'Chưa cập nhật email',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                if (user?['phone'] != null &&
                    user!['phone'].toString().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    user['phone'],
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ],
            ),
          ),
          // Nút Edit mở Dialog
          IconButton(
            icon: const Icon(Icons.edit_square, color: Color(0xFF4361EE)),
            onPressed: () => _showEditProfileDialog(context, authVM, user),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF4361EE),
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.black54,
        size: 14,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[100],
      indent: 60,
      endIndent: 20,
    );
  }
}

