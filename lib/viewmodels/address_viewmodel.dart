import 'package:flutter/material.dart';
import '../models/address_model.dart';
import '../services/address_service.dart';

class AddressViewModel extends ChangeNotifier {
  final AddressService _addressService = AddressService();

  List<AddressModel> _addresses = [];
  AddressModel? _selectedAddress;
  bool _isLoading = false;
  String? _errorMessage;

  List<AddressModel> get addresses => _addresses;
  AddressModel? get selectedAddress => _selectedAddress;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Lấy danh sách địa chỉ của user
  Future<void> loadAddresses(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _addresses = await _addressService.getAddressesByUserId(userId);

      // Tự động chọn địa chỉ mặc định
      if (_selectedAddress == null && _addresses.isNotEmpty) {
        _selectedAddress = _addresses.firstWhere(
          (addr) => addr.isDefault,
          orElse: () => _addresses.first,
        );
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Chọn địa chỉ
  void selectAddress(AddressModel address) {
    _selectedAddress = address;
    notifyListeners();
  }

  // Thêm địa chỉ mới
  Future<bool> addAddress(AddressModel address) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newAddress = await _addressService.addAddress(address);
      _addresses.add(newAddress);

      // Nếu là địa chỉ đầu tiên hoặc được đánh dấu mặc định, chọn nó
      if (_addresses.length == 1 || newAddress.isDefault) {
        _selectedAddress = newAddress;
      }

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

  // Cập nhật địa chỉ
  Future<bool> updateAddress(String id, AddressModel address) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedAddress = await _addressService.updateAddress(id, address);
      final index = _addresses.indexWhere((addr) => addr.id == id);
      if (index != -1) {
        _addresses[index] = updatedAddress;
        if (_selectedAddress?.id == id) {
          _selectedAddress = updatedAddress;
        }
      }

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

  // Xóa địa chỉ
  Future<bool> deleteAddress(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _addressService.deleteAddress(id);
      _addresses.removeWhere((addr) => addr.id == id);

      // Nếu xóa địa chỉ đang chọn, chọn địa chỉ khác
      if (_selectedAddress?.id == id) {
        _selectedAddress = _addresses.isNotEmpty ? _addresses.first : null;
      }

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

  // Reset
  void reset() {
    _addresses = [];
    _selectedAddress = null;
    _errorMessage = null;
    notifyListeners();
  }
}
