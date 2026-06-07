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
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartViewModel>(context, listen: false).loadCart();
    });
  }

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
}
