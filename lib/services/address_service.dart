import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/address_model.dart';

class AddressService {
  static const String baseUrl = "http://10.0.2.2:3000";

  // Lấy tất cả địa chỉ của user
  Future<List<AddressModel>> getAddressesByUserId(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/addresses?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final List data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((e) => AddressModel.fromJson(e)).toList();
      } else {
        throw Exception('Server trả về lỗi: ${response.statusCode}');
      }
    } catch (e) {
      // Làm sạch chuỗi lỗi, tránh bị lồng nhau
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Lấyđịa chỉ mặcđịnh của user
  Future<AddressModel?> getDefaultAddress(String userId) async {
    try {
      final addresses = await getAddressesByUserId(userId);
      return addresses.firstWhere(
        (addr) => addr.isDefault,
        orElse: () => addresses.isNotEmpty
            ? addresses.first
            : throw Exception('Không tìm thấy địa chỉ'),
      );
    } catch (e) {
      return null;
    }
  }

  // Thêmđịa chỉ mới
  Future<AddressModel> addAddress(AddressModel address) async {
    try {
      if (address.isDefault) {
        await _removeOtherDefaults(address.userId);
      }

      final response = await http.post(
        Uri.parse('$baseUrl/addresses'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(address.toJson()),
      );

      if (response.statusCode == 201) {
        return AddressModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes)),
        );
      } else {
        throw Exception('Lỗi khi thêm địa chỉ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Cập nhậtđịa chỉ
  Future<AddressModel> updateAddress(String id, AddressModel address) async {
    try {
      if (address.isDefault) {
        await _removeOtherDefaults(address.userId, exceptId: id);
      }

      final response = await http.put(
        Uri.parse('$baseUrl/addresses/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(address.toJson()),
      );

      if (response.statusCode == 200) {
        return AddressModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes)),
        );
      } else {
        throw Exception('Lỗi khi cập nhậtđịa chỉ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Xóađịa chỉ
  Future<void> deleteAddress(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/addresses/$id'));

      if (response.statusCode != 200) {
        throw Exception('Lỗi khi xóađịa chỉ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Helper: Bỏ default của cácđịa chỉ khác
  Future<void> _removeOtherDefaults(String userId, {String? exceptId}) async {
    try {
      final addresses = await getAddressesByUserId(userId);
      for (var addr in addresses) {
        if (addr.isDefault && addr.id != exceptId) {
          await http.put(
            Uri.parse('$baseUrl/addresses/${addr.id}'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(addr.copyWith(isDefault: false).toJson()),
          );
        }
      }
    } catch (e) {
      throw Exception(
        'Lỗi khi update default: ${e.toString().replaceAll('Exception: ', '')}',
      );
    }
  }
}
