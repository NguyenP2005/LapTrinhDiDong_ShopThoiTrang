class AddressModel {
  final String id;
  final String userId;
  final String receiverName;
  final String phone;
  final String address;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.userId,
    required this.receiverName,
    required this.phone,
    required this.address,
    required this.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      receiverName: json['receiver_name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      isDefault: json['is_default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'receiver_name': receiverName,
    'phone': phone,
    'address': address,
    'is_default': isDefault,
  };

  // Copy withđể update
  AddressModel copyWith({
    String? id,
    String? userId,
    String? receiverName,
    String? phone,
    String? address,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      receiverName: receiverName ?? this.receiverName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
