import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Đảm bảo import đúng đường dẫn của em
import 'package:clothing_app/views/main.screen.dart';
import 'package:clothing_app/views/admin_dashboard_screen.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Lớp Background Gradient Mờ ảo chuyển động
          const _AnimatedBlurBackground(),

          // 2. Lớp Nội dung Đăng nhập (Foreground)
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  // Điểm nhấn thiết kế
                  Container(
                    width: 60, height: 60,
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.5),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Center(child: Icon(Icons.person_outline, size: 30, color: Colors.black)),
                  ),
                  const SizedBox(height: 24),
                  const Text('Welcome Back', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  const Text('Enter your details to access your account.', style: TextStyle(fontSize: 14, color: Colors.black54)),
                  const SizedBox(height: 40),

                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildMinimalInput(
                          label: 'EMAIL',
                          hint: 'name@example.com',
                          icon: Icons.email_outlined,
                          controller: emailCtrl,
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Vui lòng nhập Email';
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) return 'Email không hợp lệ';
                            return null;
                          }
                        ),
                        const SizedBox(height: 24),
                        _buildMinimalInput(
                          label: 'PASSWORD',
                          hint: 'Enter your password',
                          icon: Icons.lock_outline,
                          controller: passCtrl,
                          obscure: true,
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Vui lòng nhập mật khẩu';
                            return null;
                          }
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
                            },
                            child: const Text('Forgot Password?', style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)),
                          )
                        ),
                        if (vm.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(vm.errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13), textAlign: TextAlign.center)
                          ),

                        const SizedBox(height: 10),
                        // Nút Đăng nhập Tối giản (Đen tuyền)
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black, // Trả về màu đen tuyền Minimalist
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                            onPressed: vm.isLoading ? null : () async {
                              if (_formKey.currentState!.validate()) {
                                final ok = await vm.login(emailCtrl.text, passCtrl.text);
                                if (!mounted) return;
                                if (ok) {
                                  String role = vm.userRole ?? 'customer';
                                  if (role == 'admin') {
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
                                  } else {
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
                                  }
                                }
                              }
                            },
                            child: vm.isLoading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('LOG IN', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[300])),
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("OR", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                      Expanded(child: Divider(color: Colors.grey[300])),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(Icons.facebook, Colors.blue),
                      const SizedBox(width: 20),
                      _buildSocialButton(Icons.apple, Colors.black),
                      const SizedBox(width: 20),
                      _buildSocialButton(Icons.g_mobiledata, Colors.red),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? ", style: TextStyle(color: Colors.black54)),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                        child: const Text('SIGN UP', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalInput({required String label, required String hint, required IconData icon, required TextEditingController controller, bool obscure = false, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: const TextStyle(color: Colors.black, fontSize: 15),
          cursorColor: Colors.black,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(icon, color: Colors.black87),
            border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2)),
            focusedErrorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
            errorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
            errorStyle: const TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, Color color) {
    return Container(
      width: 50, height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4)
      ),
      child: IconButton(icon: Icon(icon, color: color), onPressed: () {}),
    );
  }
}

// ==============================================================
// WIDGET TẠO HIỆU ỨNG BACKGROUND MỜ ẢO CHUYỂN ĐỘNG (GLASSMORPHISM)
// ==============================================================
class _AnimatedBlurBackground extends StatefulWidget {
  const _AnimatedBlurBackground();

  @override
  State<_AnimatedBlurBackground> createState() => _AnimatedBlurBackgroundState();
}

class _AnimatedBlurBackgroundState extends State<_AnimatedBlurBackground> {
  // Điểm bắt đầu của 2 khối màu
  Alignment _alignment1 = const Alignment(-0.8, -0.8);
  Alignment _alignment2 = const Alignment(0.8, 0.8);
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Mỗi 3 giây sẽ thay đổi vị trí của khối màu 1 lần
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      setState(() {
        _alignment1 = _alignment1 == const Alignment(-0.8, -0.8) ? const Alignment(0.8, -0.2) : const Alignment(-0.8, -0.8);
        _alignment2 = _alignment2 == const Alignment(0.8, 0.8) ? const Alignment(-0.8, 0.2) : const Alignment(0.8, 0.8);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // Khối màu tím 1 chuyển động
          AnimatedAlign(
            alignment: _alignment1,
            duration: const Duration(seconds: 4),
            curve: Curves.easeInOut,
            child: Container(
              width: 250, height: 250,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF8E2DE2)),
            ),
          ),
          // Khối màu tím 2 chuyển động
          AnimatedAlign(
            alignment: _alignment2,
            duration: const Duration(seconds: 4),
            curve: Curves.easeInOut,
            child: Container(
              width: 200, height: 200,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF4A00E0)),
            ),
          ),
          // Lớp Kính Mờ (Tán sắc màu)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), // Chỉnh thông số này để tăng giảm độ mờ
            child: Container(color: Colors.white.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }
}