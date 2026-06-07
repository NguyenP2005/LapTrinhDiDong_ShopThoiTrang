import 'package:flutter/material.dart';
import '../models/coupon_model.dart';
import '../services/coupon_service.dart';

class CouponViewModel extends ChangeNotifier {
  final CouponService _couponService = CouponService();

  List<CouponModel> _availableCoupons = [];
  CouponModel? _appliedCoupon;
  double _discount = 0;
  bool _isLoading = false;
  String? _errorMessage;

  List<CouponModel> get availableCoupons => _availableCoupons;
  CouponModel? get appliedCoupon => _appliedCoupon;
  double get discount => _discount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Tải danh sách mã khuyến mãi đang hoạt động
  Future<void> loadCoupons() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _availableCoupons = await _couponService.getActiveCoupons();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Áp mã bằng cách nhập code. orderAmount = tổng tiền hàng (chưa gồm ship)
  Future<bool> applyCode(String code, double orderAmount) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final coupon = await _couponService.findByCode(code);

    if (coupon == null) {
      _errorMessage = 'Mã khuyến mãi không tồn tại hoặc đã hết hạn';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    return _apply(coupon, orderAmount);
  }

  // Áp mã trực tiếp từ danh sách gợi ý
  bool applyCoupon(CouponModel coupon, double orderAmount) {
    _errorMessage = null;
    return _apply(coupon, orderAmount);
  }

  bool _apply(CouponModel coupon, double orderAmount) {
    if (orderAmount < coupon.minOrder) {
      _errorMessage =
          'Đơn tối thiểu ${coupon.minOrder.toStringAsFixed(0)}đ để dùng mã này';
      _appliedCoupon = null;
      _discount = 0;
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final d = coupon.calculateDiscount(orderAmount);
    if (d <= 0) {
      _errorMessage = 'Mã không áp dụng được cho đơn hàng này';
      _appliedCoupon = null;
      _discount = 0;
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _appliedCoupon = coupon;
    _discount = d;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  // Gỡ mã đang áp
  void removeCoupon() {
    _appliedCoupon = null;
    _discount = 0;
    _errorMessage = null;
    notifyListeners();
  }

  // Reset toàn bộ (gọi khi thoát checkout / đặt hàng xong)
  void reset() {
    _availableCoupons = [];
    _appliedCoupon = null;
    _discount = 0;
    _errorMessage = null;
    notifyListeners();
  }
}
