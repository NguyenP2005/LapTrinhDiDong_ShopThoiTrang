import 'package:flutter/material.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String orderId;

  const PaymentSuccessScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon th�nh c�ng
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 80,
                ),
              ),

              const SizedBox(height: 32),

              // Ti�ud?
              const Text(
                'Đặt hàng thành công ',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // M�don h�ng
              Text(
                'Mã đơn hàng: #$orderId',
                style: TextStyle(fontSize: 16, color: Color(0xFF4B5563)),
              ),

              const SizedBox(height: 8),

              // M� t?
              Text(
                'Cảm ơn bạn đã mua hàng!\nĐơn hàng của bạn đang được xử lý.',
                style: TextStyle(fontSize: 15, color: Color(0xFF4B5563)),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // N�t xemdon h�ng
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    // Quay về trang chủ ho?c trangdon h�ng
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4361EE),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Về trang chủ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // N�t xemdon h�ng (outline)
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: Navigate to My Orders screen
                    Navigator.popUntil(context, (route) => route.isFirst);
                    // Saud� navigated?n MyOrdersScreen
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4361EE),
                    side: const BorderSide(color: Color(0xFF4361EE), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Xem đơn hàng của tôi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
