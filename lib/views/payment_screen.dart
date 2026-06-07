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
import 'dart:async';
import 'dart:math';

class PaymentScreen extends StatefulWidget {
  final String userId;
  final String addressId;
  final double totalAmount;
  final double shippingFee;
  final double discount;

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
                  _buildPaymentMethods(paymentVM),
                  const SizedBox(height: 16),
                  if (paymentVM.selectedMethod == 'BANK_TRANSFER')
                    _buildBankInfo(paymentVM),
                  const SizedBox(height: 16),
                  _buildOrderSummary(finalAmount),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          _buildBottomButton(paymentVM, finalAmount),
        ],
      ),
    );
  }

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
          _buildPaymentOption(
            paymentVM: paymentVM,
            method: 'COD',
            title: 'Thanh toán khi nhận hàng (COD)',
            icon: Icons.money,
          ),
          const SizedBox(height: 12),
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
              if (value != null) paymentVM.selectBank(value);
            },
          ),
          const SizedBox(height: 16),
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
    if (!paymentVM.validatePaymentData()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(paymentVM.errorMessage ?? 'Dữ liệu không hợp lệ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (paymentVM.selectedMethod == 'BANK_TRANSFER') {
      final otpConfirmed = await _showOtpDialog();
      if (!otpConfirmed) return;
    }

    await _createOrderAndPayment(paymentVM, finalAmount);
  }

  Future<bool> _showOtpDialog() async {
    final String generatedOtp = (100000 + Random().nextInt(900000)).toString();

    if (!mounted) return false;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _OtpDialog(
        otp: generatedOtp,
        label: 'Xác nhận chuyển khoản',
        description: 'Mã OTP xác nhận chuyển khoản ngân hàng',
      ),
    );

    return confirmed == true;
  }

  Future<void> _createOrderAndPayment(
    PaymentViewModel paymentVM,
    double finalAmount,
  ) async {
    final cartVM = Provider.of<CartViewModel>(context, listen: false);
    final orderVM = Provider.of<OrderViewModel>(context, listen: false);

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
    await cartVM.clearCart();

    // Gỡ mã khuyến mãi đã dùng (tránh áp nhầm cho đơn sau)
    if (mounted) {
      Provider.of<CouponViewModel>(context, listen: false).removeCoupon();
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentSuccessScreen(orderId: createdOrder.id),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Widget OTP Dialog độc lập — Timer chỉ tạo MỘT LẦN trong initState
// ═══════════════════════════════════════════════════════════════════════════════
class _OtpDialog extends StatefulWidget {
  final String otp;
  final String label;
  final String description;

  const _OtpDialog({
    required this.otp,
    required this.label,
    required this.description,
  });

  @override
  State<_OtpDialog> createState() => _OtpDialogState();
}

class _OtpDialogState extends State<_OtpDialog> {
  late Timer _timer;
  int _remainingSeconds = 120;
  final TextEditingController _otpController = TextEditingController();
  String? _errorText;
  bool _otpVisible = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    final isExpired = _remainingSeconds == 0;

    Color timerColor = Colors.blue[700]!;
    Color timerBg = Colors.blue[50]!;
    if (isExpired) {
      timerColor = Colors.red;
      timerBg = Colors.red.shade50;
    } else if (_remainingSeconds <= 30) {
      timerColor = Colors.orange[800]!;
      timerBg = Colors.orange.shade50;
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xff8E2DE2).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_open_outlined,
                    color: Color(0xff8E2DE2),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.label,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Thông tin
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.sms, color: Colors.green[700], size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.description,
                      style: TextStyle(fontSize: 13, color: Colors.green[800]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Ô hiển thị mã OTP (mô phỏng SMS) — ẩn/hiện
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.phone_android,
                        color: Colors.amber[800],
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '📱 Tin nhắn SMS (mô phỏng):',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber[900],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _otpVisible
                              ? 'Mã OTP: ${widget.otp}'
                              : 'Mã OTP: ••••••',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[900],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _otpVisible = !_otpVisible),
                        child: Icon(
                          _otpVisible ? Icons.visibility_off : Icons.visibility,
                          color: Colors.amber[800],
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Bộ đếm ngược
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: timerBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timer_outlined, size: 18, color: timerColor),
                  const SizedBox(width: 6),
                  Text(
                    isExpired
                        ? 'OTP đã hết hạn!'
                        : 'Còn lại: $minutes:$seconds',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: timerColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // TextField nhập OTP
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              enabled: !isExpired,
              style: const TextStyle(
                fontSize: 26,
                letterSpacing: 8,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: '------',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 22,
                  letterSpacing: 6,
                ),
                counterText: '',
                errorText: _errorText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xff8E2DE2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xff8E2DE2),
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: isExpired ? Colors.grey[100] : Colors.white,
              ),
              onChanged: (_) {
                if (_errorText != null) setState(() => _errorText = null);
              },
            ),

            if (isExpired)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Mã OTP đã hết hạn. Vui lòng quay lại và thử lại.',
                  style: TextStyle(color: Colors.red[700], fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 20),

            // Nút hành động
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      side: BorderSide(color: Colors.grey[300]!),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Hủy'),
                  ),
                ),
                if (!isExpired) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_otpController.text.trim() == widget.otp) {
                          Navigator.pop(context, true);
                        } else {
                          setState(() => _errorText = 'Mã OTP không đúng!');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff8E2DE2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Xác nhận',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
