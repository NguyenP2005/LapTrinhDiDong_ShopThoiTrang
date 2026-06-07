import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../viewmodels/admin_product_viewmodel.dart';

class AdminProductFormScreen extends StatefulWidget {
  final Product? product;

  const AdminProductFormScreen({super.key, this.product});

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollCtrl = ScrollController();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _imageCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _ratingCtrl;
  final TextEditingController _sizeInputCtrl = TextEditingController();
  final TextEditingController _colorInputCtrl = TextEditingController();

  int? _selectedCategoryId;
  List<String> _sizes = [];
  List<String> _colors = [];
  bool _isSaving = false;

  bool get _isEditing => widget.product != null;

  static const _bgColor = Color(0xFFF4F7FC);
  static const _primary = Color(0xFF4361EE);
  static const _textDark = Color(0xFF1A1A2E);
  static const _textMid = Color(0xFF6B7280);
  static const _cardBg = Colors.white;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _priceCtrl = TextEditingController(
        text: p != null ? p.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.') : '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _imageCtrl = TextEditingController(text: p?.image ?? '');
    _stockCtrl =
        TextEditingController(text: p != null ? p.stock.toString() : '');
    _ratingCtrl = TextEditingController(
        text: p != null ? p.rating.toString() : '5.0');
    _selectedCategoryId = p?.catergoryID;
    _sizes = p != null ? List.from(p.sizes) : [];
    _colors = p != null ? List.from(p.colors) : [];
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    _imageCtrl.dispose();
    _stockCtrl.dispose();
    _ratingCtrl.dispose();
    _sizeInputCtrl.dispose();
    _colorInputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _addTag(String val, List<String> list) {
    final trimmed = val.trim();
    if (trimmed.isNotEmpty && !list.contains(trimmed)) {
      setState(() => list.add(trimmed));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      _toast('Vui lòng chọn danh mục sản phẩm', isError: true);
      return;
    }
    if (_sizes.isEmpty) {
      _toast('Vui lòng thêm ít nhất một kích cỡ', isError: true);
      return;
    }
    if (_colors.isEmpty) {
      _toast('Vui lòng thêm ít nhất một màu sắc', isError: true);
      return;
    }

    final vm = context.read<AdminProductViewModel>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: Text(
          _isEditing ? 'Xác nhận cập nhật' : 'Xác nhận thêm sản phẩm',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _textDark),
        ),
        content: Text(
          _isEditing 
            ? 'Bạn có chắc chắn muốn lưu các thayđổi cho sản phẩm này không?' 
            : 'Bạn có chắc chắn muốn thêm sản phẩm mới này vào hệ thống không?',
          style: const TextStyle(color: _textMid, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy', style: TextStyle(color: _textMid)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Xác nhận', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSaving = true);
    final data = {
      'name': _nameCtrl.text.trim(),
      'price': double.tryParse(_priceCtrl.text.trim()) ?? 0,
      'description': _descCtrl.text.trim(),
      'image': _imageCtrl.text.trim(),
      'category_id': _selectedCategoryId,
      'stock': int.tryParse(_stockCtrl.text.trim()) ?? 0,
      'rating': double.tryParse(_ratingCtrl.text.trim()) ?? 5.0,
      'sizes': _sizes,
      'colors': _colors,
    };

    final success = _isEditing
        ? await vm.editProduct(widget.product!.id, data)
        : await vm.addProduct(data);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.pop(context, true);
      _toast(
        _isEditing ? 'Cập nhật sản phẩm thành công!' : 'Thêm sản phẩm thành công!',
      );
    } else {
      _toast(vm.errorMessage ?? 'Có lỗi xảy ra, vui lòng thử lại', isError: true);
    }
  }

  void _toast(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(msg, style: const TextStyle(fontSize: 13))),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── Helpers xây dựng image widget ─────────────────────────────────────────
  Widget _buildImagePreview(String path) {
    if (path.isEmpty) return const SizedBox.shrink();
    if (path.startsWith('http')) {
      return Image.network(path,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _imgPlaceholder('URL ảnh không hợp lệ'));
    }
    return Image.asset(path,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _imgPlaceholder('Ảnh asset không tồn tại'));
  }

