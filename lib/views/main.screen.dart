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

    if (index == 2) {
      Provider.of<CartViewModel>(context, listen: false).loadCart();
    } else if (index == 3) {
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      final userId = authVM.currentUser?['id']?.toString() ?? "";
      if (userId.isNotEmpty) {
        Provider.of<OrderViewModel>(context, listen: false).loadUserOrders(userId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final userId = authVM.currentUser?['id']?.toString() ?? "";

    final screens = [
      HomeScreen(onTabChange: changeTab),
      const ProductListScreen(),
      CartScreen(onTabChange: changeTab),
      MyOrdersScreen(userId: userId),
      const ProfileScreen(),
    ];

    return PopScope(
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) changeTab(0);
      },
      child: Scaffold(
        body: IndexedStack(index: currentIndex, children: screens),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: changeTab,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF4361EE),
          unselectedItemColor: Colors.black54,
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
