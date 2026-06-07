import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/coupon_model.dart';
import '../viewmodels/admin_coupon_viewmodel.dart';

class AdminCouponsScreen extends StatefulWidget {
  const AdminCouponsScreen({super.key});

  @override
  State<AdminCouponsScreen> createState() => _AdminCouponsScreenState();
}

class _AdminCouponsScreenState extends State<AdminCouponsScreen> {
  static const colorBackground = Color(0xFFF4F7FC);
  static const colorPrimary = Color(0xFF4361EE);
  static const colorTextPrimary = Color(0xFF2B2B2B);
  static const colorTextSecondary = Color(0xFF4B5563);

  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminCouponViewModel>().loadCoupons();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _formatValue(CouponModel c) {
    if (c.type == 'percent') {
      final cap = c.maxDiscount > 0
          ? ' (tối đa ${_fmtMoney(c.maxDiscount)})'
          : '';
      return 'Giảm ${c.value.toInt()}%$cap';
    }
    return 'Giảm ${_fmtMoney(c.value)}';
  }

  String _fmtMoney(double v) {
    if (v >= 1000) {
      return '${(v / 1000).toStringAsFixed(0)}k';
    }
    return v.toInt().toString();
  }

  Future<void> _openForm({CouponModel? existing}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<AdminCouponViewModel>(),
        child: _CouponFormSheet(existing: existing),
      ),
    );
  }

  Future<void> _confirmDelete(CouponModel coupon) async {
    final vm = context.read<AdminCouponViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: const Text(
          'Xác nhận xóa',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorTextPrimary),
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(color: colorTextSecondary, fontSize: 14, height: 1.5),
            children: [
              const TextSpan(text: 'Bạn có chắc muốn xóa mã\n'),
              TextSpan(
                text: '"${coupon.code}"',
                style: const TextStyle(fontWeight: FontWeight.bold, color: colorPrimary),
              ),
              const TextSpan(text: '?\nHành động này không thể hoàn tác.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      final success = await vm.deleteCoupon(coupon.id);
      messenger.showSnackBar(SnackBar(
        content: Text(success ? 'Đã xóa mã "${coupon.code}"' : (vm.errorMessage ?? 'Xóa thất bại')),
        backgroundColor: success ? colorPrimary : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBackground,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        backgroundColor: colorPrimary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Thêm mã', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: colorPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'QUẢN LÝ MÃ KHUYẾN MÃI',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => context.read<AdminCouponViewModel>().loadCoupons(),
          tooltip: 'Làm mới',
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: colorPrimary,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => context.read<AdminCouponViewModel>().setSearch(v),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Tìm mã hoặc mô tả...',
          hintStyle: const TextStyle(color: Colors.white70, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Colors.white70, size: 20),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70, size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    context.read<AdminCouponViewModel>().setSearch('');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.18),
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    return Consumer<AdminCouponViewModel>(
      builder: (_, vm, _) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator(color: colorPrimary));
        }
        if (vm.status == AdminCouponStatus.error) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off, size: 56, color: Color(0xFF9CA3AF)),
                  const SizedBox(height: 12),
                  Text(vm.errorMessage ?? 'Lỗi không xác định',
                      style: const TextStyle(color: colorTextSecondary),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: vm.loadCoupons,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorPrimary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        final list = vm.coupons;
        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.discount_outlined, size: 72, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                const Text('Chưa có mã khuyến mãi nào',
                    style: TextStyle(fontSize: 16, color: colorTextSecondary, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                const Text('Nhấn nút + để thêm mã mới',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
              ],
            ),
          );
        }
        return RefreshIndicator(
          color: colorPrimary,
          onRefresh: vm.loadCoupons,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _CouponCard(
              coupon: list[i],
              formatValue: _formatValue,
              onEdit: () => _openForm(existing: list[i]),
              onDelete: () => _confirmDelete(list[i]),
              onToggle: () => context.read<AdminCouponViewModel>().toggleActive(list[i]),
            ),
          ),
        );
      },
    );
  }
}

