import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../models/cart_item.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  // SỬA: Đã thêm biến nhận hàm chuyển tab
  final Function(int)? onTabChange;

  const CartScreen({super.key, this.onTabChange});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    // Load giỏ hàng khi mở màn hình
    Future.microtask(() {
      Provider.of<CartViewModel>(context, listen: false).loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      appBar: AppBar(
        title: const Text(
          "Giỏ hàng",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff8E2DE2),
        // Đã xóa nút leading (Back) để không bị lỗi màn hình đen
      ),

      body: Consumer<CartViewModel>(
        builder: (context, cartVM, child) {
          if (cartVM.items.isEmpty) {
            return _buildEmptyCart();
          }

          return Column(
            children: [
              // Danh sách sản phẩm trong giỏ
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartVM.items.length,
                  itemBuilder: (context, index) {
                    final item = cartVM.items[index];
                    return _buildCartItem(context, item, cartVM);
                  },
                ),
              ),

              // Phần tổng tiền + nút thanh toán
              _buildBottomSummary(cartVM),
            ],
          );
        },
      ),
    );
  }

  // Widget hiển thị từng sản phẩm trong giỏ
  Widget _buildCartItem(
    BuildContext context,
    CartItem item,
    CartViewModel cartVM,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          // Ảnh sản phẩm
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildImage(item.image),
          ),

          const SizedBox(width: 12),

          // Thông tin sản phẩm
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "${item.price.toStringAsFixed(0)} VND",
                  style: const TextStyle(
                    color: Color(0xff8E2DE2),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),

                // Bộ điều chỉnh số lượng
                Row(
                  children: [
                    _qtyButton(
                      icon: Icons.remove,
                      onTap: () async {
                        if (item.quantity > 1) {
                          // Giảm số lượng
                          await cartVM.updateQuantity(
                            item.productId,
                            item.quantity - 1,
                          );
                        } else {
                          // Xóa nếu số lượng về 0
                          _confirmDelete(context, item, cartVM);
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        "${item.quantity}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _qtyButton(
                      icon: Icons.add,
                      onTap: () async {
                        await cartVM.updateQuantity(
                          item.productId,
                          item.quantity + 1,
                        );
                      },
                    ),

                    const Spacer(),

                    // Nút xóa sản phẩm
                    GestureDetector(
                      onTap: () => _confirmDelete(context, item, cartVM),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Dialog xác nhận xóa sản phẩm
  void _confirmDelete(
    BuildContext context,
    CartItem item,
    CartViewModel cartVM,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Xóa sản phẩm"),
        content: Text('Bạn có chắc muốn xóa "${item.name}" khỏi giỏ hàng?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await cartVM.removeFromCart(item.productId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Xóa", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Phần tổng tiền + nút thanh toán
  Widget _buildBottomSummary(CartViewModel cartVM) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Số lượng & tổng tiền
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Tổng (${cartVM.totalCount} sản phẩm):",
                style: const TextStyle(fontSize: 15, color: Colors.grey),
              ),
              Text(
                "${cartVM.totalPrice.toStringAsFixed(0)} VND",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff8E2DE2),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Nút thanh toán
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                final authVM = Provider.of<AuthViewModel>(
                  context,
                  listen: false,
                );

                // Lấy ID từ Map currentUser. Dùng toString() để đảm bảo không lỗi
                final userId = authVM.currentUser?['id']?.toString();

                if (userId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckoutScreen(userId: userId),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Vui lòng đăng nhập để tiếp tục!"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff8E2DE2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "Tiến hành thanh toán",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Màn hình giỏ hàng trống
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "Giỏ hàng trống",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Hãy thêm sản phẩm vào giỏ hàng",
            style: TextStyle(color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            // SỬA: Chuyển tab sang trang Sản phẩm thay vì dùng lệnh Navigator.pop
            onPressed: () {
              widget.onTabChange?.call(1);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff8E2DE2),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text("Mua sắm ngay"),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String path) {
    if (path.startsWith("http")) {
      return Image.network(
        path,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _errorImage(),
      );
    }
    return Image.asset(
      path,
      width: 80,
      height: 80,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _errorImage(),
    );
  }

  Widget _errorImage() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[300],
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }

  Widget _qtyButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xff8E2DE2)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: const Color(0xff8E2DE2), size: 16),
      ),
    );
  }
}
