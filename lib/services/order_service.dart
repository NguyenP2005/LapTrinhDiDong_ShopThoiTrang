import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';
import '../models/order_item_model.dart';

class OrderService {
  static const String baseUrl = "http://10.0.2.2:3000";

  // Lấy tất cảđơn hàng (Dành cho Admin)
  Future<List<OrderModel>> getAllOrders() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/orders'));

      if (response.statusCode == 200) {
        final List data = json.decode(utf8.decode(response.bodyBytes));
        final allOrders = data.map((e) => OrderModel.fromJson(e)).toList();
        allOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return allOrders;
      } else {
        throw Exception('Lỗi tải danh sách: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Lấy tất cảđơn hàng của user
  // Sửa lại hàm này trong order_service.dart
  // Lấy danh sáchđơn hàng (Dùng Dartđể tự lọc thay vì nhờ json-server)
  Future<List<OrderModel>> getOrdersByUserId(String userId) async {
    try {
      // 1. Kéo TOÀN BỘđơn hàng về máy
      final response = await http.get(Uri.parse('$baseUrl/orders'));

      if (response.statusCode == 200) {
        final List data = json.decode(utf8.decode(response.bodyBytes));

        // 2. Chuyển hết JSON thành Model
        final allOrders = data.map((e) => OrderModel.fromJson(e)).toList();

        // 3. Dùng Dartđể lọcđúng user (Cách này ép kiểu an toàn 100%)
        final userOrders = allOrders
            .where((order) => order.userId == userId)
            .toList();

        // 4. Tự sắp xếpđơn hàng mới nhất lênđầu
        userOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return userOrders;
      } else {
        throw Exception('Lỗi tải danh sách: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Lấy chi tiết 1đơn hàng
  Future<OrderModel> getOrderById(String orderId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/orders/$orderId'));

      if (response.statusCode == 200) {
        return OrderModel.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception('Lỗi tải chi tiếtđơn hàng: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Lấy các items của 1đơn hàng
  Future<List<OrderItemModel>> getOrderItems(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/order_items?order_id=$orderId'),
      );

      if (response.statusCode == 200) {
        final List data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((e) => OrderItemModel.fromJson(e)).toList();
      } else {
        throw Exception('Lỗi tải danh sách sản phẩm: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Tạođơn hàng mới
  Future<OrderModel> createOrder(OrderModel order) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(order.toJson()),
      );

      if (response.statusCode == 201) {
        return OrderModel.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception('Lỗi khi tạođơn hàng: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Thêm items vàođơn hàng
  Future<void> addOrderItems(List<OrderItemModel> items) async {
    try {
      for (var item in items) {
        final response = await http.post(
          Uri.parse('$baseUrl/order_items'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(item.toJson()),
        );
        if (response.statusCode != 201) {
          throw Exception(
            'Lỗi khi lưu sản phẩm vàođơn: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Cập nhật trạng tháiđơn hàng
  Future<OrderModel> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final order = await getOrderById(orderId);
      final updatedOrder = OrderModel(
        id: order.id,
        userId: order.userId,
        addressId: order.addressId,
        totalAmount: order.totalAmount,
        shippingFee: order.shippingFee,
        finalAmount: order.finalAmount,
        status: newStatus,
        paymentMethod: order.paymentMethod,
        createdAt: order.createdAt,
        updatedAt: DateTime.now().toIso8601String(),
      );

      final response = await http.put(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedOrder.toJson()),
      );

      if (response.statusCode == 200) {
        return OrderModel.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception('Lỗi khi cập nhật trạng thái: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
