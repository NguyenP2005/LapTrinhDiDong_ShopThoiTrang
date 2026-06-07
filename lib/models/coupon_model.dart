class CouponModel {
  final String id;
  final String code;
  final String description;
  final String type; // 'percent' (giảm %) hoặc 'fixed' (giảm tiền)
  final double value; // % nếu percent, số tiền (VND) nếu fixed
  final double maxDiscount; // trần giảm cho loại percent (0 = không giới hạn)
  final double minOrder; // đơn tối thiểu để áp dụng
  final bool isActive;

  CouponModel({
    required this.id,
    required this.code,
    required this.description,
    required this.type,
    required this.value,
    required this.maxDiscount,
    required this.minOrder,
    required this.isActive,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id']?.toString() ?? '',
      code: (json['code'] ?? '').toString().toUpperCase(),
      description: json['description'] ?? '',
      type: json['type'] ?? 'fixed',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      maxDiscount: (json['max_discount'] as num?)?.toDouble() ?? 0.0,
      minOrder: (json['min_order'] as num?)?.toDouble() ?? 0.0,
      isActive: json['is_active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'description': description,
    'type': type,
    'value': value,
    'max_discount': maxDiscount,
    'min_order': minOrder,
    'is_active': isActive,
  };

  /// Tính số tiền được giảm dựa trên tổng tiền hàng [orderAmount].
  /// Trả về 0 nếu chưa đạt đơn tối thiểu.
  double calculateDiscount(double orderAmount) {
    if (orderAmount < minOrder) return 0;

    double discount;
    if (type == 'percent') {
      discount = orderAmount * value / 100;
      // Áp trần giảm giá nếu có
      if (maxDiscount > 0 && discount > maxDiscount) {
        discount = maxDiscount;
      }
    } else {
      discount = value;
    }

    // Không giảm vượt quá tổng tiền hàng
    if (discount > orderAmount) discount = orderAmount;
    return discount;
  }
}
