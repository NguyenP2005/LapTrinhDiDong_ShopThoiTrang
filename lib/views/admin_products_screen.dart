import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../viewmodels/admin_product_viewmodel.dart';
import 'admin_product_form_screen.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  static const colorBackground = Color(0xFFF4F7FC);
  static const colorPrimary = Color(0xFF4361EE);
  static const colorTextPrimary = Color(0xFF2B2B2B);

  // M�u s?c cho t?ng category
  final List<Color> _categoryColors = [
    colorPrimary,
    const Color(0xFF7B2FBE),
    const Color(0xFFE83E8C),
    const Color(0xFFFF7849),
    const Color(0xFF20C997),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProductViewModel>().fetchAll();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Color _getCategoryColor(int index) => _categoryColors[index % _categoryColors.length];

  Future<void> _openForm({Product? product}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<AdminProductViewModel>(),
          child: AdminProductFormScreen(product: product),
        ),
      ),
    );
    // N?u form luu th�nh c�ng th� refresh l?id?d?ng b?
    if (result == true && mounted) {
      // D? li?ud�du?c c?p nh?t trong ViewModel, ch? c?n UI rebuild
    }
  }

  Future<void> _confirmDelete(BuildContext context, Product product) async {
    final vm = context.read<AdminProductViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: const Text(
          'X�c nh?n x�a',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorTextPrimary),
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black54, fontSize: 14, height: 1.5),
            children: [
              const TextSpan(text: 'B?n c� ch?c mu?n x�a sản phẩm\n'),
              TextSpan(
                text: '"${product.name}"',
                style: const TextStyle(fontWeight: FontWeight.bold, color: colorTextPrimary),
              ),
              const TextSpan(text: '?\n\nH�nhd?ng n�y kh�ng th? ho�n t�c.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('X�a', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await vm.removeProduct(product.id);
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(success ? '�� x�a "${product.name}"' : 'X�a th?t b?i, vui l�ng th? l?i'),
            backgroundColor: success ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBackground,
      appBar: AppBar(
        backgroundColor: colorBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: colorTextPrimary),
        title: const Text(
          'PRODUCT MANAGEMENT',
          style: TextStyle(
            color: colorTextPrimary,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
            fontSize: 15,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _openForm(),
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colorPrimary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<AdminProductViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading && vm.products.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: colorPrimary));
          }

          if (vm.errorMessage != null && vm.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 56, color: Colors.black54),
                  const SizedBox(height: 16),
                  Text(vm.errorMessage!, style: const TextStyle(color: Colors.black54), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: vm.fetchAll,
                    style: ElevatedButton.styleFrom(backgroundColor: colorPrimary, foregroundColor: Colors.white),
                    child: const Text('Th? l?i'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: colorPrimary,
            backgroundColor: Colors.white,
            onRefresh: vm.fetchAll,
            child: Column(
              children: [
                // -- Search & Filter ----------------------------------------
                Container(
                  color: colorBackground,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    children: [
                      // Thanh t�m ki?m
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: vm.setSearchQuery,
                          style: const TextStyle(fontSize: 14, color: colorTextPrimary),
                          decoration: InputDecoration(
                            hintText: 'T�m ki?m sản phẩm...',
                            hintStyle: TextStyle(fontSize: 13, color: Colors.black38),
                            prefixIcon: const Icon(Icons.search, color: Colors.black54, size: 20),
                            suffixIcon: _searchCtrl.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close, size: 18, color: Colors.black54),
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      vm.setSearchQuery('');
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Filter chips theo category
                      SizedBox(
                        height: 36,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildFilterChip('T?t c?', null, vm),
                            ...vm.categories.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final cat = entry.value;
                              final catId = int.tryParse(cat.id.toString());
                              return _buildFilterChip(cat.name, catId, vm, color: _getCategoryColor(idx + 1));
                            }),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // �?m s? lu?ng sản phẩm
                      Row(
                        children: [
                          Text(
                            '${vm.products.length} sản phẩm',
                            style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600),
                          ),
                          if (vm.isLoading) ...[
                            const SizedBox(width: 8),
                            const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2, color: colorPrimary),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),

                // -- Danh s�ch sản phẩm ------------------------------------
                Expanded(
                  child: vm.products.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                          itemCount: vm.products.length,
                          itemBuilder: (context, index) {
                            return _buildProductCard(context, vm.products[index], vm);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),

      // FAB th�m sản phẩm
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: colorPrimary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add),
        label: const Text('Th�m sản phẩm', style: TextStyle(fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _buildFilterChip(String label, int? categoryId, AdminProductViewModel vm, {Color? color}) {
    final isSelected = vm.selectedCategoryId == categoryId;
    final chipColor = color ?? colorPrimary;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => vm.setCategory(categoryId),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? chipColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? chipColor : Colors.grey.shade300),
            boxShadow: isSelected
                ? [BoxShadow(color: chipColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
                : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product, AdminProductViewModel vm) {
    final catIdx = vm.categories.indexWhere(
      (c) => int.tryParse(c.id.toString()) == product.catergoryID,
    );
    final badgeColor = _getCategoryColor(catIdx >= 0 ? catIdx + 1 : 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          // -- ?nh sản phẩm ------------------------------------------------
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
            child: SizedBox(
              width: 100,
              height: 110,
              child: _buildProductImage(product.image),
            ),
          ),

          // -- Th�ng tin ----------------------------------------------------
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge + Rating
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          vm.getCategoryName(product.catergoryID),
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.star, color: Color(0xFFFFC107), size: 13),
                      const SizedBox(width: 2),
                      Text(
                        product.rating.toString(),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colorTextPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // T�n sản phẩm
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: colorTextPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Gi� & T?n kho
                  Row(
                    children: [
                      Text(
                        vm.formatPrice(product.price),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colorPrimary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: product.stock > 10
                              ? Colors.green.withValues(alpha: 0.1)
                              : product.stock > 0
                                  ? Colors.orange.withValues(alpha: 0.1)
                                  : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Kho: ${product.stock}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: product.stock > 10
                                ? Colors.green
                                : product.stock > 0
                                    ? Colors.orange
                                    : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // -- Action Menu -------------------------------------------------
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black54, size: 20),
              color: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              onSelected: (value) {
                if (value == 'edit') {
                  _openForm(product: product);
                } else if (value == 'delete') {
                  _confirmDelete(context, product);
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: colorPrimary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.edit_outlined, color: colorPrimary, size: 16),
                      ),
                      const SizedBox(width: 10),
                      const Text('Ch?nh s?a', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.delete_outline, color: Colors.red, size: 16),
                      ),
                      const SizedBox(width: 10),
                      const Text('X�a', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorPrimary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inventory_2_outlined, size: 40, color: colorPrimary),
          ),
          const SizedBox(height: 16),
          const Text(
            'Kh�ng t�m th?y sản phẩm',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Th? thayd?i b? l?c ho?c th�m sản phẩm m?i',
            style: TextStyle(fontSize: 13, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String imagePath) {
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _imgFallback(),
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Container(
            color: Colors.grey.shade100,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2, color: colorPrimary),
            ),
          );
        },
      );
    } else if (imagePath.isNotEmpty) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _imgFallback(),
      );
    }
    return _imgFallback();
  }

  Widget _imgFallback() {
    return Container(
      color: Colors.grey.shade100,
      child: const Center(
        child: Icon(Icons.image_not_supported_outlined, color: Colors.black54, size: 30),
      ),
    );
  }
}

