class CartItem {
  final String productId;
  final String name; // Tên gốc sản phẩm (không kèm biến thể)
  final String? color; // Màu sắc được chọn
  final String? size; // Kích cỡ được chọn
  final double price;
  final String image;
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    this.color,
    this.size,
    required this.price,
    required this.image,
    this.quantity = 1,
  });

  /// Tên hiển thị đầy đủ kèm biến thể màu/size
  String get displayName {
    final parts = <String>[];
    if (color != null && color!.isNotEmpty) parts.add('Màu: $color');
    if (size != null && size!.isNotEmpty) parts.add('Size: $size');
    if (parts.isEmpty) return name;
    return '$name (${parts.join(', ')})';
  }

  /// Sửa lỗi encoding tiếng Việt bị hỏng (ví dụ: "M?u:" → "Màu:")
  static String _fixVietnamese(String text) {
    return text
        .replaceAll('M?u:', 'Màu:')
        .replaceAll('M\u00c3\u00bcu:', 'Màu:')
        .replaceAll('M\u00e0u:', 'Màu:')
        .replaceAll('M\u00e2u:', 'Màu:')
        .replaceAll('M\u1ea7u:', 'Màu:')
        .replaceAll('M\u1eadu:', 'Màu:')
        .replaceAll('M\u00e3u:', 'Màu:');
  }

  /// Tách tên gốc và biến thể từ chuỗi name cũ kiểu "Tên (Màu: X, Size: Y)"
  static Map<String, String?> _parseOldName(String raw) {
    final fixed = _fixVietnamese(raw);
    final match = RegExp(r'^(.*?)\s*\(([^)]+)\)\s*$').firstMatch(fixed);
    if (match == null) return {'name': fixed, 'color': null, 'size': null};

    final baseName = match.group(1)!.trim();
    final variationStr = match.group(2)!;

    String? color;
    String? size;

    for (final part in variationStr.split(',')) {
      final kv = part.trim();
      if (kv.startsWith('Màu:')) {
        color = kv.replaceFirst('Màu:', '').trim();
      } else if (kv.startsWith('Size:')) {
        size = kv.replaceFirst('Size:', '').trim();
      }
    }
    return {'name': baseName, 'color': color, 'size': size};
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'color': color ?? '',
      'size': size ?? '',
      'price': price,
      'image': image,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    final rawName = map['name'] as String? ?? '';

    // Nếu DB cũ có cột color/size thì dùng trực tiếp
    final rawColor = map['color'] as String?;
    final rawSize = map['size'] as String?;

    if (rawColor != null && rawSize != null) {
      return CartItem(
        productId: map['productId'],
        name: _fixVietnamese(rawName),
        color: rawColor.isEmpty ? null : rawColor,
        size: rawSize.isEmpty ? null : rawSize,
        price: (map['price'] as num).toDouble(),
        image: map['image'],
        quantity: map['quantity'] as int,
      );
    }

    // Backward compat: parse tên cũ dạng "Tên (Màu: X, Size: Y)"
    final parsed = _parseOldName(rawName);
    return CartItem(
      productId: map['productId'],
      name: parsed['name']!,
      color: parsed['color'],
      size: parsed['size'],
      price: (map['price'] as num).toDouble(),
      image: map['image'],
      quantity: map['quantity'] as int,
    );
  }
}
