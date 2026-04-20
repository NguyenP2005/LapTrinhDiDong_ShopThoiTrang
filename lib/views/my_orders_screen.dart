import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/order_viewmodel.dart';
import '../models/order_model.dart';
import 'order_detail_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  final String userId;

  const MyOrdersScreen({super.key, required this.userId});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  @override
  void initState() {
    super.initState();
    // Tải danh sách đơn hàng ngay khi mở màn hình
    Future.microtask(() {
      print(
        "========== ĐANG TÌM ĐƠN HÀNG CHO USER ID: ${widget.userId} ==========",
      );
      Provider.of<OrderViewModel>(
        context,
        listen: false,
      ).loadUserOrders(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xffF5F5F5),
        appBar: AppBar(
          title: const Text(
            'Đơn hàng của tôi',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xff8E2DE2),
          // leading: GestureDetector(
          //   onTap: () => Navigator.of(context).pop(),
          //   child: Container(
          //     margin: const EdgeInsets.all(8),
          //     decoration: BoxDecoration(
          //       color: Colors.white.withOpacity(0.3),
          //       shape: BoxShape.circle,
          //     ),
          //     child: const Icon(
          //       Icons.arrow_back_ios_new,
          //       color: Colors.white,
          //       size: 20,
          //     ),
          //   ),
          // ),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Chờ xác nhận'),
              Tab(text: 'Đang giao'),
              Tab(text: 'Đã giao'),
              Tab(text: 'Đã hủy'),
            ],
          ),
        ),
        body: Consumer<OrderViewModel>(
          builder: (context, orderVM, child) {
            if (orderVM.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (orderVM.errorMessage != null) {
              return Center(
                child: Text(
                  'Lỗi: ${orderVM.errorMessage}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            final allOrders = orderVM.orders;

            return TabBarView(
              children: [
                _buildOrderList(
                  allOrders.where((o) => o.status == 'pending').toList(),
                ),
                _buildOrderList(
                  allOrders.where((o) => o.status == 'shipping').toList(),
                ),
                _buildOrderList(
                  allOrders.where((o) => o.status == 'delivered').toList(),
                ),
                _buildOrderList(
                  allOrders.where((o) => o.status == 'cancelled').toList(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Chưa có đơn hàng nào',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderDetailScreen(order: order),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mã ĐH: #${order.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      _formatDate(order.createdAt),
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tổng thanh toán:',
                      style: TextStyle(color: Colors.grey[700], fontSize: 15),
                    ),
                    Text(
                      '${order.finalAmount.toStringAsFixed(0)} đ',
                      style: const TextStyle(
                        color: Color(0xff8E2DE2),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xff8E2DE2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Xem chi tiết',
                      style: TextStyle(
                        color: Color(0xff8E2DE2),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Hàm cắt chuỗi ngày tháng đơn giản (từ ISO8601 sang YYYY-MM-DD)
  String _formatDate(String isoString) {
    try {
      return isoString.substring(0, 10);
    } catch (e) {
      return isoString;
    }
  }
}
