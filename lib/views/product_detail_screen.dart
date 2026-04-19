import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../viewmodels/cart_viewmodel.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedQuantity = 1;
  bool _isDescriptionExpanded = false;
  bool _isFavorited = false;

  // Thêm vào giỏ hàng và hiển thị thông báo
  Future<void> _addToCart(BuildContext context) async {
    final cartVM = Provider.of<CartViewModel>(context, listen: false);

    final cartItem = CartItem(
      productId: widget.product.id,
      name: widget.product.name,
      price: widget.product.price,
      image: widget.product.image,
      quantity: _selectedQuantity,
    );

    await cartVM.addToCart(cartItem);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Đã thêm ${widget.product.name} vào giỏ hàng"),
        backgroundColor: const Color(0xff8E2DE2),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: CustomScrollView(
        slivers: [
          // AppBar cuộn cùng ảnh sản phẩm
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: const Color(0xff8E2DE2),
            leading: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.deepPurpleAccent,
                  size: 20,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorited ? Colors.red : Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isFavorited = !_isFavorited;
                  });
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildProductImage(product.image),
            ),
          ),

          // Nội dung chi tiết sản phẩm
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên & giá sản phẩm
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "${product.price.toStringAsFixed(0)} VND",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff8E2DE2),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Đánh giá & tình trạng kho
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Còn ${product.stock} sản phẩm",
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 20),

                  // Mô tả sản phẩm (có thể thu gọn/mở rộng)
                  const Text(
                    "Mô tả sản phẩm",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    maxLines: _isDescriptionExpanded ? null : 3,
                    overflow: _isDescriptionExpanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[700], height: 1.5),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isDescriptionExpanded = !_isDescriptionExpanded;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _isDescriptionExpanded ? "Thu gọn" : "Xem thêm",
                        style: const TextStyle(
                          color: Color(0xff8E2DE2),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Chọn số lượng
                  Row(
                    children: [
                      const Text(
                        "Số lượng:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      _buildQuantitySelector(),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Nút thêm vào giỏ hàng
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: product.stock > 0
                          ? () => _addToCart(context)
                          : null,
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: Text(
                        product.stock > 0 ? "Thêm vào giỏ hàng" : "Hết hàng",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff8E2DE2),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget selector số lượng sản phẩm
  Widget _buildQuantitySelector() {
    return Row(
      children: [
        _quantityButton(
          icon: Icons.remove,
          onTap: () {
            if (_selectedQuantity > 1) {
              setState(() => _selectedQuantity--);
            }
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "$_selectedQuantity",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        _quantityButton(
          icon: Icons.add,
          onTap: () {
            if (_selectedQuantity < widget.product.stock) {
              setState(() => _selectedQuantity++);
            }
          },
        ),
      ],
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xff8E2DE2)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xff8E2DE2), size: 20),
      ),
    );
  }

  // Xây dựng ảnh sản phẩm (hỗ trợ cả URL và asset)
  Widget _buildProductImage(String path) {
    if (path.startsWith("http")) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _errorImage(),
      );
    }
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _errorImage(),
    );
  }

  Widget _errorImage() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.image, size: 60, color: Colors.grey),
    );
  }
}
