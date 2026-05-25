import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import 'admin_users_screen.dart';
import 'login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().loadDashboardData();
    });
  }

  // SỬA LỖI Ở ĐÂY: Đổi 'double amount' thành 'num amount' để nhận cả int lẫn double
  String _formatCurrency(num amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ';
  }

  String _translateStatus(String status) {
    switch (status) {
      case 'pending': return 'CHỜ DUYỆT';
      case 'shipping': return 'ĐANG GIAO';
      case 'delivered': return 'HOÀN THÀNH';
      default: return status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    const colorBackground = Colors.white;
    const colorTextPrimary = Colors.black;
    const colorTextSecondary = Colors.grey;
    final colorBorder = Colors.grey[300]!;

    return Scaffold(
      backgroundColor: colorBackground,
      appBar: AppBar(
        backgroundColor: colorBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: colorTextPrimary),
        title: const Text(
          'DASHBOARD',
          style: TextStyle(color: colorTextPrimary, fontWeight: FontWeight.w800, letterSpacing: 2.0, fontSize: 16),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: colorBorder, height: 1.0),
        ),
      ),
      drawer: Drawer(
        backgroundColor: colorBackground,
        child: Column(
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.black),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
              ),
              accountName: Text('ADMINISTRATOR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 12)),
              accountEmail: Text('admin@clothingshop.com', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ),
            _buildDrawerItem(Icons.people_outline, 'User Management', () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUsersScreen()));
            }),
            _buildDrawerItem(Icons.inventory_2_outlined, 'Products & Inventory', () {
              Navigator.pop(context);
            }),
            // ĐÃ THÊM LẠI MENU VOUCHER & PROMOTIONS
            _buildDrawerItem(Icons.card_giftcard_outlined, 'Vouchers & Promotions', () {
              Navigator.pop(context);
            }),
            _buildDrawerItem(Icons.receipt_long_outlined, 'Orders', () {
              Navigator.pop(context);
            }),
            const Spacer(),
            Divider(color: colorBorder, height: 1),
            _buildDrawerItem(Icons.logout, 'Log Out', () async {
              await Provider.of<AuthViewModel>(context, listen: false).logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
              }
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: Consumer<DashboardViewModel>(
        builder: (context, dashboardVM, child) {
          if (dashboardVM.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          }

          return RefreshIndicator(
            color: Colors.black,
            backgroundColor: Colors.white,
            onRefresh: () => dashboardVM.loadDashboardData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('OVERVIEW', style: TextStyle(color: colorTextSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(child: _buildStatCard('REVENUE', _formatCurrency(dashboardVM.totalRevenue), Icons.account_balance_wallet_outlined)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('ORDERS', dashboardVM.totalOrders.toString(), Icons.shopping_bag_outlined)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('CUSTOMERS', dashboardVM.totalCustomers.toString(), Icons.people_outline)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('PRODUCTS', dashboardVM.totalProducts.toString(), Icons.inventory_2_outlined)),
                    ],
                  ),
                  const SizedBox(height: 32),

                  const Text('WEEKLY TREND', style: TextStyle(color: colorTextSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(border: Border.all(color: colorBorder), borderRadius: BorderRadius.circular(4)),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total: ${_formatCurrency(dashboardVM.totalRevenue)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const Icon(Icons.trending_up, color: Colors.black, size: 18),
                          ],
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          height: 120,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildMonochromeBar('M', 0.4),
                              _buildMonochromeBar('T', 0.6),
                              _buildMonochromeBar('W', 0.3),
                              _buildMonochromeBar('T', 0.8),
                              _buildMonochromeBar('F', 0.5),
                              _buildMonochromeBar('S', 0.9),
                              _buildMonochromeBar('S', 0.7),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text('*Biểu đồ tuần mang tính minh họa tỷ lệ', style: TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic))
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('RECENT ORDERS', style: TextStyle(color: colorTextSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(foregroundColor: Colors.black),
                        child: const Text('View All', style: TextStyle(fontSize: 12, decoration: TextDecoration.underline)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (dashboardVM.recentOrders.isEmpty)
                    const Padding(padding: EdgeInsets.all(20), child: Text("No orders found.", style: TextStyle(color: Colors.grey)))
                  else
                    ...dashboardVM.recentOrders.map((order) => _buildRecentOrderTile(
                      order['customer_name'],
                      order['product_name'],
                      _formatCurrency(order['final_amount'] as num? ?? 0), // Ép kiểu an toàn ở đây
                      _translateStatus(order['status'] ?? ''),
                    )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.black, size: 20),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1.0, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMonochromeBar(String label, double heightPercentage) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 24,
          height: 100 * heightPercentage,
          decoration: const BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildRecentOrderTile(String name, String product, String price, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name.toUpperCase(), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
              const SizedBox(height: 4),
              Text(product, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(status, style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ),
            ],
          )
        ],
      ),
    );
  }
}