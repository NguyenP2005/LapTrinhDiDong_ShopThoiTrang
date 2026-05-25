import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_management_viewmodel.dart';
import '../models/user_model.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  @override
  void initState() {
    super.initState();
    // Khởi tạo data ngay khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserManagementViewModel>().loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tone màu Minimalist chủ đạo
    const colorBackground = Colors.white;
    const colorTextPrimary = Colors.black;
    const colorTextSecondary = Colors.grey;
    final colorDivider = Colors.grey[200];

    return Scaffold(
      backgroundColor: colorBackground,
      appBar: AppBar(
        backgroundColor: colorBackground,
        elevation: 0,
        scrolledUnderElevation: 0, // Tránh đổi màu khi cuộn trên Android 13+
        iconTheme: const IconThemeData(color: colorTextPrimary),
        title: const Text(
          'USERS',
          style: TextStyle(
            color: colorTextPrimary,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0, // Tăng khoảng cách chữ cho cảm giác sang trọng
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: colorDivider, height: 1.0),
        ),
      ),
      body: Consumer<UserManagementViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: colorTextPrimary),
            );
          }

          if (viewModel.users.isEmpty) {
            return const Center(child: Text("No users found."));
          }

          return RefreshIndicator(
            color: colorTextPrimary,
            backgroundColor: colorBackground,
            onRefresh: () => viewModel.loadUsers(),
            child: ListView.separated(
              itemCount: viewModel.users.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                thickness: 1,
                color: colorDivider,
                indent: 16, // Thụt lề một chút cho đẹp
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                final UserModel user = viewModel.users[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.grey[100],
                        backgroundImage: NetworkImage(user.avatar),
                      ),
                      const SizedBox(width: 16),

                      // Thông tin
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              style: const TextStyle(
                                color: colorTextSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Badge trạng thái Minimalist
                            Row(
                              children: [
                                _buildTag(user.role.toUpperCase(), isPrimary: user.role == 'admin'),
                                const SizedBox(width: 8),
                                if (user.isLocked) _buildTag('LOCKED', isPrimary: false),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Action menu (Dấu 3 chấm)
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_horiz, color: colorTextPrimary),
                        color: colorBackground,
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)), // Bỏ bo góc
                        onSelected: (value) {
                          if (value == 'role') {
                            viewModel.toggleUserRole(user.id, user.role);
                          } else if (value == 'lock') {
                            viewModel.toggleUserLock(user.id, user.isLocked);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'role',
                            child: Text(
                              user.role == 'admin' ? 'Change to Customer' : 'Make Admin',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'lock',
                            child: Text(
                              user.isLocked ? 'Unlock Account' : 'Lock Account',
                              style: TextStyle(
                                fontSize: 13,
                                color: user.isLocked ? colorTextPrimary : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Widget vẽ Tag chức vụ/trạng thái (Border mỏng, nền trong suốt)
  Widget _buildTag(String text, {required bool isPrimary}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: isPrimary ? Colors.black : Colors.grey[300]!),
        borderRadius: BorderRadius.circular(2), // Bo góc rất nhẹ
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
          color: isPrimary ? Colors.black : Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}