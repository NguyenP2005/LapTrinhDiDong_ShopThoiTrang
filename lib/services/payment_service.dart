import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/payment_model.dart';

class PaymentService {
  static const String baseUrl = "http://10.0.2.2:3000";

  // Tạo payment mới
  Future<PaymentModel> createPayment(PaymentModel payment) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payment.toJson()),
      );

      if (response.statusCode == 201) {
        return PaymentModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create payment');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Lấy thông tin payment của 1 đơn hàng
  Future<PaymentModel?> getPaymentByOrderId(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payments?order_id=$orderId'),
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          return PaymentModel.fromJson(data.first);
        }
        return null;
      } else {
        throw Exception('Failed to load payment');
      }
    } catch (e) {
      return null;
    }
  }

  // Cập nhật trạng thái payment
  Future<PaymentModel> updatePaymentStatus(
    String paymentId,
    String newStatus,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/payments/$paymentId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'status': newStatus,
          'paid_at': newStatus == 'success'
              ? DateTime.now().toIso8601String()
              : null,
        }),
      );

      if (response.statusCode == 200) {
        return PaymentModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update payment');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
