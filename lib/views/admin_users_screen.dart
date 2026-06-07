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
    const colorBackground = Color(0xFFF4F7FC);
    const colorPrimary = Color(0xFF4361EE);
    const colorTextPrimary = Color(0xFF2B2B2B);
    const colorTextSecondary = Colors.grey;

    return Scaffold(
      backgroundColor: colorBackground,
      appBar: AppBar(
        backgroundColor: colorBackground,
        elevation: 0,
        scrolledUnderElevation: 0, 
        iconTheme: const IconThemeData(color: colorTextPrimary),
        title: const Text(
          'USER MANAGEMENT',
          style: TextStyle(
            color: colorTextPrimary,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<UserManagementViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: colorPrimary),
            );
          }

          if (viewModel.users.isEmpty) {
            return const Center(child: Text("No users found.", style: TextStyle(color: colorTextSecondary)));
          }

          return RefreshIndicator(
            color: colorPrimary,
            backgroundColor: Colors.white,
            onRefresh: () => viewModel.loadUsers(),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: viewModel.users.length,
              itemBuilder: (context, index) {
                final UserModel user = viewModel.users[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: colorPrimary.withOpacity(0.2), width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.grey[100],
                          backgroundImage: NetworkImage(user.avatar),
                        ),
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
                                color: colorTextPrimary,
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
                            // Badge trạng thái
                            Row(
                              children: [
                                _buildTag(user.role.toUpperCase(), isPrimary: user.role == 'admin'),
                                const SizedBox(width: 8),
                                if (user.isLocked) _buildLockTag(),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Action menu (Dấu 3 chấm)
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_horiz, color: colorTextSecondary),
                        color: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), 
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
                            child: Row(
                              children: [
                                Icon(Icons.admin_panel_settings_outlined, color: user.role == 'admin' ? Colors.orange : colorPrimary, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  user.role == 'admin' ? 'Change to Customer' : 'Make Admin',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'lock',
                            child: Row(
                              children: [
                                Icon(user.isLocked ? Icons.lock_open : Icons.lock_outline, color: user.isLocked ? Colors.green : Colors.red, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  user.isLocked ? 'Unlock Account' : 'Lock Account',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: user.isLocked ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
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

  Widget _buildTag(String text, {required bool isPrimary}) {
    final colorPrimary = const Color(0xFF4361EE);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPrimary ? colorPrimary.withOpacity(0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isPrimary ? colorPrimary : Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildLockTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'LOCKED',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.red,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}