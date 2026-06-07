import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/wishlist_viewmodel.dart';
import '../models/product.dart';
import 'product_detail_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const colorPrimary = Color(0xff8E2DE2);

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff8E2DE2), Color(0xff4A00E0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Sản phẩm yêu thích",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Consumer<WishlistViewModel>(
        builder: (context, wishlistVM, child) {
          if (wishlistVM.wishlistItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    "Bạn chưa yêu thích sản phẩm nào",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: wishlistVM.wishlistItems.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.68,
            ),
            itemBuilder: (context, index) {
              final product = wishlistVM.wishlistItems[index];
              return _buildWishlistCard(context, product, wishlistVM);
            },
          );
        },
      ),
    );
  }

  Widget _buildWishlistCard(BuildContext context, Product product, WishlistViewModel vm) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: _buildProductImage(product.image), // Đã sửa lại chỗ này
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => vm.toggleFavorite(product),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.favorite, color: Colors.redAccent, size: 18),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${product.price.toStringAsFixed(0)} ₫",
                    style: const TextStyle(color: Color(0xff8E2DE2), fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HÀM LOAD ẢNH THÔNG MINH ---
  Widget _buildProductImage(String path) {
    if (path.startsWith("http")) {
      return Image.network(
        path,
        height: 140,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _errorImage(),
      );
    }
    // Nếu không có chữ http thì load từ máy
    return Image.asset(
      path,
      height: 140,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _errorImage(),
    );
  }

  Widget _errorImage() {
    return Container(
      height: 140,
      width: double.infinity,
      color: Colors.grey[200],
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }
}