  Widget _imgPlaceholder(String msg) => Container(
        color: Colors.grey.shade100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.broken_image_outlined, size: 36, color: Colors.black54),
            const SizedBox(height: 6),
            Text(msg,
                style: const TextStyle(color: Colors.black54, fontSize: 11),
                textAlign: TextAlign.center),
          ],
        ),
      );

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminProductViewModel>();

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: _buildAppBar(),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          controller: _scrollCtrl,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            // ─── Header banner ────────────────────────────────────────────
            _buildHeaderBanner(),
            const SizedBox(height: 20),

            // ─── 1. Ảnh sản phẩm ──────────────────────────────────────────
            _buildCard(
              stepNum: 1,
              title: 'Ảnh sản phẩm',
              icon: Icons.image_outlined,
              child: _buildImageSection(),
            ),
            const SizedBox(height: 14),

            // ─── 2. Thông tin chính ───────────────────────────────────────
            _buildCard(
              stepNum: 2,
              title: 'Thông tin chính',
              icon: Icons.info_outline,
              child: _buildMainInfoSection(),
            ),
            const SizedBox(height: 14),

            // ─── 3. Danh mục & Tồn kho ────────────────────────────────────
            _buildCard(
              stepNum: 3,
              title: 'Danh mục & Tồn kho',
              icon: Icons.category_outlined,
              child: _buildCategoryStockSection(vm),
            ),
            const SizedBox(height: 14),

            // ─── 4. Mô tả ─────────────────────────────────────────────────
            _buildCard(
              stepNum: 4,
              title: 'Mô tả sản phẩm',
              icon: Icons.description_outlined,
              child: _buildDescSection(),
            ),
            const SizedBox(height: 14),

            // ─── 5. Kích cỡ ───────────────────────────────────────────────
            _buildCard(
              stepNum: 5,
              title: 'Kích cỡ',
              icon: Icons.straighten_outlined,
              child: _buildTagSection(
                controller: _sizeInputCtrl,
                tags: _sizes,
                hint: 'S, M, L, 30, 32...',
                onAdd: () {
                  _addTag(_sizeInputCtrl.text, _sizes);
                  _sizeInputCtrl.clear();
                },
                onRemove: (s) => setState(() => _sizes.remove(s)),
                tagColor: _primary,
              ),
            ),
            const SizedBox(height: 14),

            // ─── 6. Màu sắc ───────────────────────────────────────────────
            _buildCard(
              stepNum: 6,
              title: 'Màu sắc',
              icon: Icons.palette_outlined,
              child: _buildTagSection(
                controller: _colorInputCtrl,
                tags: _colors,
                hint: 'Đen, Trắng, Đỏ...',
                onAdd: () {
                  _addTag(_colorInputCtrl.text, _colors);
                  _colorInputCtrl.clear();
                },
                onRemove: (c) => setState(() => _colors.remove(c)),
                tagColor: const Color(0xFFE83E8C),
              ),
            ),
          ],
        ),
      ),

      // ── Nút Lưu cốđịnh dướiđáy ──────────────────────────────────────────
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _bgColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: const IconThemeData(color: _textDark),
      centerTitle: true,
      title: Text(
        _isEditing ? 'Chỉnh sửa sản phẩm' : 'Thêm sản phẩm mới',
        style: const TextStyle(
          color: _textDark,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4361EE), Color(0xFF7B2FBE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _isEditing ? Icons.edit_note_rounded : Icons.add_box_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? 'Chỉnh sửa sản phẩm' : 'Thêm sản phẩm mới',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isEditing
                      ? 'Cập nhật thông tin sản phẩm của bạn'
                      : 'Điềnđầyđủ thông tin bên dưới',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required int stepNum,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade100, width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4361EE), Color(0xFF7B2FBE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$stepNum',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(icon, size: 18, color: _primary),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(
                    color: _textDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Card body
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  // ── Sections ──────────────────────────────────────────────────────────────

  Widget _buildImageSection() {
    final path = _imageCtrl.text.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Preview box
        GestureDetector(
          onTap: () {},
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: path.isEmpty ? Colors.grey.shade200 : _primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: path.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: _primary.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add_photo_alternate_outlined,
                              size: 28, color: _primary),
                        ),
                        const SizedBox(height: 10),
                        const Text('Nhập URL hoặcđường dẫn ảnh bên dưới',
                            style: TextStyle(color: _textMid, fontSize: 12)),
                      ],
                    )
                  : _buildImagePreview(path),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // URL input
        _buildInputField(
          controller: _imageCtrl,
          hint: 'assets/images/image01.webp  hoặc  https://...',
          prefixIcon: Icons.link,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Nhậpđường dẫn ảnh';
            if (!v.startsWith('http') && !v.startsWith('assets/')) {
              return 'Đường dẫn phải bắtđầu bằng http hoặc assets/';
            }
            return null;
          },
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildMainInfoSection() {
    return Column(
      children: [
        _buildInputField(
          controller: _nameCtrl,
          label: 'Tên sản phẩm',
          hint: 'VD: Áo thun basic trắng',
          prefixIcon: Icons.label_outline,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Tên khôngđược trống';
            if (v.trim().length < 3) return 'Tên phải dài hơn 3 ký tự';
            return null;
          },
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildInputField(
                controller: _priceCtrl,
                label: 'Giá (đ)',
                hint: '199000',
                prefixIcon: Icons.sell_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Nhập giá';
                  final price = double.tryParse(v.trim());
                  if (price == null) return 'Phải là số';
                  if (price <= 0) return 'Giá phải > 0';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInputField(
                controller: _ratingCtrl,
                label: 'Rating',
                hint: '4.5',
                prefixIcon: Icons.star_outline,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Nhập rating';
                  final r = double.tryParse(v.trim());
                  if (r == null) return 'Phải là số';
                  if (r < 0 || r > 5) return 'Từ 0đến 5';
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryStockSection(AdminProductViewModel vm) {
    return Column(
      children: [
        // Dropdown danh mục
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _fieldLabel('Danh mục'),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedCategoryId != null
                      ? _primary.withValues(alpha: 0.5)
                      : Colors.grey.shade300,
                  width: 1.2,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: _selectedCategoryId,
                  hint: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Chọn danh mục',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  borderRadius: BorderRadius.circular(12),
                  dropdownColor: Colors.white,
                  icon: const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Icon(Icons.keyboard_arrow_down, color: _textMid),
                  ),
                  style: const TextStyle(fontSize: 14, color: _textDark),
                  items: vm.categories.map((cat) {
                    return DropdownMenuItem<int>(
                      value: int.tryParse(cat.id),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(cat.name,
                              style: const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCategoryId = val),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildInputField(
          controller: _stockCtrl,
          label: 'Số lượng tồn kho',
          hint: '50',
          prefixIcon: Icons.inventory_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Nhập tồn kho';
            final stock = int.tryParse(v.trim());
            if (stock == null) return 'Phải là số';
            if (stock < 0) return 'Khôngđược âm';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescSection() {
    return _buildInputField(
      controller: _descCtrl,
      hint: 'Nhập mô tả chi tiết về sản phẩm...',
      prefixIcon: Icons.notes,
      maxLines: 5,
      validator: (v) =>
          v == null || v.trim().isEmpty ? 'Nhập mô tả sản phẩm' : null,
    );
  }

  Widget _buildTagSection({
    required TextEditingController controller,
    required List<String> tags,
    required String hint,
    required VoidCallback onAdd,
    required void Function(String) onRemove,
    required Color tagColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input + nút thêm
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: _decoration(hint, null),
                style: const TextStyle(fontSize: 14, color: _textDark),
                onSubmitted: (_) => onAdd(),
                textInputAction: TextInputAction.done,
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4361EE), Color(0xFF7B2FBE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: _primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3))
                  ],
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags
                .map((tag) => _buildTag(tag, tagColor, () => onRemove(tag)))
                .toList(),
          ),
        ] else ...[
          const SizedBox(height: 10),
          Text(
            'Chưa có mục nào — nhập và nhấn +để thêm',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400, fontStyle: FontStyle.italic),
          ),
        ],
      ],
    );
  }

  Widget _buildTag(String label, Color color, VoidCallback onRemove) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.only(left: 12, right: 6, top: 6, bottom: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.12), color.withValues(alpha: 0.06)],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 11, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -4)),
        ],
      ),
      child: Row(
        children: [
          // Nút Hủy
          Expanded(
            flex: 2,
            child: OutlinedButton(
              onPressed: _isSaving ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: _textMid,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Hủy',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ),
          ),
          const SizedBox(width: 12),
          // Nút Lưu
          Expanded(
            flex: 5,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: _isSaving
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFF4361EE), Color(0xFF7B2FBE)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                color: _isSaving ? Colors.grey.shade300 : null,
                borderRadius: BorderRadius.circular(14),
                boxShadow: _isSaving
                    ? []
                    : [
                        BoxShadow(
                            color: _primary.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4))
                      ],
              ),
              child: ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isEditing ? Icons.save_outlined : Icons.add_circle_outline,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isEditing ? 'Cập nhật' : 'Thêm sản phẩm',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Input helpers ──────────────────────────────────────────────────────────

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: _textMid,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    String? label,
    required String hint,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          _fieldLabel(label),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          validator: validator,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 14, color: _textDark),
          decoration: _decoration(hint, prefixIcon),
        ),
      ],
    );
  }

  InputDecoration _decoration(String hint, IconData? icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
      prefixIcon: icon != null ? Icon(icon, size: 18, color: _textMid) : null,
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primary, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.8),
      ),
    );
  }
}
