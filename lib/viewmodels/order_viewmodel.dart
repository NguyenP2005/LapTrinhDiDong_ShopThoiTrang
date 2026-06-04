import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/order_item_model.dart';
import '../services/order_service.dart';
import '../services/api_service.dart';

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

  // Lấy TẤT CẢ đơn hàng (Dùng cho Admin)
  Future<void> loadAllOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _orderService.getAllOrders();
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
      final apiService = ApiService();

      // 1. Tạo order trên server
      final createdOrder = await _orderService.createOrder(order);

      // 2. Map lại OrderId cho từng item
      final itemsWithOrderId = items.map((item) {
        return OrderItemModel(
          id: '',
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

      // 4. Trừ tồn kho từng sản phẩm
      for (final item in items) {
        try {
          final product = await apiService.getProductById(item.productId);
          if (product != null) {
            final newStock = (product.stock - item.quantity).clamp(0, product.stock);
            await apiService.updateProductStock(item.productId, newStock);
          }
        } catch (_) {
          // Bỏ qua lỗi trừ kho đơn lẻ, không block luồng đặt hàng
        }
      }

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
  Future<bool> updateOrderStatus(String orderId, String newStatus, {bool isAdmin = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _orderService.updateOrderStatus(orderId, newStatus);

      // Nếu trạng thái là đã hủy, hoàn trả lại số lượng tồn kho
      if (newStatus == 'cancelled') {
        final apiService = ApiService();
        final itemsToRestore = await _orderService.getOrderItems(orderId);
        for (final item in itemsToRestore) {
          try {
            final product = await apiService.getProductById(item.productId);
            if (product != null) {
              final newStock = product.stock + item.quantity;
              await apiService.updateProductStock(item.productId, newStock);
            }
          } catch (_) {
            // Bỏ qua lỗi cập nhật tồn kho đơn lẻ
          }
        }
      }

      // Reload lại data
      if (isAdmin) {
        await loadAllOrders();
      } else {
        final index = _orders.indexWhere((order) => order.id == orderId);
        if (index != -1) {
          await loadUserOrders(_orders[index].userId);
        }
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
