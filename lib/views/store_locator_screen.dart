import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../viewmodels/store_viewmodel.dart';
import '../models/store_model.dart';

class StoreLocatorScreen extends StatefulWidget {
  const StoreLocatorScreen({super.key});

  @override
  State<StoreLocatorScreen> createState() => _StoreLocatorScreenState();
}

class _StoreLocatorScreenState extends State<StoreLocatorScreen> {
  GoogleMapController? _mapController;

  // Camera mặcđịnh: trung tâm TP.HCM
  static const LatLng _hcmCenter = LatLng(10.7769, 106.7009);

  @override
  void initState() {
    super.initState();
    // Tải cửa hàng + vị trí ngay khi mở màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoreViewModel>().loadStores();
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  // Tạo marker cho từng cửa hàng (+ marker user nếu có vị trí)
  Set<Marker> _buildMarkers(StoreViewModel vm) {
    final markers = <Marker>{};

    for (var store in vm.stores) {
      final isNearest = vm.nearestStore?.id == store.id;
      markers.add(
        Marker(
          markerId: MarkerId('store_${store.id}'),
          position: LatLng(store.latitude, store.longitude),
          // Cửa hàng gần nhất tô màu xanh lá, còn lại màu tím chuẩn
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isNearest ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueViolet,
          ),
          infoWindow: InfoWindow(
            title: store.name,
            snippet: store.distanceInKm != null
                ? '${store.distanceInKm!.toStringAsFixed(1)} km • ${store.address}'
                : store.address,
          ),
        ),
      );
    }

    return markers;
  }

  void _moveCamera(StoreModel store) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(store.latitude, store.longitude), 15),
    );
  }

  // Mở Google Mapsđể chỉđường tới cửa hàng (dùng app Google Maps có sẵn).
  Future<void> _openDirections(StoreModel store) async {
    final lat = store.latitude;
    final lng = store.longitude;

    // originđể trống -> Google tự lấy vị trí hiện tại của người dùng.
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=$lat,$lng'
      '&travelmode=driving',
    );

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'Không mởđược Google Maps';
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không mởđược chỉđường: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Mở app gọiđiện tới số của cửa hàng
  Future<void> _callStore(String phone) async {
    final telUri = Uri.parse('tel:${phone.replaceAll(' ', '')}');
    try {
      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri);
      } else {
        throw 'Không gọiđược';
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thực hiệnđược cuộc gọi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Cửa hàng gần bạn',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF4361EE),
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
      body: Consumer<StoreViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4361EE)),
            );
          }

          if (vm.errorMessage != null && vm.stores.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 56,
                      color: Color(0xFF4B5563),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Lỗi tải cửa hàng:\n${vm.errorMessage}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF4B5563)),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => vm.loadStores(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4361EE),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              // Cảnh báo nếu chưa cấp quyền vị trí
              if (vm.locationDenied)
                Container(
                  width: double.infinity,
                  color: Colors.orange[100],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Colors.orange[900],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Chưa bật vị trí — không tínhđược khoảng cách. '
                          'Vẫn xemđược tất cả cửa hàng bên dưới.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Bảnđồ Google Maps
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.42,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: vm.userPosition != null
                        ? LatLng(
                            vm.userPosition!.latitude,
                            vm.userPosition!.longitude,
                          )
                        : _hcmCenter,
                    zoom: 12,
                  ),
                  markers: _buildMarkers(vm),
                  myLocationEnabled: vm.userPosition != null,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                ),
              ),

              // Banner cửa hàng gần nhất
              if (vm.nearestStore != null)
                _buildNearestBanner(vm.nearestStore!),

              // Danh sách cửa hàng
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.stores.length,
                  itemBuilder: (context, index) {
                    final store = vm.stores[index];
                    final isNearest = vm.nearestStore?.id == store.id;
                    return _buildStoreCard(store, isNearest);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNearestBanner(StoreModel store) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff11998e), Color(0xff38ef7d)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.near_me, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gần bạn nhất',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  store.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          if (store.distanceInKm != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${store.distanceInKm!.toStringAsFixed(1)} km',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStoreCard(StoreModel store, bool isNearest) {
    return GestureDetector(
      onTap: () => _moveCamera(store),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isNearest ? const Color(0xff11998e) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4361EE).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.store,
                    color: Color(0xFF4361EE),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              store.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (isNearest)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xff11998e),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Gần nhất',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (store.distanceInKm != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            'Cách bạn ${store.distanceInKm!.toStringAsFixed(1)} km',
                            style: const TextStyle(
                              color: Color(0xff11998e),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _infoRow(Icons.location_on_outlined, store.address),
            const SizedBox(height: 6),
            _infoRow(Icons.phone_outlined, store.phone),
            const SizedBox(height: 6),
            _infoRow(Icons.access_time, 'Mở cửa: ${store.openHours}'),
            const SizedBox(height: 12),
            // Hai nút: Chỉđường + Gọi
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openDirections(store),
                    icon: const Icon(Icons.directions, size: 18),
                    label: const Text('Chỉđường'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4361EE),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _callStore(store.phone),
                    icon: const Icon(Icons.call, size: 18),
                    label: const Text('Gọi'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4361EE),
                      side: const BorderSide(color: Color(0xFF4361EE)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Color(0xFF4B5563)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
          ),
        ),
      ],
    );
  }
}
