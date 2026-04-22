import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_management_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<UserManagementViewModel>(context, listen: false).loadUsers());
  }

  @override
  Widget build(BuildContext context) {
    final userVM = Provider.of<UserManagementViewModel>(context);
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final currentAdminId = authVM.currentUser?['id']?.toString();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        title: Text(
          'USER MANAGEMENT',
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w800, letterSpacing: 1.5, fontSize: 18),
        ),
        centerTitle: true,
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1.0), child: Container(color: Colors.grey[200], height: 1.0)),
      ),
      body: userVM.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: userVM.users.length,
              itemBuilder: (context, index) {
                final user = userVM.users[index];
                final isLocked = user['isLocked'] ?? false;
                final isMe = user['id'].toString() == currentAdminId; // Kiểm tra xem có phải chính mình không

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user['avatar'] ?? 'https://i.pravatar.cc/150'),
                  ),
                  title: Text(user['name'] ?? 'No Name', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user['email'] ?? ''),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: user['role'] == 'admin' ? Colors.blue[100] : Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              user['role']?.toUpperCase() ?? 'USER',
                              style: TextStyle(fontSize: 10, color: user['role'] == 'admin' ? Colors.blue[900] : Colors.black),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isLocked)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.red[100], borderRadius: BorderRadius.circular(4)),
                              child: Text('LOCKED', style: TextStyle(fontSize: 10, color: Colors.red[900])),
                            ),
                        ],
                      )
                    ],
                  ),
                  trailing: isMe
                    ? const Text("You", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
                    : PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          if (value == 'lock') userVM.toggleUserLock(user['id'].toString(), isLocked);
                          if (value == 'role') userVM.toggleUserRole(user['id'].toString(), user['role']);
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'role',
                            child: Text(user['role'] == 'admin' ? 'Hạ quyền xuống User' : 'Nâng cấp lên Admin'),
                          ),
                          PopupMenuItem(
                            value: 'lock',
                            child: Text(isLocked ? 'Mở khóa tài khoản' : 'Khóa tài khoản', style: TextStyle(color: isLocked ? Colors.green : Colors.red)),
                          ),
                        ],
                      ),
                );
              },
            ),
    );
  }
}