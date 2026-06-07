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
                '�?t h�ng th�nh c�ng!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // M�don h�ng
              Text(
                'M�don h�ng: #$orderId',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),

              const SizedBox(height: 8),

              // M� t?
              Text(
                'Cảm ơn bạn đĐã� mua h�ng!\n�on h�ng c?a bạn đĐãangdu?c xử lý�.',
                style: TextStyle(fontSize: 15, color: Colors.black54),
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
                    'V? trang ch?',
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
                    'Xemdon h�ng c?a t�i',
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

