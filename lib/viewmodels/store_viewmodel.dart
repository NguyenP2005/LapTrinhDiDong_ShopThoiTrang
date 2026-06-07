import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/store_model.dart';
import '../services/store_service.dart';

class StoreViewModel extends ChangeNotifier {
  final StoreService _storeService = StoreService();

  List<StoreModel> _stores = [];
  Position? _userPosition;
  bool _isLoading = false;
  String? _errorMessage;
  bool _locationDenied = false;

  List<StoreModel> get stores => _stores;
  Position? get userPosition => _userPosition;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get locationDenied => _locationDenied;

  // Cửa hàng gần nhất (sau khi đã tính khoảng cách)
  StoreModel? get nearestStore {
    if (_stores.isEmpty) return null;
    final withDistance = _stores.where((s) => s.distanceInKm != null).toList();
    if (withDistance.isEmpty) return null;
    withDistance.sort((a, b) => a.distanceInKm!.compareTo(b.distanceInKm!));
    return withDistance.first;
  }

  // Tải danh sách cửa hàng + xác định vị trí + tính khoảng cách
  Future<void> loadStores() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Lấy danh sách cửa hàng từ server
      _stores = await _storeService.getStores();

      // 2. Cố gắng lấy vị trí user (không bắt buộc)
      await _determinePosition();

      // 3. Nếu có vị trí, tính khoảng cách rồi sắp xếp gần -> xa
      if (_userPosition != null) {
        _calculateDistances();
        _stores.sort((a, b) {
          if (a.distanceInKm == null) return 1;
          if (b.distanceInKm == null) return -1;
          return a.distanceInKm!.compareTo(b.distanceInKm!);
        });
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tính khoảng cách (km) từ user tới từng cửa hàng bằng Haversine của geolocator
  void _calculateDistances() {
    if (_userPosition == null) return;
    for (var store in _stores) {
      final meters = Geolocator.distanceBetween(
        _userPosition!.latitude,
        _userPosition!.longitude,
        store.latitude,
        store.longitude,
      );
      store.distanceInKm = meters / 1000;
    }
  }

  // Xử lý quyền và lấy vị trí hiện tại
  Future<void> _determinePosition() async {
    _locationDenied = false;

    // Kiểm tra dịch vụ định vị có bật không
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _locationDenied = true;
      return; // Không có GPS -> vẫn hiện danh sách, chỉ không tính khoảng cách
    }

    // Kiểm tra & xin quyền
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _locationDenied = true;
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _locationDenied = true;
      return;
    }

    // Lấy vị trí hiện tại
    try {
      _userPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (e) {
      _locationDenied = true;
    }
  }
}
