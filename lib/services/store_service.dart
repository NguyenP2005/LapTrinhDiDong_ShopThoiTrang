import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/store_model.dart';

class StoreService {
  static const String baseUrl = "http://10.0.2.2:3000";

  // Lấy danh sách tất cả cửa hàng
  Future<List<StoreModel>> getStores() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/stores'));

      if (response.statusCode == 200) {
        final List data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((e) => StoreModel.fromJson(e)).toList();
      } else {
        throw Exception('Lỗi tải danh sách cửa hàng: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
