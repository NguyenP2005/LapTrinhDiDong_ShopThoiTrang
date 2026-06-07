import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/coupon_model.dart';

class CouponService {
  static const String baseUrl = "http://10.0.2.2:3000";

  // Lấy tất cả mã khuyến mãiđang hoạtđộng
  Future<List<CouponModel>> getActiveCoupons() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/coupons'));

      if (response.statusCode == 200) {
        final List data = json.decode(utf8.decode(response.bodyBytes));
        return data
            .map((e) => CouponModel.fromJson(e))
            .where((c) => c.isActive)
            .toList();
      } else {
        throw Exception('Lỗi tải mã khuyến mãi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Tìm mã khuyến mãi theo code (dùngđể áp mã thủ công)
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
