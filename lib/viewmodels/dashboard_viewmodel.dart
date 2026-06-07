import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum FilterPeriod { day, week, month, quarter, year }

class DashboardViewModel extends ChangeNotifier {
  static const String baseUrl = "http://10.0.2.2:3000";

  bool isLoading = true;

  // Các biến lưu số liệu thật
  double totalRevenue = 0;
  int totalOrders = 0;
  int totalCustomers = 0;
  int totalProducts = 0;
  List<dynamic> recentOrders = [];
  List<Map<String, dynamic>> weeklyRevenueData = []; // Vẫn giữ tên biến cũ nhưng dùng cho mọi filter

  double filteredRevenue = 0;

  FilterPeriod currentFilter = FilterPeriod.day;
  List<dynamic> _cachedOrdersData = [];

  Future<void> loadDashboardData() async {
    isLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      // Gọiđồng thời 3 APIđể lấy dữ liệu
      final resOrders = await http.get(Uri.parse('$baseUrl/orders'));
      final resUsers = await http.get(Uri.parse('$baseUrl/users'));
      final resProducts = await http.get(Uri.parse('$baseUrl/products'));

      if (resOrders.statusCode == 200 && resUsers.statusCode == 200 && resProducts.statusCode == 200) {
        List<dynamic> ordersData = jsonDecode(resOrders.body);
        List<dynamic> usersData = jsonDecode(resUsers.body);
        List<dynamic> productsData = jsonDecode(resProducts.body);

        _cachedOrdersData = ordersData;

        // 1. Tính tổng sốđơn hàng
        totalOrders = ordersData.length;

        // 2. Tính tổng doanh thu (Ép kiểu an toàn bằng "as num" và chuyển thành double)
        totalRevenue = ordersData.fold(0.0, (sum, order) => sum + ((order['final_amount'] ?? 0) as num).toDouble());

        // 3. Tính tổng khách hàng (Những user không phải admin)
        totalCustomers = usersData.where((u) => u['role'] != 'admin').length;

        // 4. Tính tổng số lượng sản phẩmđang bán
        totalProducts = productsData.length;

        // 5. Lấy danh sách 3đơn hàng mới nhất
        var sortedOrders = List.from(ordersData);
        // Sắp xếp theo ngày tạo mới nhất (giảm dần)
        sortedOrders.sort((a, b) => (b['created_at'] ?? '').compareTo(a['created_at'] ?? ''));

        recentOrders = sortedOrders.take(3).map((order) {
          // Khớp user_id trong order với danh sách userđể lấy ra tên người mua
          var user = usersData.firstWhere((u) => u['id'].toString() == order['user_id'].toString(), orElse: () => null);
          return {
            'id': order['id'],
            'customer_name': user != null ? user['name'] : 'Khách vãng lai',
            'product_name': 'Đơn hàng #${order['id']}', // Rút gọn tên hiển thị
            'final_amount': order['final_amount'],
            'status': order['status'],
          };
        }).toList();

        // 6. Tính toán doanh thu theo bộ lọc
        calculateRevenueData();
      }
    } catch (e) {
      debugPrint("Lỗi load dữ liệu Dashboard: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  void setFilter(FilterPeriod filter) {
    if (currentFilter != filter) {
      currentFilter = filter;
      calculateRevenueData();
      notifyListeners();
    }
  }

  void calculateRevenueData() {
    DateTime now = DateTime.now();
    List<double> revenues = [];
    List<String> labels = [];

    switch (currentFilter) {
      case FilterPeriod.day:
        revenues = List.filled(7, 0.0);
        const List<String> weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
        for (int i = 6; i >= 0; i--) {
          DateTime day = now.subtract(Duration(days: i));
          labels.add(weekDays[day.weekday - 1]);
        }
        break;
      case FilterPeriod.week:
        revenues = List.filled(4, 0.0);
        for (int i = 3; i >= 0; i--) {
          labels.add('W${4 - i}');
        }
        break;
      case FilterPeriod.month:
        revenues = List.filled(12, 0.0);
        for (int i = 1; i <= 12; i++) {
          labels.add('T$i');
        }
        break;
      case FilterPeriod.quarter:
        revenues = List.filled(4, 0.0);
        labels = ['Q1', 'Q2', 'Q3', 'Q4'];
        break;
      case FilterPeriod.year:
        revenues = List.filled(5, 0.0);
        for (int i = 4; i >= 0; i--) {
          labels.add('${now.year - i}');
        }
        break;
    }

    // Cộng dồn doanh thu
    for (var order in _cachedOrdersData) {
      if (order['status'] == 'cancelled') continue;
      
      String? createdAtStr = order['created_at'];
      if (createdAtStr == null || createdAtStr.isEmpty) continue;

      try {
        DateTime createdAt = DateTime.parse(createdAtStr);
        double amount = ((order['final_amount'] ?? 0) as num).toDouble();

        switch (currentFilter) {
          case FilterPeriod.day:
            int diffDays = DateTime(now.year, now.month, now.day)
                .difference(DateTime(createdAt.year, createdAt.month, createdAt.day))
                .inDays;
            if (diffDays >= 0 && diffDays < 7) {
              revenues[6 - diffDays] += amount;
            }
            break;
          case FilterPeriod.week:
            int diffDays = DateTime(now.year, now.month, now.day)
                .difference(DateTime(createdAt.year, createdAt.month, createdAt.day))
                .inDays;
            if (diffDays >= 0 && diffDays < 28) {
              int weekIndex = diffDays ~/ 7;
              revenues[3 - weekIndex] += amount;
            }
            break;
          case FilterPeriod.month:
            if (createdAt.year == now.year) {
              revenues[createdAt.month - 1] += amount;
            }
            break;
          case FilterPeriod.quarter:
            if (createdAt.year == now.year) {
              int quarterIndex = (createdAt.month - 1) ~/ 3;
              revenues[quarterIndex] += amount;
            }
            break;
          case FilterPeriod.year:
            int diffYears = now.year - createdAt.year;
            if (diffYears >= 0 && diffYears < 5) {
              revenues[4 - diffYears] += amount;
            }
            break;
        }
      } catch (e) {
        // Bỏ qua nếu lỗi parse ngày
      }
    }

    filteredRevenue = revenues.fold(0.0, (sum, val) => sum + val);

    // Tìm doanh thu cao nhấtđể tính phần trăm (cho chiều cao cột)
    double maxRevenue = revenues.fold(0.0, (max, v) => v > max ? v : max);
    
    weeklyRevenueData = [];
    for (int i = 0; i < revenues.length; i++) {
      double percentage = maxRevenue > 0 ? (revenues[i] / maxRevenue) : 0.0;
      if (percentage.isNaN || percentage.isInfinite) percentage = 0.0;
      weeklyRevenueData.add({
        'label': labels[i],
        'percentage': percentage,
      });
    }
  }
}