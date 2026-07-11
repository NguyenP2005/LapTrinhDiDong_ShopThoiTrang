import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/product_viewmodel.dart';
import 'package:clothing_app/views/product_detail_screen.dart';
import '../models/cart_item.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../views/cart_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String searchText = "";
  String selectedCategory = "All";
  String selectedPriceRange = "Tất cả";
  final TextEditingController _searchController = TextEditingController();

  static const Map<String, (double, double)> _priceRanges = {
    "Tất cả":   (0, double.infinity),
    "< 200K":   (0, 199999),
    "200-400K": (200000, 400000),
    "> 400K":   (400001, double.infinity),
  };

  String getCategoryName(int id) {
    switch (id) {
      case 1:
        return "Áo";
      case 2:
        return "Quần";
      case 3:
        return "Váy";
      case 4:
        return "Phụ kiện";
      default:
        return "Khác";
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductViewModel()..fetchProducts(),
      child: Scaffold(
        backgroundColor: const Color(0xffF5F5F5),

        appBar: AppBar(
          title: const Text(
            "Danh sách sản phẩm",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF4361EE),

          actions: [
            Consumer<CartViewModel>(
              builder: (context, cartVM, child) {
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.shopping_bag_outlined, // Giữ icon túi xách
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CartScreen()),
                        );
                      },
                    ),
                    // Badge hiển thị số lượng
                    if (cartVM.totalCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            "${cartVM.totalCount}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),

        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      searchText = value.trim().toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Tìm kiếm sản phẩm...",
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280)),

                    suffixIcon: searchText.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                searchText = "";
                              });
                            },
                          )
                        : null,

                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  buildFilter("All"),
                  buildFilter("Áo"),
                  buildFilter("Quần"),
                  buildFilter("Váy"),
                  buildFilter("Phụ kiện"),
                ],
              ),
            ),

            const SizedBox(height: 6),

            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: _priceRanges.keys
                    .map((label) => buildPriceFilter(label))
                    .toList(),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: Consumer<ProductViewModel>(
                builder: (context, vm, child) {
                  if (vm.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final (minPrice, maxPrice) = _priceRanges[selectedPriceRange]!;
                  final filtered = vm.products.where((p) {
                    final name = p.name.toLowerCase().trim();
                    final search = searchText.toLowerCase().trim();

                    final matchSearch =
                        name.contains(search) ||
                        getCategoryName(
                          p.catergoryID,
                        ).toLowerCase().contains(search);

                    final matchCategory =
                        selectedCategory == "All" ||
                        getCategoryName(p.catergoryID).toLowerCase().trim() ==
                            selectedCategory.toLowerCase().trim();

                    final matchPrice =
                        p.price >= minPrice && p.price <= maxPrice;

                    return matchSearch && matchCategory && matchPrice;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text("Không tìm thấy sản phẩm"));
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.65,
                        ),
                    itemBuilder: (context, index) {
                      final product = filtered[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailScreen(product: product),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Ảnh sản phẩm ──
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                child: _buildImage(product.image),
                              ),

                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Tên sản phẩm
                                    Text(
                                      product.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    // Badge danh mục
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        getCategoryName(product.catergoryID),
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    // Giá
                                    Text(
                                      "${product.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VND",
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    // ── THÊM MỚI: Hàng nút bên dưới ──
                                    Row(
                                      children: [
                                        // Nút "Chi tiết"
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      ProductDetailScreen(
                                                        product: product,
                                                      ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              height: 32,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: const Color(
                                                    0xFF4361EE,
                                                  ),
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              alignment: Alignment.center,
                                              child: const Text(
                                                "Chi tiết",
                                                style: TextStyle(
                                                  color: Color(0xFF4361EE),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(width: 6),

                                        // Nút giỏ hàng (icon)
                                        GestureDetector(
                                          onTap: () async {
                                            final cartVM =
                                                Provider.of<CartViewModel>(
                                                  context,
                                                  listen: false,
                                                );
                                            await cartVM.addToCart(
                                              CartItem(
                                                productId: product.id,
                                                name: product.name,
                                                price: product.price,
                                                image: product.image,
                                                quantity: 1,
                                              ),
                                            );
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "ĐĐã thêm ${product.name} vào giỏ",
                                                ),
                                                backgroundColor: const Color(
                                                  0xFF4361EE,
                                                ),
                                                duration: const Duration(
                                                  seconds: 2,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF4361EE).withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.shopping_bag_outlined,
                                              color: Color(0xFF4361EE),
                                              size: 18,
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
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String path) {
    if (path.startsWith("http")) {
      return Image.network(
        path,
        height: 140,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _errorImage(),
      );
    } else {
      return Image.asset(
        path,
        height: 140,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _errorImage(),
      );
    }
  }

  Widget _errorImage() {
    return Container(
      height: 140,
      color: Colors.grey[300],
      child: const Icon(Icons.image),
    );
  }

  Widget buildPriceFilter(String label) {
    final isSelected = selectedPriceRange == label;
    return GestureDetector(
      onTap: () => setState(() => selectedPriceRange = label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4361EE) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF4361EE) : Colors.grey.shade300,
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.attach_money, size: 13,
                color: isSelected ? Colors.white : Colors.black87),
            const SizedBox(width: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFilter(String category) {
    final isSelected = selectedCategory == category;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          category,
          style: TextStyle(color: isSelected ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}
