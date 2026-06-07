class OrderItemModel {
  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final String productImage;
  final int quantity;
  final double price;
  final String? color;
  final String? size;

  OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.price,
    this.color,
    this.size,
  });

  String get displayName {
    final parts = <String>[];
    if (color != null && color!.isNotEmpty) parts.add('Màu: $color');
    if (size != null && size!.isNotEmpty) parts.add('Size: $size');
    if (parts.isEmpty) return productName;
    return '$productName (${parts.join(', ')})';
  }

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      productName: json['product_name'] ?? '',
      productImage: json['product_image'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      color: (json['color'] as String?)?.isEmpty == true ? null : json['color'] as String?,
      size: (json['size'] as String?)?.isEmpty == true ? null : json['size'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'order_id': orderId,
    'product_id': productId,
    'product_name': productName,
    'product_image': productImage,
    'quantity': quantity,
    'price': price,
    'color': color ?? '',
    'size': size ?? '',
  };
}
