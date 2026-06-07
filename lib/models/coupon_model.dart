class CouponModel {
  final String id;
  final String code;
  final String description;
  final String type; // 'percent' hoặc 'fixed'
  final double value;
  final double maxDiscount;
  final double minOrder;
  final bool isActive;
  final String? expiresAt;

  CouponModel({
    required this.id,
    required this.code,
    required this.description,
    required this.type,
    required this.value,
    required this.maxDiscount,
    required this.minOrder,
    required this.isActive,
    this.expiresAt,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id']?.toString() ?? '',
      code: (json['code'] ?? '').toString().toUpperCase(),
      description: json['description'] ?? '',
      type: json['type'] ?? 'fixed',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      maxDiscount: (json['maxDiscount'] as num?)?.toDouble() ?? 0.0,
      minOrder: (json['minOrder'] as num?)?.toDouble() ?? 0.0,
      isActive: json['isActive'] ?? false,
      expiresAt: json['expiresAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'description': description,
    'type': type,
    'value': value,
    'maxDiscount': maxDiscount,
    'minOrder': minOrder,
    'isActive': isActive,
    if (expiresAt != null) 'expiresAt': expiresAt,
  };

  CouponModel copyWith({
    String? id,
    String? code,
    String? description,
    String? type,
    double? value,
    double? maxDiscount,
    double? minOrder,
    bool? isActive,
    String? expiresAt,
  }) {
    return CouponModel(
      id: id ?? this.id,
      code: code ?? this.code,
      description: description ?? this.description,
      type: type ?? this.type,
      value: value ?? this.value,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      minOrder: minOrder ?? this.minOrder,
      isActive: isActive ?? this.isActive,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  double calculateDiscount(double orderAmount) {
    if (orderAmount < minOrder) return 0;
    double discount;
    if (type == 'percent') {
      discount = orderAmount * value / 100;
      if (maxDiscount > 0 && discount > maxDiscount) discount = maxDiscount;
    } else {
      discount = value;
    }
    if (discount > orderAmount) discount = orderAmount;
    return discount;
  }
}
