import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../models/cart_item.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  // S?A: �� th�m bi?n nh?n h�m chuy?n tab
  final Function(int)? onTabChange;

  const CartScreen({super.key, this.onTabChange});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    // Load gi? h�ng khi m? m�n h�nh
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartViewModel>(context, listen: false).loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      appBar: AppBar(
        title: const Text(
          "Gi? h�ng",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF4361EE),
        // �� x�a n�t leading (Back)d? kh�ng b? l?i m�n h�nhden
      ),

      body: Consumer<CartViewModel>(
        builder: (context, cartVM, child) {
          if (cartVM.items.isEmpty) {
            return _buildEmptyCart();
          }

          return Column(
            children: [
              // Danh s�ch sản phẩm trong gi?
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

              // Ph?n tổng tiền + n�t thanh to�n
              _buildBottomSummary(cartVM),
            ],
          );
        },
      ),
    );
  }

  // Widget hi?n th? t?ng sản phẩm trong gi?
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
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          // ?nh sản phẩm
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildImage(item.image),
          ),

          const SizedBox(width: 12),

          // Th�ng tin sản phẩm
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
                  "${item.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VND",
                  style: const TextStyle(
                    color: Color(0xFF4361EE),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),

                // B?di?u ch?nh s? lu?ng
                Row(
                  children: [
                    _qtyButton(
                      icon: Icons.remove,
                      onTap: () async {
                        if (item.quantity > 1) {
                          // Gi?m s? lu?ng
                          await cartVM.updateQuantity(
                            item.productId,
                            item.quantity - 1,
                          );
                        } else {
                          // X�a n?u s? lu?ng v? 0
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
                        try {
                          await cartVM.updateQuantity(
                            item.productId,
                            item.quantity + 1,
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Kh�ng th? tang th�m! ${e.toString().replaceAll('Exception: ', '')}',
                              ),
                              backgroundColor: Colors.orange[800],
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    ),

                    const Spacer(),

                    // N�t x�a sản phẩm
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

  // Dialog x�c nh?n x�a sản phẩm
  void _confirmDelete(
    BuildContext context,
    CartItem item,
    CartViewModel cartVM,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("X�a sản phẩm"),
        content: Text('B?n c� ch?c mu?n x�a "${item.name}" kh?i gi? h�ng?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: Colors.black54)),
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
            child: const Text("X�a", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Ph?n tổng tiền + n�t thanh to�n
  Widget _buildBottomSummary(CartViewModel cartVM) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
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
                "T?ng (${cartVM.totalCount} sản phẩm):",
                style: const TextStyle(fontSize: 15, color: Colors.black54),
              ),
              Text(
                "${cartVM.totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VND",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4361EE),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // N�t thanh to�n
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                final authVM = Provider.of<AuthViewModel>(
                  context,
                  listen: false,
                );

                // L?y ID t? Map currentUser. D�ng toString()d?d?m b?o kh�ng l?i
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
                      content: Text("Vui l�ngdang nh?pđể tiếp tục!"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4361EE),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "Ti?n h�nh thanh to�n",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // M�n h�nh gi? h�ng tr?ng
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.black38),
          const SizedBox(height: 16),
          Text(
            "Gi? h�ng tr?ng",
            style: TextStyle(
              fontSize: 18,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "H�y th�m sản phẩm v�o gi? h�ng",
            style: TextStyle(color: Colors.black38),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            // S?A: Chuy?n tab sang trang Sản phẩm thay v� d�ng l?nh Navigator.pop
            onPressed: () {
              widget.onTabChange?.call(1);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4361EE),
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
        errorBuilder: (_, _, _) => _errorImage(),
      );
    }
    return Image.asset(
      path,
      width: 80,
      height: 80,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _errorImage(),
    );
  }

  Widget _errorImage() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[300],
      child: const Icon(Icons.image, color: Colors.black54),
    );
  }

  Widget _qtyButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF4361EE)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: const Color(0xFF4361EE), size: 16),
      ),
    );
  }
}

