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
  final TextEditingController _searchController = TextEditingController();
  String _selectedTab = 'all'; // Trạng thái tab hiển thị nội bộ trên UI

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserManagementViewModel>().loadUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Định nghĩa bảng màu Minimalist nguyên bản
    const colorBackground = Color(0xffF9F9F9); // Nền xám trắng siêu sang của các website luxury
    const colorContent = Colors.white;
    const colorMainBlack = Color(0xFF111111);
    const colorSubGrey = Color(0xFF757575);

    final viewModel = context.watch<UserManagementViewModel>();

    return Scaffold(
      backgroundColor: colorBackground,
      appBar: AppBar(
        backgroundColor: colorContent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey[200], height: 1), // Đường gạch chân mảnh tinh tế
        ),
        iconTheme: const IconThemeData(color: colorMainBlack),
        title: const Text(
          'QUẢN LÝ NGƯỜI DÙNG',
          style: TextStyle(
            color: colorMainBlack,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontSize: 15,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- 1. THANH THỐNG KÊ TỐI GIẢN (HEADER STATS) ---
          Container(
            color: colorContent,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem("TỔNG SỐ", viewModel.totalCount.toString(), colorMainBlack),
                _buildStatDivider(),
                _buildStatItem("QUẢN TRỊ", viewModel.adminCount.toString(), colorMainBlack),
                _buildStatDivider(),
                _buildStatItem("BỊ KHÓA", viewModel.lockedCount.toString(), Colors.redAccent),
              ],
            ),
          ),

          // --- 2. THANH TÌM KIẾM SẮC NÉT ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => viewModel.searchUsers(value),
              cursorColor: colorMainBlack,
              style: const TextStyle(fontSize: 14, color: colorMainBlack),
              decoration: InputDecoration(
                hintText: "Tìm kiếm tên hoặc email...",
                hintStyle: const TextStyle(color: colorSubGrey, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: colorMainBlack, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: colorSubGrey, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          viewModel.searchUsers('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: colorContent,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: colorMainBlack, width: 1),
                ),
              ),
            ),
          ),

          // --- 3. BỘ LỌC PHÂN LOẠI TAB (FILTER CHIPS) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildFilterChip("Tất cả", 'all', viewModel),
                const SizedBox(width: 8),
                _buildFilterChip("Quản trị", 'admin', viewModel),
                const SizedBox(width: 8),
                _buildFilterChip("Đang khóa", 'locked', viewModel),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // --- 4. DANH SÁCH NGƯỜI DÙNG ---
          Expanded(
            child: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator(color: colorMainBlack))
                : viewModel.users.isEmpty
                    ? const Center(
                        child: Text(
                          "Không tìm thấy người dùng phù hợp.",
                          style: TextStyle(color: colorSubGrey, fontSize: 13),
                        ),
                      )
                    : RefreshIndicator(
                        color: colorMainBlack,
                        backgroundColor: colorContent,
                        onRefresh: () => viewModel.loadUsers(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: viewModel.users.length,
                          itemBuilder: (context, index) {
                            final UserModel user = viewModel.users[index];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colorContent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!, width: 1),
                              ),
                              child: Row(
                                children: [
                                  // Avatar phẳng tinh tế
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.grey[300]!, width: 1),
                                    ),
                                    child: CircleAvatar(
                                      radius: 24,
                                      backgroundColor: Colors.grey[100],
                                      backgroundImage: NetworkImage(user.avatar),
                                      onBackgroundImageError: (_, __) => const Icon(Icons.person, color: colorSubGrey),
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Nội dung chữ phẳng và rõ nét
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.name.toUpperCase(),
                                          style: const TextStyle(
                                            color: colorMainBlack,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          user.email,
                                          style: const TextStyle(color: colorSubGrey, fontSize: 12),
                                        ),
                                        const SizedBox(height: 8),
                                        // Các nhãn phân loại (Tags)
                                        Row(
                                          children: [
                                            _buildMinimalTag(
                                              user.role.toUpperCase(),
                                              isDark: user.role == 'admin',
                                            ),
                                            if (user.isLocked) ...[
                                              const SizedBox(width: 6),
                                              _buildMinimalLockTag(),
                                            ]
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Menu thao tác nhanh
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_horiz, color: colorSubGrey),
                                    color: colorContent,
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                                            const Icon(Icons.admin_panel_settings_outlined, color: colorMainBlack, size: 18),
                                            const SizedBox(width: 8),
                                            Text(
                                              user.role == 'admin' ? 'Chuyển thành Khách hàng' : 'Cấp quyền Quản trị',
                                              style: const TextStyle(fontSize: 13, color: colorMainBlack),
                                            ),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'lock',
                                        child: Row(
                                          children: [
                                            Icon(
                                              user.isLocked ? Icons.lock_open : Icons.lock_outline,
                                              color: user.isLocked ? Colors.green : Colors.red,
                                              size: 18
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              user.isLocked ? 'Mở khóa tài khoản' : 'Khóa tài khoản',
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
                      ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────── COMPONENT UI TỐI GIẢN ───────────────────────

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF9E9E9E), letterSpacing: 1.0),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: valueColor),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 24, color: Colors.grey[200]);
  }

  Widget _buildFilterChip(String title, String tabValue, UserManagementViewModel vm) {
    final isSelected = _selectedTab == tabValue;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedTab = tabValue);
        vm.changeFilterTab(tabValue);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF111111) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF111111) : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : const Color(0xFF555555),
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalTag(String text, {required bool isDark}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111111) : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : const Color(0xFF555555),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMinimalLockTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'ĐÃ KHÓA',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: Colors.red,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}