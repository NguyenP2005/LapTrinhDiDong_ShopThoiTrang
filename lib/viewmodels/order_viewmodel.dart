import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/order_item_model.dart';
import '../services/order_service.dart';

class OrderViewModel extends ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<OrderModel> _orders = [];
  OrderModel? _selectedOrder;
  List<OrderItemModel> _selectedOrderItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderModel> get orders => _orders;
  OrderModel? get selectedOrder => _selectedOrder;
  List<OrderItemModel> get selectedOrderItems => _selectedOrderItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Lọc đơn hàng theo trạng thái
  List<OrderModel> getOrdersByStatus(String status) {
    return _orders.where((order) => order.status == status).toList();
  }

  // Lấy danh sách đơn hàng của user (Dùng cho MyOrdersScreen)
  Future<void> loadUserOrders(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _orderService.getOrdersByUserId(userId);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Hàm trả về trực tiếp danh sách item (Khớp với màn hình OrderDetailScreen)
  Future<List<OrderItemModel>> getOrderItems(String orderId) async {
    try {
      return await _orderService.getOrderItems(orderId);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return [];
    }
  }

  // Lấy chi tiết đơn hàng + items lưu vào state
  Future<void> loadOrderDetail(String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedOrder = await _orderService.getOrderById(orderId);
      _selectedOrderItems = await _orderService.getOrderItems(orderId);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tạo đơn hàng mới
  Future<OrderModel?> createOrder(
    OrderModel order,
    List<OrderItemModel> items,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Tạo order trên server
      final createdOrder = await _orderService.createOrder(order);

      // 2. Map lại OrderId cho từng item
      final itemsWithOrderId = items.map((item) {
        return OrderItemModel(
          id: '', // Để rỗng cho json-server tự tạo ID
          orderId: createdOrder.id,
          productId: item.productId,
          productName: item.productName,
          productImage: item.productImage,
          quantity: item.quantity,
          price: item.price,
        );
      }).toList();

      // 3. Đẩy items lên server
      await _orderService.addOrderItems(itemsWithOrderId);

      _isLoading = false;
      notifyListeners();
      return createdOrder;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Cập nhật trạng thái đơn hàng
  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _orderService.updateOrderStatus(orderId, newStatus);

      // Reload lại data nếu đang có sẵn trong list
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        await loadUserOrders(_orders[index].userId);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Reset
  void reset() {
    _orders = [];
    _selectedOrder = null;
    _selectedOrderItems = [];
    _errorMessage = null;
    notifyListeners();
  }
}
