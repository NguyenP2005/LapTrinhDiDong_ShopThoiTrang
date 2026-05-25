import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardViewModel extends ChangeNotifier {
  static const String baseUrl = "http://10.0.2.2:3000";

  bool isLoading = true;

  // Các biến lưu số liệu thật
  double totalRevenue = 0;
  int totalOrders = 0;
  int totalCustomers = 0;
  int totalProducts = 0;
  List<dynamic> recentOrders = [];

  Future<void> loadDashboardData() async {
    isLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      // Gọi đồng thời 3 API để lấy dữ liệu
      final resOrders = await http.get(Uri.parse('$baseUrl/orders'));
      final resUsers = await http.get(Uri.parse('$baseUrl/users'));
      final resProducts = await http.get(Uri.parse('$baseUrl/products'));

      if (resOrders.statusCode == 200 && resUsers.statusCode == 200 && resProducts.statusCode == 200) {
        List<dynamic> ordersData = jsonDecode(resOrders.body);
        List<dynamic> usersData = jsonDecode(resUsers.body);
        List<dynamic> productsData = jsonDecode(resProducts.body);

        // 1. Tính tổng số đơn hàng
                totalOrders = ordersData.length;

                // 2. Tính tổng doanh thu (Ép kiểu an toàn bằng "as num" và chuyển thành double)
                totalRevenue = ordersData.fold(0.0, (sum, order) => sum + ((order['final_amount'] ?? 0) as num).toDouble());

                // 3. Tính tổng khách hàng (Những user không phải admin)
                totalCustomers = usersData.where((u) => u['role'] != 'admin').length;

        // 4. Tính tổng số lượng sản phẩm đang bán
        totalProducts = productsData.length;

        // 5. Lấy danh sách 3 đơn hàng mới nhất
        var sortedOrders = List.from(ordersData);
        // Sắp xếp theo ngày tạo mới nhất (giảm dần)
        sortedOrders.sort((a, b) => (b['created_at'] ?? '').compareTo(a['created_at'] ?? ''));

        recentOrders = sortedOrders.take(3).map((order) {
          // Khớp user_id trong order với danh sách user để lấy ra tên người mua
          var user = usersData.firstWhere((u) => u['id'].toString() == order['user_id'].toString(), orElse: () => null);
          return {
            'id': order['id'],
            'customer_name': user != null ? user['name'] : 'Khách vãng lai',
            'product_name': 'Đơn hàng #${order['id']}', // Rút gọn tên hiển thị
            'final_amount': order['final_amount'],
            'status': order['status'],
          };
        }).toList();
      }
    } catch (e) {
      debugPrint("Lỗi load dữ liệu Dashboard: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}