// ── Coupon Card ───────────────────────────────────────────────────────────────
class _CouponCard extends StatelessWidget {
  final CouponModel coupon;
  final String Function(CouponModel) formatValue;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const _CouponCard({
    required this.coupon,
    required this.formatValue,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  static const colorPrimary = Color(0xFF4361EE);
  static const colorTextSecondary = Color(0xFF4B5563);

  @override
  Widget build(BuildContext context) {
    final isActive = coupon.isActive;
    final activeColor = isActive ? colorPrimary : const Color(0xFF9CA3AF);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isActive ? colorPrimary.withValues(alpha: 0.25) : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon badge
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: activeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                coupon.type == 'percent' ? Icons.percent : Icons.currency_exchange,
                color: activeColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          coupon.code,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isActive ? const Color(0xFF1E293B) : const Color(0xFF9CA3AF),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      // Active badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: activeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isActive ? 'Đang hoạt động' : 'Tắt',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: activeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    coupon.description,
                    style: const TextStyle(fontSize: 13, color: colorTextSecondary, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.local_offer_outlined,
                        label: formatValue(coupon),
                        color: activeColor,
                      ),
                      const SizedBox(width: 6),
                      _InfoChip(
                        icon: Icons.shopping_bag_outlined,
                        label: 'Từ ${_fmtMoney(coupon.minOrder)}đ',
                        color: const Color(0xFF6B7280),
                      ),
                    ],
                  ),
                  if (coupon.expiresAt != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 12, color: Color(0xFF9CA3AF)),
                        const SizedBox(width: 4),
                        Text(
                          'HSD: ${coupon.expiresAt}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 4),
            // Action buttons
            Column(
              children: [
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'toggle') onToggle();
                    if (v == 'delete') onDelete();
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  icon: const Icon(Icons.more_vert, color: Color(0xFF6B7280), size: 20),
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        Icon(Icons.edit_outlined, size: 16, color: colorPrimary),
                        SizedBox(width: 8),
                        Text('Sửa', style: TextStyle(fontSize: 13)),
                      ]),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(children: [
                        Icon(
                          isActive ? Icons.toggle_off_outlined : Icons.toggle_on_outlined,
                          size: 16,
                          color: isActive ? const Color(0xFF6B7280) : Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isActive ? 'Tắt mã' : 'Bật mã',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ]),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete_outline, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Xóa', style: TextStyle(fontSize: 13, color: Colors.red)),
                      ]),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _fmtMoney(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(0)}tr';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}k';
    return v.toInt().toString();
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ── Create / Edit Form Sheet ──────────────────────────────────────────────────
class _CouponFormSheet extends StatefulWidget {
  final CouponModel? existing;
  const _CouponFormSheet({this.existing});

  @override
  State<_CouponFormSheet> createState() => _CouponFormSheetState();
}

class _CouponFormSheetState extends State<_CouponFormSheet> {
  static const colorPrimary = Color(0xFF4361EE);

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _valueCtrl;
  late TextEditingController _maxDiscCtrl;
  late TextEditingController _minOrderCtrl;
  late TextEditingController _expiresCtrl;
  String _type = 'percent';
  bool _isActive = true;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final c = widget.existing;
    _codeCtrl = TextEditingController(text: c?.code ?? '');
    _descCtrl = TextEditingController(text: c?.description ?? '');
    _valueCtrl = TextEditingController(text: c != null ? c.value.toInt().toString() : '');
    _maxDiscCtrl = TextEditingController(text: c != null ? c.maxDiscount.toInt().toString() : '0');
    _minOrderCtrl = TextEditingController(text: c != null ? c.minOrder.toInt().toString() : '0');
    _expiresCtrl = TextEditingController(text: c?.expiresAt ?? '');
    _type = c?.type ?? 'percent';
    _isActive = c?.isActive ?? true;
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _descCtrl.dispose();
    _valueCtrl.dispose();
    _maxDiscCtrl.dispose();
    _minOrderCtrl.dispose();
    _expiresCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final vm = context.read<AdminCouponViewModel>();
    final coupon = CouponModel(
      id: widget.existing?.id ?? '',
      code: _codeCtrl.text.trim().toUpperCase(),
      description: _descCtrl.text.trim(),
      type: _type,
      value: double.tryParse(_valueCtrl.text.trim()) ?? 0,
      maxDiscount: double.tryParse(_maxDiscCtrl.text.trim()) ?? 0,
      minOrder: double.tryParse(_minOrderCtrl.text.trim()) ?? 0,
      isActive: _isActive,
      expiresAt: _expiresCtrl.text.trim().isEmpty ? null : _expiresCtrl.text.trim(),
    );
    final success = _isEdit
        ? await vm.updateCoupon(coupon)
        : await vm.createCoupon(coupon);

