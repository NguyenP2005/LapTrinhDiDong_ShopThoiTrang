import 'package:flutter/foundation.dart';
import '../models/coupon_model.dart';
import '../services/coupon_service.dart';

enum AdminCouponStatus { idle, loading, success, error }

class AdminCouponViewModel extends ChangeNotifier {
  final CouponService _service = CouponService();

  List<CouponModel> _coupons = [];
  AdminCouponStatus _status = AdminCouponStatus.idle;
  String? _errorMessage;
  String _search = '';

  List<CouponModel> get coupons {
    if (_search.isEmpty) return _coupons;
    final q = _search.toLowerCase();
    return _coupons.where((c) =>
      c.code.toLowerCase().contains(q) ||
      c.description.toLowerCase().contains(q)
    ).toList();
  }

  AdminCouponStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AdminCouponStatus.loading;

  void setSearch(String q) {
    _search = q;
    notifyListeners();
  }

  Future<void> loadCoupons() async {
    _status = AdminCouponStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _coupons = await _service.getAllCoupons();
      _status = AdminCouponStatus.success;
    } catch (e) {
      _status = AdminCouponStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }
    notifyListeners();
  }

  Future<bool> createCoupon(CouponModel coupon) async {
    try {
      final created = await _service.createCoupon(coupon);
      _coupons.insert(0, created);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCoupon(CouponModel coupon) async {
    try {
      final updated = await _service.updateCoupon(coupon);
      final idx = _coupons.indexWhere((c) => c.id == coupon.id);
      if (idx != -1) _coupons[idx] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCoupon(String id) async {
    try {
      await _service.deleteCoupon(id);
      _coupons.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleActive(CouponModel coupon) async {
    return updateCoupon(coupon.copyWith(isActive: !coupon.isActive));
  }
}
