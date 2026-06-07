import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../viewmodels/wishlist_viewmodel.dart'; // THÊM DÒNG IMPORT NÀY
import '../models/cart_item.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    const colorPrimary = Color(0xFF2344D1);

    return Scaffold(
      backgroundColor: const Color(0xffFDFDFD),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, colorPrimary),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductInfo(context),
                _buildRatingAndDescription(context, colorPrimary),
                _buildStockInfo(),
                _buildQuantitySelector(context),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context, colorPrimary),
    );
  }

  // --- APPBAR VỚI HÌNH ẢNH ---
  SliverAppBar _buildAppBar(BuildContext context, Color colorPrimary) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white70,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          product.name.length > 20 ? "${product.name.substring(0, 18)}..." : product.name,
          style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: (product.image.startsWith('http'))
            ? Image.network(product.image, fit: BoxFit.cover)
            : Image.asset(product.image, fit: BoxFit.cover),
      ),
    );
  }

  // --- THÔNG TIN TÊN & GIÁ ---
  Widget _buildProductInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, height: 1.2),
                ),
              ),
              const SizedBox(width: 12),
              // --- NÚT THẢ TIM WISHLIST ĐÃ ĐƯỢC KẾT NỐI ---
              Consumer<WishlistViewModel>(
                builder: (context, wishlistVM, child) {
                  final isFav = wishlistVM.isFavorite(product.id);
                  return GestureDetector(
                    onTap: () => wishlistVM.toggleFavorite(product),
                    child: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: Colors.redAccent,
                      size: 28,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                "${product.price.toStringAsFixed(0)} đ",
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xffEE4D2D)),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xffEE4D2D).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "FREESHIP",
                  style: TextStyle(color: Color(0xffEE4D2D), fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- ĐÁNH GIÁ & MÔ TẢ ---
  Widget _buildRatingAndDescription(BuildContext context, Color colorPrimary) {
    return Container(
      width: double.infinity,
      color: Colors.grey[50],
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Đánh giá", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < product.rating.floor()
                        ? Icons.star
                        : (index == product.rating.floor() && product.rating % 1 != 0
                            ? Icons.star_half
                            : Icons.star_border),
                    color: Colors.amber,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                product.rating.toStringAsFixed(1),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text("Mô tả sản phẩm", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            product.description,
            style: TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.6),
          ),
        ],
      ),
    );
  }

  // --- TỒN KHO ---
  Widget _buildStockInfo() {
    bool outOfStock = product.stock == 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          const Icon(Icons.inventory_2_outlined, color: Colors.grey),
          const SizedBox(width: 8),
          const Text("Tồn kho:", style: TextStyle(color: Colors.grey)),
          const SizedBox(width: 6),
          Text(
            outOfStock ? "Hết hàng" : "${product.stock} sản phẩm",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: outOfStock ? Colors.red : Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  // --- CHỌN SỐ LƯỢNG (UI ONLY) ---
  Widget _buildQuantitySelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Số lượng", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildQtyBtn(Icons.remove, () {}),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                color: Colors.grey[100],
                child: const Text(
                  "1",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              _buildQtyBtn(Icons.add, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        color: Colors.grey[200],
        child: Icon(icon, size: 20),
      ),
    );
  }

  // --- THANH TOÁN DƯỚI CÙNG ---
  Widget _buildBottomNavigationBar(BuildContext context, Color colorPrimary) {
    bool outOfStock = product.stock == 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: outOfStock ? Colors.grey : colorPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
                label: const Text(
                  "Thêm vào giỏ",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: outOfStock ? null : () => _addToCart(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Logic thêm vào giỏ hàng (giữ nguyên)
  void _addToCart(BuildContext context) {
    final cartVM = Provider.of<CartViewModel>(context, listen: false);
    cartVM.addToCart(
      CartItem(
        productId: product.id,
        name: product.name,
        price: product.price,
        image: product.image,
        quantity: 1, // Mặc định là 1 vì UI chưa gắn logic tăng giảm
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Đã thêm ${product.name} vào giỏ hàng"),
        backgroundColor: const Color(0xFF2344D1),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}