    if (!mounted) return;
    setState(() => _saving = false);
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEdit ? 'Đã cập nhật mã "${coupon.code}"' : 'Đã thêm mã "${coupon.code}"'),
        backgroundColor: colorPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(vm.errorMessage ?? 'Có lỗi xảy ra'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomPad),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Title
              Text(
                _isEdit ? 'Sửa mã khuyến mãi' : 'Thêm mã khuyến mãi',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 20),
              // Code
              _buildField(
                controller: _codeCtrl,
                label: 'Mã giảm giá *',
                hint: 'VD: SALE20',
                inputFormatters: [UpperCaseTextFormatter()],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Vui lòng nhập mã';
                  if (v.trim().length < 3) return 'Mã phải có ít nhất 3 ký tự';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              // Description
              _buildField(
                controller: _descCtrl,
                label: 'Mô tả *',
                hint: 'Mô tả ngắn về mã khuyến mãi',
                maxLines: 2,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập mô tả' : null,
              ),
              const SizedBox(height: 14),
              // Type selector
              const Text('Loại giảm giá *',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
              const SizedBox(height: 8),
              Row(
                children: [
                  _TypeChip(
                    label: 'Phần trăm (%)',
                    selected: _type == 'percent',
                    onTap: () => setState(() => _type = 'percent'),
                  ),
                  const SizedBox(width: 10),
                  _TypeChip(
                    label: 'Số tiền cố định',
                    selected: _type == 'fixed',
                    onTap: () => setState(() => _type = 'fixed'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Value
              _buildField(
                controller: _valueCtrl,
                label: _type == 'percent' ? 'Phần trăm giảm (%) *' : 'Số tiền giảm (VNĐ) *',
                hint: _type == 'percent' ? 'VD: 10' : 'VD: 30000',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Vui lòng nhập giá trị';
                  final val = double.tryParse(v.trim());
                  if (val == null || val <= 0) return 'Giá trị phải lớn hơn 0';
                  if (_type == 'percent' && val > 100) return 'Phần trăm không được vượt quá 100%';
                  return null;
                },
              ),
              if (_type == 'percent') ...[
                const SizedBox(height: 14),
                _buildField(
                  controller: _maxDiscCtrl,
                  label: 'Giảm tối đa (VNĐ) — 0 = không giới hạn',
                  hint: 'VD: 100000',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ],
              const SizedBox(height: 14),
              _buildField(
                controller: _minOrderCtrl,
                label: 'Đơn hàng tối thiểu (VNĐ) — 0 = không giới hạn',
                hint: 'VD: 200000',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _expiresCtrl,
                label: 'Ngày hết hạn (tuỳ chọn)',
                hint: 'YYYY-MM-DD',
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                  return regex.hasMatch(v.trim()) ? null : 'Định dạng: YYYY-MM-DD';
                },
              ),
              const SizedBox(height: 14),
              // Active toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Kích hoạt mã',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                  Switch(
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                    activeThumbColor: colorPrimary,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Submit
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          _isEdit ? 'Cập nhật' : 'Thêm mã',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: colorPrimary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({required this.label, required this.selected, required this.onTap});

  static const colorPrimary = Color(0xFF4361EE);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? colorPrimary : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? colorPrimary : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}

// Converts text to UPPERCASE while typing
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
