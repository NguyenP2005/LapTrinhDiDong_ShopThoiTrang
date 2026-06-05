import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/payment_viewmodel.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../viewmodels/order_viewmodel.dart';
import '../viewmodels/coupon_viewmodel.dart';
import '../models/order_model.dart';
import '../models/order_item_model.dart';
import '../models/payment_model.dart';
import 'payment_success_screen.dart';
import 'dart:math';

class PaymentScreen extends StatefulWidget {
  final String userId;
  final String addressId;
  final double totalAmount;
  final double shippingFee;
  final double discount; // Số tiền giảm từ mã khuyến mãi

  const PaymentScreen({
    super.key,
    required this.userId,
    required this.addressId,
    required this.totalAmount,
    required this.shippingFee,
    this.discount = 0,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _accountController = TextEditingController();

  @override
  void dispose() {
    _accountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paymentVM = Provider.of<PaymentViewModel>(context);
    final finalAmount =
        widget.totalAmount + widget.shippingFee - widget.discount;

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Thanh toán',
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
                  const SizedBox(height: 16),

                  // Phương thức thanh toán
                  _buildPaymentMethods(paymentVM),

                  const SizedBox(height: 16),

                  // Thông tin ngân hàng (nếu chọn chuyển khoản)
                  if (paymentVM.selectedMethod == 'BANK_TRANSFER')
                    _buildBankInfo(paymentVM),

                  const SizedBox(height: 16),

                  // Thông tin đơn hàng
                  _buildOrderSummary(finalAmount),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Nút xác nhận
          _buildBottomButton(paymentVM, finalAmount),
        ],
      ),
    );
  }

  // Chọn phương thức thanh toán
  Widget _buildPaymentMethods(PaymentViewModel paymentVM) {
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
            'Phương thức thanh toán',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // COD
          _buildPaymentOption(
            paymentVM: paymentVM,
            method: 'COD',
            title: 'Thanh toán khi nhận hàng (COD)',
            icon: Icons.money,
          ),

          const SizedBox(height: 12),

          // Chuyển khoản
          _buildPaymentOption(
            paymentVM: paymentVM,
            method: 'BANK_TRANSFER',
            title: 'Chuyển khoản ngân hàng',
            icon: Icons.account_balance,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required PaymentViewModel paymentVM,
    required String method,
    required String title,
    required IconData icon,
  }) {
    final isSelected = paymentVM.selectedMethod == method;

    return GestureDetector(
      onTap: () => paymentVM.selectPaymentMethod(method),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xff8E2DE2).withOpacity(0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xff8E2DE2) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xff8E2DE2) : Colors.grey,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? const Color(0xff8E2DE2) : Colors.black,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xff8E2DE2)),
          ],
        ),
      ),
    );
  }

  // Thông tin ngân hàng
  Widget _buildBankInfo(PaymentViewModel paymentVM) {
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
            'Thông tin chuyển khoản',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Dropdown chọn ngân hàng
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Chọn ngân hàng',
              prefixIcon: const Icon(
                Icons.account_balance,
                color: Color(0xff8E2DE2),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            value: paymentVM.selectedBank,
            items: paymentVM.banks
                .map(
                  (bank) => DropdownMenuItem(
                    value: bank['name'],
                    child: Text(bank['name']!),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                paymentVM.selectBank(value);
              }
            },
          ),

          const SizedBox(height: 16),

          // Nhập số tài khoản
          TextFormField(
            controller: _accountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Số tài khoản',
              hintText: 'Nhập số tài khoản',
              prefixIcon: const Icon(
                Icons.credit_card,
                color: Color(0xff8E2DE2),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) => paymentVM.setAccountNumber(value),
          ),

          const SizedBox(height: 16),

          // Số tiền cần chuyển
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xff8E2DE2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Số tiền cần chuyển:',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${(widget.totalAmount + widget.shippingFee - widget.discount).toStringAsFixed(0)} đ',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff8E2DE2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Thông tin đơn hàng
  Widget _buildOrderSummary(double finalAmount) {
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
            'Thông tin đơn hàng',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Tổng tiền hàng', widget.totalAmount),
          const SizedBox(height: 8),
          _buildSummaryRow('Phí vận chuyển', widget.shippingFee),
          if (widget.discount > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow('Giảm giá', widget.discount, isDiscount: true),
          ],
          const Divider(height: 24),
          _buildSummaryRow('Tổng thanh toán', finalAmount, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount, {
    bool isTotal = false,
    bool isDiscount = false,
  }) {
    final prefix = isDiscount ? '-' : '';
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
          '$prefix${amount.toStringAsFixed(0)} đ',
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

  // Nút xác nhận thanh toán
  Widget _buildBottomButton(PaymentViewModel paymentVM, double finalAmount) {
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
          onPressed: paymentVM.isLoading
              ? null
              : () => _handlePayment(paymentVM, finalAmount),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff8E2DE2),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: paymentVM.isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Xác nhận thanh toán',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  Future<void> _handlePayment(
    PaymentViewModel paymentVM,
    double finalAmount,
  ) async {
    // Validate dữ liệu
    if (!paymentVM.validatePaymentData()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(paymentVM.errorMessage ?? 'Dữ liệu không hợp lệ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Nếu chọn chuyển khoản, hiển thị dialog OTP
    if (paymentVM.selectedMethod == 'BANK_TRANSFER') {
      final otpConfirmed = await _showOtpDialog();
      if (!otpConfirmed) return;
    }

    // Tạo đơn hàng
    await _createOrderAndPayment(paymentVM, finalAmount);
  }

  Future<bool> _showOtpDialog() async {
    // 1. Tạo mã OTP ngẫu nhiên 6 chữ số
    final String generatedOtp = (100000 + Random().nextInt(900000)).toString();

    // 2. Giả lập gửi SMS bằng SnackBar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '📱 TIN NHẮN: Mã OTP xác nhận thanh toán của bạn là: $generatedOtp',
          ),
          duration: const Duration(seconds: 10), // Để lâu xíu cho user kịp nhìn
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    final otpController = TextEditingController();
    bool confirmed = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận OTP'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Vui lòng kiểm tra tin nhắn và nhập mã OTP (6 số) để xác nhận.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8),
              decoration: InputDecoration(
                hintText: '------',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              confirmed = false;
              Navigator.pop(context);
            },
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              // 3. Kiểm tra logic OTP có khớp không
              if (otpController.text == generatedOtp) {
                confirmed = true;
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mã OTP không chính xác! Vui lòng thử lại.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff8E2DE2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Xác nhận',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    otpController.dispose();
    return confirmed;
  }

  Future<void> _createOrderAndPayment(
    PaymentViewModel paymentVM,
    double finalAmount,
  ) async {
    final cartVM = Provider.of<CartViewModel>(context, listen: false);
    final orderVM = Provider.of<OrderViewModel>(context, listen: false);

    // Tạo order
    final newOrder = OrderModel(
      id: '',
      userId: widget.userId,
      addressId: widget.addressId,
      totalAmount: widget.totalAmount,
      shippingFee: widget.shippingFee,
      finalAmount: finalAmount,
      status: 'pending',
      paymentMethod: paymentVM.selectedMethod,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    // Tạo order items từ giỏ hàng
    final orderItems = cartVM.items
        .map(
          (item) => OrderItemModel(
            id: '',
            orderId: '',
            productId: item.productId,
            productName: item.name,
            productImage: item.image,
            quantity: item.quantity,
            price: item.price,
          ),
        )
        .toList();

    // Gọi API tạo order
    final createdOrder = await orderVM.createOrder(newOrder, orderItems);

    if (createdOrder == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Có lỗi khi tạo đơn hàng'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Tạo payment
    final newPayment = PaymentModel(
      id: '',
      orderId: createdOrder.id,
      method: paymentVM.selectedMethod,
      amount: finalAmount,
      status: 'success',
      bankName: paymentVM.selectedBank,
      accountNumber: paymentVM.accountNumber,
      paidAt: DateTime.now().toIso8601String(),
    );

    await paymentVM.createPayment(newPayment);

    // Xóa giỏ hàng
    for (var item in cartVM.items) {
      await cartVM.removeFromCart(item.productId);
    }

    // Gỡ mã khuyến mãi đã dùng (tránh áp nhầm cho đơn sau)
    if (mounted) {
      Provider.of<CouponViewModel>(context, listen: false).removeCoupon();
    }

    if (!mounted) return;

    // Chuyển đến màn hình thành công
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentSuccessScreen(orderId: createdOrder.id),
      ),
    );
  }
}
