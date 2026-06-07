import 'package:flutter/material.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';

class PaymentViewModel extends ChangeNotifier {
  final PaymentService _paymentService = PaymentService();

  PaymentModel? _currentPayment;
  String _selectedMethod = 'COD'; // COD hoặc BANK_TRANSFER
  String? _selectedBank;
  String? _accountNumber;
  bool _isLoading = false;
  String? _errorMessage;

  PaymentModel? get currentPayment => _currentPayment;
  String get selectedMethod => _selectedMethod;
  String? get selectedBank => _selectedBank;
  String? get accountNumber => _accountNumber;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Danh sách ngân hàng
  final List<Map<String, String>> banks = [
    {'name': 'Vietcombank', 'code': 'VCB'},
    {'name': 'VietinBank', 'code': 'CTG'},
    {'name': 'BIDV', 'code': 'BIDV'},
    {'name': 'Agribank', 'code': 'AGB'},
    {'name': 'MB Bank', 'code': 'MB'},
    {'name': 'Techcombank', 'code': 'TCB'},
    {'name': 'ACB', 'code': 'ACB'},
    {'name': 'VPBank', 'code': 'VPB'},
    {'name': 'TPBank', 'code': 'TPB'},
    {'name': 'Sacombank', 'code': 'STB'},
  ];

  // Chọn phương thức thanh toán
  void selectPaymentMethod(String method) {
    _selectedMethod = method;

    // Reset thông tin ngân hàng nếu chọn COD
    if (method == 'COD') {
      _selectedBank = null;
      _accountNumber = null;
    }

    notifyListeners();
  }

  // Chọn ngân hàng
  void selectBank(String bankName) {
    _selectedBank = bankName;
    notifyListeners();
  }

  // Nhập số tài khoản
  void setAccountNumber(String number) {
    _accountNumber = number;
    notifyListeners();
  }

  // Tạo payment mới
  Future<PaymentModel?> createPayment(PaymentModel payment) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentPayment = await _paymentService.createPayment(payment);
      _isLoading = false;
      notifyListeners();
      return _currentPayment;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Lấy thông tin payment củađơn hàng
  Future<void> loadPaymentByOrderId(String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentPayment = await _paymentService.getPaymentByOrderId(orderId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cập nhật trạng thái payment
  Future<bool> updatePaymentStatus(String paymentId, String newStatus) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _paymentService.updatePaymentStatus(paymentId, newStatus);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Validate dữ liệu trước khi thanh toán
  bool validatePaymentData() {
    if (_selectedMethod == 'BANK_TRANSFER') {
      if (_selectedBank == null || _selectedBank!.isEmpty) {
        _errorMessage = 'Vui lòng chọn ngân hàng';
        notifyListeners();
        return false;
      }
      if (_accountNumber == null || _accountNumber!.isEmpty) {
        _errorMessage = 'Vui lòng nhập số tài khoản';
        notifyListeners();
        return false;
      }
      if (_accountNumber!.length < 9) {
        _errorMessage = 'Số tài khoản không hợp lệ';
        notifyListeners();
        return false;
      }
    }
    return true;
  }

  // Reset
  void reset() {
    _currentPayment = null;
    _selectedMethod = 'COD';
    _selectedBank = null;
    _accountNumber = null;
    _errorMessage = null;
    notifyListeners();
  }
}
