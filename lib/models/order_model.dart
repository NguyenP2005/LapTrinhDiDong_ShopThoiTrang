class OrderModel {
  final String id;
  final String userId;
  final String addressId;
  final double totalAmount;
  final double shippingFee;
  final double finalAmount;
  final String status;
  final String paymentMethod;
  final String createdAt;
  final String updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.addressId,
    required this.totalAmount,
    required this.shippingFee,
    required this.finalAmount,
    required this.status,
    required this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      addressId: json['address_id']?.toString() ?? '',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      shippingFee: (json['shipping_fee'] as num?)?.toDouble() ?? 0.0,
      finalAmount: (json['final_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'address_id': addressId,
      'total_amount': totalAmount,
      'shipping_fee': shippingFee,
      'final_amount': finalAmount,
      'status': status,
      'payment_method': paymentMethod,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
