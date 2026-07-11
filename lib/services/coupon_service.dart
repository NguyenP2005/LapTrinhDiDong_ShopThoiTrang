import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/coupon_model.dart';

class CouponService {
  static const String baseUrl = "http://10.0.2.2:3000";

  Future<List<CouponModel>> getActiveCoupons() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/coupons'));
      if (response.statusCode == 200) {
        final List data = json.decode(utf8.decode(response.bodyBytes));
        return data
            .map((e) => CouponModel.fromJson(e))
            .where((c) => c.isActive)
            .toList();
      }
      throw Exception('Lỗi tải mã khuyến mãi: ${response.statusCode}');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<List<CouponModel>> getAllCoupons() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/coupons'));
      if (response.statusCode == 200) {
        final List data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((e) => CouponModel.fromJson(e)).toList();
      }
      throw Exception('Lỗi tải danh sách mã: ${response.statusCode}');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<CouponModel> createCoupon(CouponModel coupon) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/coupons'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(coupon.toJson()),
      );
      if (response.statusCode == 201) {
        return CouponModel.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      }
      throw Exception('Tạo mã thất bại: ${response.statusCode}');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<CouponModel> updateCoupon(CouponModel coupon) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/coupons/${coupon.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(coupon.toJson()),
      );
      if (response.statusCode == 200) {
        return CouponModel.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      }
      throw Exception('Cập nhật thất bại: ${response.statusCode}');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> deleteCoupon(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/coupons/$id'));
      if (response.statusCode != 200) {
        throw Exception('Xóa mã thất bại: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<CouponModel?> findByCode(String code) async {
    try {
      final coupons = await getActiveCoupons();
      final upperCode = code.trim().toUpperCase();
      for (var c in coupons) {
        if (c.code == upperCode) return c;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
