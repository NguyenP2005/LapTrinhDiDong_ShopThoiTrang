import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../viewmodels/cart_viewmodel.dart';
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
  bool _isFavorited = false;
  
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
        const SnackBar(content: Text('Vui lòng chọn kích thước'), backgroundColor: Colors.red),
      );
      return;
    }
    if (widget.product.colors.isNotEmpty && _selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn màu sắc'), backgroundColor: Colors.red),
      );
      return;
    }

    final cartVM = Provider.of<CartViewModel>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);

    // Tạo tên kèm phân loại
    String variation = '';
    if (_selectedColor != null || _selectedSize != null) {
      variation = ' (';
      if (_selectedColor != null) variation += 'Màu: $_selectedColor';
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
          content: Text("Đã thêm ${widget.product.name} vào giỏ hàng"),
          backgroundColor: const Color(0xff8E2DE2),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Không thể thêm vào giỏ! ${e.toString().replaceAll('Exception: ', '')}'),
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

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: CustomScrollView(
        slivers: [
          // AppBar cuộn cùng ảnh sản phẩm
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: const Color(0xff8E2DE2),
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
              GestureDetector(
                onTap: () => setState(() => _isFavorited = !_isFavorited),
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
                    _isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorited ? Colors.red : Colors.grey[700],
                    size: 22,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _buildProductImage(product.image),
                  // Nền đen mờ dưới cùng ảnh để làm rõ các nút khi cuộn
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
                  // Tên & giá sản phẩm
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "${product.price.toStringAsFixed(0)} ₫",
                        style: const TextStyle(
                          fontSize: 22,
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
                      ...List.generate(5, (index) {
                        return Icon(
                          index < product.rating.floor()
                              ? Icons.star
                              : index < product.rating
                                  ? Icons.star_half
                                  : Icons.star_border,
                          color: Colors.amber,
                          size: 18,
                        );
                      }),
                      const SizedBox(width: 4),
                      Text(
                        product.rating > 0 ? product.rating.toStringAsFixed(1) : "Chưa có đánh giá",
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(width: 16),
                      Container(width: 1, height: 14, color: Colors.grey[300]),
                      const SizedBox(width: 16),
                      Icon(Icons.inventory_2_outlined, size: 16, color: isOutOfStock ? Colors.red : Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        isOutOfStock ? "Hết hàng" : "Còn ${product.stock} SP",
                        style: TextStyle(
                          color: isOutOfStock ? Colors.red : Colors.grey[600],
                          fontSize: 14,
                          fontWeight: isOutOfStock ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 20),

                  // Cấu hình: Màu sắc
                  if (product.colors.isNotEmpty) ...[
                    const Text('Màu sắc', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                              color: isSelected ? const Color(0xff8E2DE2) : Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isSelected ? const Color(0xff8E2DE2) : Colors.grey[300]!),
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

                  // Cấu hình: Kích cỡ
                  if (product.sizes.isNotEmpty) ...[
                    const Text('Kích cỡ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                              color: isSelected ? const Color(0xff8E2DE2) : Colors.grey[100],
                              shape: BoxShape.circle,
                              border: Border.all(color: isSelected ? const Color(0xff8E2DE2) : Colors.grey[300]!),
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

                  // Mô tả sản phẩm
                  const Text("Chi tiết sản phẩm", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    maxLines: _isDescriptionExpanded ? null : 4,
                    overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[800], height: 1.6, fontSize: 14),
                  ),
                  if (product.description.length > 150)
                    GestureDetector(
                      onTap: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _isDescriptionExpanded ? "Thu gọn" : "Xem thêm",
                          style: const TextStyle(color: Color(0xff8E2DE2), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Chọn số lượng
                  Row(
                    children: [
                      const Text("Số lượng:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 16),
                      _buildQuantitySelector(isOutOfStock),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Nút thêm vào giỏ hàng
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: isOutOfStock ? null : () => _addToCart(context),
                      icon: Icon(isOutOfStock ? Icons.remove_shopping_cart : Icons.shopping_cart_outlined),
                      label: Text(
                        isOutOfStock ? "Sản phẩm đã hết hàng" : "Thêm vào giỏ hàng",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff8E2DE2),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[400],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Sản phẩm liên quan
                  const Text("Sản phẩm tương tự", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildRelatedProducts(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedProducts() {
    if (_isLoadingRelated) {
      return const Center(child: CircularProgressIndicator(color: Color(0xff8E2DE2)));
    }
    if (_relatedProducts.isEmpty) {
      return const Text("Không có sản phẩm tương tự", style: TextStyle(color: Colors.grey));
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
                          "${p.price.toStringAsFixed(0)} ₫",
                          style: const TextStyle(color: Color(0xff8E2DE2), fontWeight: FontWeight.bold, fontSize: 13),
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

  Widget _buildQuantitySelector(bool isOutOfStock) {
    return Row(
      children: [
        _quantityButton(
          icon: Icons.remove,
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
              color: isOutOfStock ? Colors.grey : Colors.black
            ),
          ),
        ),
        _quantityButton(
          icon: Icons.add,
          onTap: isOutOfStock ? null : () {
            if (_selectedQuantity < widget.product.stock) {
              setState(() => _selectedQuantity++);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Chỉ còn ${widget.product.stock} sản phẩm trong kho!'))
              );
            }
          },
        ),
      ],
    );
  }

  Widget _quantityButton({required IconData icon, required VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          border: Border.all(color: onTap == null ? Colors.grey[300]! : const Color(0xff8E2DE2)),
          borderRadius: BorderRadius.circular(8),
          color: onTap == null ? Colors.grey[100] : Colors.white,
        ),
        child: Icon(icon, color: onTap == null ? Colors.grey : const Color(0xff8E2DE2), size: 20),
      ),
    );
  }

  Widget _buildProductImage(String path) {
    if (path.startsWith("http")) {
      return Image.network(path, fit: BoxFit.cover, errorBuilder: (_, _, _) => _errorImage());
    }
    return Image.asset(path, fit: BoxFit.cover, errorBuilder: (_, _, _) => _errorImage());
  }

  Widget _errorImage() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.image, size: 60, color: Colors.grey),
    );
  }
}
