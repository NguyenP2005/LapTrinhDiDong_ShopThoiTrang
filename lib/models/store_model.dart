class StoreModel {
  final String id;
  final String name;
  final String address;
  final String phone;
  final double latitude;
  final double longitude;
  final String openHours;
  final String image;

  // Khoảng cách từ vị trí user tới cửa hàng (km).
  // Không lưu trên server,được tính ở client sau khi lấy vị trí.
  double? distanceInKm;

  StoreModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.openHours,
    required this.image,
    this.distanceInKm,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      openHours: json['open_hours'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'address': address,
    'phone': phone,
    'latitude': latitude,
    'longitude': longitude,
    'open_hours': openHours,
    'image': image,
  };
}
