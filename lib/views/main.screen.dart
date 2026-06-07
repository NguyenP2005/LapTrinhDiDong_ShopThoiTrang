import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import ViewModels
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../viewmodels/order_viewmodel.dart';

// Import Screens
import 'home_screen.dart';
import 'products_list_screen.dart';
import 'cart_screen.dart';
import 'my_orders_screen.dart';
import 'store_locator_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  void changeTab(int index) {
    setState(() {
      currentIndex = index;
    });

    // Nếu bấm vào tab Giỏ hàng (index 2), bắt load lại Giỏ hàng
    if (index == 2) {
      Provider.of<CartViewModel>(context, listen: false).loadCart();
    }
    // Nếu bấm vào tab Đơn hàng (index 3), bắt load lại Đơn hàng
    else if (index == 3) {
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      final userId = authVM.currentUser?['id']?.toString() ?? "";

      if (userId.isNotEmpty) {
        Provider.of<OrderViewModel>(
          context,
          listen: false,
        ).loadUserOrders(userId);
      }
    }
    // ========================
  }

  @override
  Widget build(BuildContext context) {
    // 1. Lấy thông tin user đang đăng nhập
    final authVM = Provider.of<AuthViewModel>(context);
    final userId = authVM.currentUser?['id']?.toString() ?? "";

    // 2. Danh sách 5 màn hình
    // Danh sách 5 màn hình tương ứng với 5 nút
    final screens = [
      HomeScreen(onTabChange: changeTab), // Index 0
      const ProductListScreen(), // Index 1
      CartScreen(onTabChange: changeTab), // Index 2
      MyOrdersScreen(userId: userId), // Index 3
      const ProfileScreen(),
    ];

    // WillPopScope dùng để điều khiển nút Back vật lý của điện thoại
    return WillPopScope(
      onWillPop: () async {
        // Nếu không phải đang ở tab Home (index 0), thì nhảy về Home
        if (currentIndex != 0) {
          changeTab(0);
          return false; // Không thoát app
        }
        return true; // Nếu đang ở Home mà bấm Back thì cho phép thoát App
      },
      child: Scaffold(
        // SỬA Ở ĐÂY: Dùng IndexedStack để giữ nguyên dữ liệu của các tab khi lướt qua lại
        body: IndexedStack(index: currentIndex, children: screens),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: changeTab,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xff8E2DE2),
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: "Trang chủ",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view),
              label: "Sản phẩm",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart),
              label: "Giỏ hàng",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: "Đơn hàng",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: "Tài khoản",
            ),
          ],
        ),
      ),
    );
  }

  // Màn hình tài khoản đơn giản: thông tin user + lối vào bản đồ cửa hàng + đăng xuất
  Widget _buildAccountScreen(AuthViewModel authVM) {
    final user = authVM.currentUser;
    final name = user?['name']?.toString() ?? 'Khách';
    final email = user?['email']?.toString() ?? '';
    final avatar = user?['avatar']?.toString() ?? 'https://i.pravatar.cc/150';

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Tài khoản',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff8E2DE2),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Thẻ thông tin user
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff8E2DE2), Color(0xff4A00E0)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: NetworkImage(avatar),
                  backgroundColor: Colors.white24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Mục: Cửa hàng gần bạn
          _buildMenuTile(
            icon: Icons.location_on_outlined,
            title: 'Cửa hàng gần bạn',
            subtitle: 'Xem hệ thống cửa hàng trên bản đồ',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StoreLocatorScreen()),
              );
            },
          ),

          // Mục: Đơn hàng của tôi
          _buildMenuTile(
            icon: Icons.receipt_long_outlined,
            title: 'Đơn hàng của tôi',
            subtitle: 'Theo dõi đơn hàng đã đặt',
            onTap: () => changeTab(3),
          ),

          const SizedBox(height: 24),

          // Nút đăng xuất
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () => _confirmLogout(authVM),
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Đăng xuất',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xff8E2DE2).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xff8E2DE2)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  void _confirmLogout(AuthViewModel authVM) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              authVM.currentUser = null;
              Navigator.pop(context); // đóng dialog
              // Quay về màn đăng nhập, xóa hết stack
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
