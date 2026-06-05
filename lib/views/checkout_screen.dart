import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../viewmodels/address_viewmodel.dart';
import '../viewmodels/coupon_viewmodel.dart';
import '../models/address_model.dart';
import '../models/coupon_model.dart';
import 'add_address_screen.dart';
import 'payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final String userId; // Truyền từ màn hình trước

  const CheckoutScreen({super.key, required this.userId});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final double shippingFee = 30000; // Phí ship cố định
  final TextEditingController _couponController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<AddressViewModel>(
        context,
        listen: false,
      ).loadAddresses(widget.userId);
      // Tải danh sách mã khuyến mãi
      Provider.of<CouponViewModel>(context, listen: false).loadCoupons();
    });
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartVM = Provider.of<CartViewModel>(context);
    final addressVM = Provider.of<AddressViewModel>(context);

    // Kiểm tra giỏ hàng trống
    if (cartVM.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Đặt hàng'),
          backgroundColor: const Color(0xff8E2DE2),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Giỏ hàng trống')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Đặt hàng',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff8E2DE2),
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Phần địa chỉ giao hàng
                  _buildAddressSection(addressVM),

                  const SizedBox(height: 12),

                  // Danh sách sản phẩm
                  _buildProductList(cartVM),

                  const SizedBox(height: 12),

                  // Mã khuyến mãi
                  _buildCouponSection(cartVM),

                  const SizedBox(height: 12),

                  // Phần tổng tiền
                  _buildPriceSummary(cartVM),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Nút tiếp tục
          _buildBottomButton(addressVM, cartVM),
        ],
      ),
    );
  }

  // Phần địa chỉ giao hàng
  Widget _buildAddressSection(AddressViewModel addressVM) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xff8E2DE2), size: 24),
              const SizedBox(width: 8),
              const Text(
                'Địa chỉ giao hàng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (addressVM.addresses.isNotEmpty)
                TextButton(
                  onPressed: () => _showAddressListDialog(addressVM),
                  child: const Text(
                    'Thay đổi',
                    style: TextStyle(color: Color(0xff8E2DE2)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          if (addressVM.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (addressVM.selectedAddress != null)
            _buildAddressCard(addressVM.selectedAddress!)
          else
            _buildNoAddressCard(),
        ],
      ),
    );
  }

  Widget _buildAddressCard(AddressModel address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              address.receiverName,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                address.phone,
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          address.address,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildNoAddressCard() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddAddressScreen(userId: widget.userId),
          ),
        );
        if (result == true) {
          Provider.of<AddressViewModel>(
            context,
            listen: false,
          ).loadAddresses(widget.userId);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xff8E2DE2), width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Color(0xff8E2DE2)),
            SizedBox(width: 8),
            Text(
              'Thêm địa chỉ giao hàng',
              style: TextStyle(
                color: Color(0xff8E2DE2),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Danh sách sản phẩm
  Widget _buildProductList(CartViewModel cartVM) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sản phẩm đã chọn',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...cartVM.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildImage(item.image, 60),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'x${item.quantity}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${item.price.toStringAsFixed(0)} đ',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff8E2DE2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────── Mã khuyến mãi ───────────
  Widget _buildCouponSection(CartViewModel cartVM) {
    final couponVM = Provider.of<CouponViewModel>(context);
    final orderAmount = cartVM.totalPrice;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_offer, color: Color(0xff8E2DE2), size: 22),
              const SizedBox(width: 8),
              const Text(
                'Mã khuyến mãi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Nếu đã áp mã -> hiện thẻ mã đang dùng + nút gỡ
          if (couponVM.appliedCoupon != null)
            _buildAppliedCoupon(couponVM.appliedCoupon!, couponVM)
          else ...[
            // Ô nhập mã + nút áp dụng
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _couponController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Nhập mã giảm giá',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: couponVM.isLoading
                      ? null
                      : () => _applyCouponCode(couponVM, orderAmount),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff8E2DE2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Áp dụng'),
                ),
              ],
            ),

            // Báo lỗi mã (nếu có)
            if (couponVM.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  couponVM.errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),

            // Danh sách mã gợi ý
            if (couponVM.availableCoupons.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                'Mã có thể dùng:',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              ...couponVM.availableCoupons.map(
                (c) => _buildCouponSuggestion(c, couponVM, orderAmount),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildAppliedCoupon(CouponModel coupon, CouponViewModel couponVM) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green, width: 1.2),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coupon.code,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  coupon.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              couponVM.removeCoupon();
              _couponController.clear();
            },
            child: const Text('Gỡ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponSuggestion(
    CouponModel coupon,
    CouponViewModel couponVM,
    double orderAmount,
  ) {
    final eligible = orderAmount >= coupon.minOrder;
    return GestureDetector(
      onTap: eligible
          ? () {
              final ok = couponVM.applyCoupon(coupon, orderAmount);
              if (ok && mounted) {
                _couponController.text = coupon.code;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã áp mã ${coupon.code}'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }
          : null,
      child: Opacity(
        opacity: eligible ? 1 : 0.45,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xff8E2DE2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  coupon.code,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  coupon.description,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              if (eligible)
                const Icon(
                  Icons.add_circle_outline,
                  color: Color(0xff8E2DE2),
                  size: 20,
                )
              else
                const Icon(Icons.lock_outline, color: Colors.grey, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _applyCouponCode(
    CouponViewModel couponVM,
    double orderAmount,
  ) async {
    final code = _couponController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập mã khuyến mãi')),
      );
      return;
    }
    final ok = await couponVM.applyCode(code, orderAmount);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Áp mã thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Phần tổng tiền
  Widget _buildPriceSummary(CartViewModel cartVM) {
    final totalAmount = cartVM.totalPrice;
    final couponVM = Provider.of<CouponViewModel>(context);
    final discount = couponVM.discount;
    final finalAmount = totalAmount + shippingFee - discount;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          _buildPriceRow('Tổng tiền hàng', totalAmount),
          const SizedBox(height: 8),
          _buildPriceRow('Phí vận chuyển', shippingFee),
          // Hiển thị dòng giảm giá nếu có áp mã
          if (discount > 0) ...[
            const SizedBox(height: 8),
            _buildPriceRow('Giảm giá', -discount, isDiscount: true),
          ],
          const Divider(height: 24),
          _buildPriceRow('Tổng thanh toán', finalAmount, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount, {
    bool isTotal = false,
    bool isDiscount = false,
  }) {
    final prefix = isDiscount ? '-' : '';
    final displayAmount = amount.abs();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black : Colors.grey[600],
          ),
        ),
        Text(
          '$prefix${displayAmount.toStringAsFixed(0)} đ',
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: isTotal
                ? const Color(0xff8E2DE2)
                : isDiscount
                ? Colors.green
                : Colors.black,
          ),
        ),
      ],
    );
  }

  // Nút tiếp tục thanh toán
  Widget _buildBottomButton(AddressViewModel addressVM, CartViewModel cartVM) {
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
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: addressVM.selectedAddress == null
              ? null
              : () {
                  // Lấy số tiền giảm từ coupon đang áp
                  final discount = Provider.of<CouponViewModel>(
                    context,
                    listen: false,
                  ).discount;
                  // Chuyển sang màn hình thanh toán
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentScreen(
                        userId: widget.userId,
                        addressId: addressVM.selectedAddress!.id,
                        totalAmount: cartVM.totalPrice,
                        shippingFee: shippingFee,
                        discount: discount,
                      ),
                    ),
                  );
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff8E2DE2),
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey[300],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            'Tiếp tục',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // Dialog chọn địa chỉ
  void _showAddressListDialog(AddressViewModel addressVM) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Chọn địa chỉ giao hàng',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: addressVM.addresses.length,
                itemBuilder: (context, index) {
                  final address = addressVM.addresses[index];
                  final isSelected =
                      addressVM.selectedAddress?.id == address.id;

                  return GestureDetector(
                    onTap: () {
                      addressVM.selectAddress(address);
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xff8E2DE2).withOpacity(0.1)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xff8E2DE2)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      address.receiverName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      address.phone,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  address.address,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xff8E2DE2),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddAddressScreen(userId: widget.userId),
                      ),
                    );
                    if (result == true) {
                      addressVM.loadAddresses(widget.userId);
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm địa chỉ mới'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xff8E2DE2),
                    side: const BorderSide(color: Color(0xff8E2DE2)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String path, double size) {
    if (path.startsWith("http")) {
      return Image.network(
        path,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _errorImage(size),
      );
    }
    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _errorImage(size),
    );
  }

  Widget _errorImage(double size) {
    return Container(
      width: size,
      height: size,
      color: Colors.grey[300],
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }
}
