import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../viewmodels/admin_product_viewmodel.dart';
import 'admin_users_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_products_screen.dart';
import 'login_screen.dart';
import 'admin_coupons_screen.dart';
import '../viewmodels/admin_coupon_viewmodel.dart';

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

  String _formatCurrency(num amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.').replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VND';
  }

  String _translateStatus(String status) {
    switch (status) {
      case 'pending': return 'CHỜ DUYỆT';
      case 'shipping': return 'ĐANG GIAO';
      case 'delivered': return 'HOÀN THÀNH';
      case 'cancelled': return 'ĐÃ HỦY';
      default: return status.toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'shipping': return Colors.blue;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    const colorBackground = Color(0xFFF4F7FC);
    const colorPrimary = Color(0xFF4361EE);
    const colorTextPrimary = Color(0xFF2B2B2B);
    const colorTextSecondary = Color(0xFF6B7280);

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
      ),
      drawer: Drawer(
        backgroundColor: colorBackground,
        child: Column(
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: colorPrimary),
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (_) => AdminProductViewModel(),
                    child: const AdminProductsScreen(),
                  ),
                ),
              );
            }),
            _buildDrawerItem(Icons.card_giftcard_outlined, 'Mã khuyến mãi', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: context.read<AdminCouponViewModel>(),
                    child: const AdminCouponsScreen(),
                  ),
                ),
              );
            }),
            _buildDrawerItem(Icons.receipt_long_outlined, 'Orders', () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminOrdersScreen()));
            }),
            const Spacer(),
            Divider(color: Colors.grey[300], height: 1),
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
            return const Center(child: CircularProgressIndicator(color: colorPrimary));
          }

          return RefreshIndicator(
            color: colorPrimary,
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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('REVENUE TREND', style: TextStyle(color: colorTextSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: DropdownButton<FilterPeriod>(
                          value: dashboardVM.currentFilter,
                          icon: const Icon(Icons.arrow_drop_down, color: colorTextPrimary),
                          underline: const SizedBox(),
                          style: const TextStyle(color: colorTextPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                          onChanged: (FilterPeriod? newValue) {
                            if (newValue != null) {
                              dashboardVM.setFilter(newValue);
                            }
                          },
                          items: const [
                            DropdownMenuItem(value: FilterPeriod.day, child: Text('Ngày')),
                            DropdownMenuItem(value: FilterPeriod.week, child: Text('Tuần')),
                            DropdownMenuItem(value: FilterPeriod.month, child: Text('Tháng')),
                            DropdownMenuItem(value: FilterPeriod.quarter, child: Text('Quý')),
                            DropdownMenuItem(value: FilterPeriod.year, child: Text('Năm')),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total: ${_formatCurrency(dashboardVM.filteredRevenue)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const Icon(Icons.trending_up, color: colorPrimary, size: 18),
                          ],
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          height: 150,
                          child: dashboardVM.weeklyRevenueData.isEmpty 
                              ? const Center(child: Text('Loading...', style: TextStyle(fontSize: 10, color: Color(0xFF4B5563))))
                              : SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: dashboardVM.weeklyRevenueData.map((data) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                        child: _buildMonochromeBar(data['label'], data['percentage']),
                                      );
                                    }).toList(),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 10),
                        const Text('*Biểu đồ tính dựa trên tỷ lệ doanh thu', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280), fontStyle: FontStyle.italic))
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('RECENT ORDERS', style: TextStyle(color: colorTextSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminOrdersScreen()));
                        },
                        style: TextButton.styleFrom(foregroundColor: colorPrimary),
                        child: const Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (dashboardVM.recentOrders.isEmpty)
                    const Padding(padding: EdgeInsets.all(20), child: Text("No orders found.", style: TextStyle(color: Color(0xFF4B5563))))
                  else
                    ...dashboardVM.recentOrders.map((order) => _buildRecentOrderTile(
                      order['customer_name'],
                      order['product_name'],
                      _formatCurrency(order['final_amount'] as num? ?? 0),
                      order['status'] ?? '',
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
      leading: Icon(icon, color: const Color(0xFF2B2B2B)),
      title: Text(title, style: const TextStyle(color: Color(0xFF2B2B2B), fontSize: 14, fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4361EE).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF4361EE), size: 20),
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(color: Color(0xFF2B2B2B), fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Color(0xFF4B5563), fontSize: 10, letterSpacing: 1.0, fontWeight: FontWeight.bold)),
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
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Color(0xFF4361EE), Color(0xFF4CC9F0)],
            ),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Color(0xFF4B5563), fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildRecentOrderTile(String name, String product, String price, String rawStatus) {
    final statusColor = _getStatusColor(rawStatus);
    final statusText = _translateStatus(rawStatus);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name.toUpperCase(), style: const TextStyle(color: Color(0xFF2B2B2B), fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text(product, style: const TextStyle(color: Color(0xFF4B5563), fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: const TextStyle(color: Color(0xFF4361EE), fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ),
            ],
          )
        ],
      ),
    );
  }
}
