import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../viewmodels/wishlist_viewmodel.dart';
import '../services/api_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedQuantity = 1;
  bool _isDescriptionExpanded = false;
  
  String? _selectedSize;
  String? _selectedColor;

  List<Product> _relatedProducts = [];
  bool _isLoadingRelated = true;

  @override
  void initState() {
    super.initState();
    if (widget.product.sizes.isNotEmpty) {
      _selectedSize = widget.product.sizes.first;
    }
    if (widget.product.colors.isNotEmpty) {
      _selectedColor = widget.product.colors.first;
    }
    _loadRelatedProducts();
  }

  Future<void> _loadRelatedProducts() async {
    try {
      final apiService = ApiService();
      final products = await apiService.getProductsByCategory(widget.product.catergoryID);
      // Lọc bỏ sản phẩm hiện tại
      setState(() {
        _relatedProducts = products.where((p) => p.id != widget.product.id).toList();
        _isLoadingRelated = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingRelated = false;
      });
    }
  }

  Future<void> _addToCart(BuildContext context) async {
    if (widget.product.sizes.isNotEmpty && _selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui l�ng ch?n k�ch thu?c'), backgroundColor: Colors.red),
      );
      return;
    }
    if (widget.product.colors.isNotEmpty && _selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui l�ng ch?n m�u s?c'), backgroundColor: Colors.red),
      );
      return;
    }

    final cartVM = Provider.of<CartViewModel>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);

    // T?o t�n k�m ph�n lo?i
    String variation = '';
    if (_selectedColor != null || _selectedSize != null) {
      variation = ' (';
      if (_selectedColor != null) variation += 'M�u: $_selectedColor';
      if (_selectedColor != null && _selectedSize != null) variation += ', ';
      if (_selectedSize != null) variation += 'Size: $_selectedSize';
      variation += ')';
    }

    final cartItem = CartItem(
      productId: widget.product.id,
      name: '${widget.product.name}$variation',
      price: widget.product.price,
      image: widget.product.image,
      quantity: _selectedQuantity,
    );

    try {
      await cartVM.addToCart(cartItem);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text("�� th�m ${widget.product.name} v�o gi? h�ng"),
          backgroundColor: const Color(0xFF4361EE),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Kh�ng th? th�m v�o gi?! ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.orange[800],
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isOutOfStock = product.stock <= 0;
    const colorPrimary = Color(0xFF4361EE);

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: CustomScrollView(
        slivers: [
          // AppBar cu?n c�ng ?nh sản phẩm
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: colorPrimary,
            leading: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              ),
            ),
            actions: [
              Consumer<WishlistViewModel>(
                builder: (context, wishlistVM, child) {
                  final isFav = wishlistVM.isFavorite(product.id);
                  return GestureDetector(
                    onTap: () => wishlistVM.toggleFavorite(product),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4),
                        ],
                      ),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.red : Colors.black54,
                        size: 22,
                      ),
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _buildProductImage(product.image),
                  // N?nden m? du?i c�ng ?nhd? l�m r� c�c n�t khi cu?n
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.5),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
                  // T�n sản phẩm
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.2),
                  ),
                  const SizedBox(height: 12),
                  // Gi� v� Freeship tag
                  Row(
                    children: [
                      Text(
                        "${product.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VND",
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Color(0xffEE4D2D), // Changed to red per friend's update
                        ),
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
                  const SizedBox(height: 12),

                  // ��nh gi� & t�nh tr?ng kho
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < product.rating.floor()
                              ? Icons.star
                              : (index == product.rating.floor() && product.rating % 1 != 0
                                  ? Icons.star_half
                                  : Icons.star_border),
                          color: Colors.amber,
                          size: 18,
                        );
                      }),
                      const SizedBox(width: 4),
                      Text(
                        product.rating > 0 ? product.rating.toStringAsFixed(1) : "Chưa có�d�nh gi�",
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(width: 16),
                      Container(width: 1, height: 14, color: Colors.grey[300]),
                      const SizedBox(width: 16),
                      Icon(Icons.inventory_2_outlined, size: 16, color: isOutOfStock ? Colors.red : Colors.black54),
                      const SizedBox(width: 4),
                      Text(
                        isOutOfStock ? "H?t h�ng" : "C�n ${product.stock} SP",
                        style: TextStyle(
                          color: isOutOfStock ? Colors.red : Colors.black54,
                          fontSize: 14,
                          fontWeight: isOutOfStock ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 20),

                  // C?u h�nh: M�u s?c
                  if (product.colors.isNotEmpty) ...[
                    const Text('M�u s?c', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: product.colors.map((color) {
                        final isSelected = _selectedColor == color;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColor = color),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? colorPrimary : Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isSelected ? colorPrimary : Colors.grey[300]!),
                            ),
                            child: Text(
                              color,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // C?u h�nh: K�ch c?
                  if (product.sizes.isNotEmpty) ...[
                    const Text('K�ch c?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: product.sizes.map((size) {
                        final isSelected = _selectedSize == size;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedSize = size),
                          child: Container(
                            width: 50,
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? colorPrimary : Colors.grey[100],
                              shape: BoxShape.circle,
                              border: Border.all(color: isSelected ? colorPrimary : Colors.grey[300]!),
                            ),
                            child: Text(
                              size,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 20),
                  ],

                  // M� t? sản phẩm
                  const Text("Chi tiết sản phẩm", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    maxLines: _isDescriptionExpanded ? null : 4,
                    overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.black87, height: 1.6, fontSize: 14),
                  ),
                  if (product.description.length > 150)
                    GestureDetector(
                      onTap: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _isDescriptionExpanded ? "Thu gọn" : "Xem th�m",
                          style: const TextStyle(color: colorPrimary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Chọn số lượng
                  Row(
                    children: [
                      const Text("Số lượng:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 16),
                      _buildQuantitySelector(isOutOfStock, colorPrimary),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Sản phẩm li�n quan
                  const Text("Sản phẩm tương tự", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildRelatedProducts(colorPrimary),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -2)),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: isOutOfStock ? null : () => _addToCart(context),
              icon: Icon(isOutOfStock ? Icons.remove_shopping_cart : Icons.shopping_cart_outlined),
              label: Text(
                isOutOfStock ? "Sản phẩmd� h?t h�ng" : "Th�m v�o gi? h�ng",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorPrimary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.black38,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRelatedProducts(Color colorPrimary) {
    if (_isLoadingRelated) {
      return Center(child: CircularProgressIndicator(color: colorPrimary));
    }
    if (_relatedProducts.isEmpty) {
      return const Text("Kh�ng c� sản phẩm tương tự", style: TextStyle(color: Colors.black54));
    }

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _relatedProducts.length,
        itemBuilder: (context, index) {
          final p = _relatedProducts[index];
          return GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)),
              );
            },
            child: Container(
              width: 140,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: SizedBox(
                        width: double.infinity,
                        child: _buildProductImage(p.image),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${p.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VND",
                          style: const TextStyle(color: Color(0xffEE4D2D), fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuantitySelector(bool isOutOfStock, Color colorPrimary) {
    return Row(
      children: [
        _quantityButton(
          icon: Icons.remove,
          colorPrimary: colorPrimary,
          onTap: isOutOfStock ? null : () {
            if (_selectedQuantity > 1) {
              setState(() => _selectedQuantity--);
            }
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            isOutOfStock ? "0" : "$_selectedQuantity",
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold,
              color: isOutOfStock ? Colors.black54 : Colors.black
            ),
          ),
        ),
        _quantityButton(
          icon: Icons.add,
          colorPrimary: colorPrimary,
          onTap: isOutOfStock ? null : () {
            if (_selectedQuantity < widget.product.stock) {
              setState(() => _selectedQuantity++);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Ch? c�n ${widget.product.stock} sản phẩm trong kho!'))
              );
            }
          },
        ),
      ],
    );
  }

  Widget _quantityButton({required IconData icon, required VoidCallback? onTap, required Color colorPrimary}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          border: Border.all(color: onTap == null ? Colors.grey[300]! : colorPrimary),
          borderRadius: BorderRadius.circular(8),
          color: onTap == null ? Colors.grey[100] : Colors.white,
        ),
        child: Icon(icon, color: onTap == null ? Colors.black54 : colorPrimary, size: 20),
      ),
    );
  }

  Widget _buildProductImage(String path) {
    if (path.startsWith("http")) {
      return Image.network(path, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _errorImage());
    }
    return Image.asset(path, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _errorImage());
  }

  Widget _errorImage() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.image, size: 60, color: Colors.black54),
    );
  }
}
