import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final PageController _pageController = PageController();
  final _formKeyEmail = GlobalKey<FormState>();
  final _formKeyOTP = GlobalKey<FormState>();
  final _formKeyPass = GlobalKey<FormState>();

  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _otpCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _confirmPassCtrl = TextEditingController();

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Trong suốt để lộ nền phía dưới
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      extendBodyBehindAppBar: true, // Đẩy body lên sát mép trên màn hình
      body: Stack(
        children: [
          // 1. Lớp Ambient Mesh Gradient chuyển động mờ ảo đồng bộ
          const _AnimatedBlurBackground(),

          // 2. Lớp Luồng nội dung xử lý các bước
          SafeArea(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Khóa vuốt tay để tránh lỗi luồng nhập dữ liệu
              children: [
                _buildEmailStep(vm),
                _buildOTPStep(vm),
                _buildNewPasswordStep(vm),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // BƯỚC A: NHẬP EMAIL THU THẬP
  Widget _buildEmailStep(AuthViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKeyEmail,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text('Forgot Password', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            const Text('Enter your email address to receive a verification code.', style: TextStyle(color: Colors.black54, fontSize: 14)),
            const SizedBox(height: 40),
            _buildMinimalInput(
              label: 'EMAIL ADDRESS',
              hint: 'name@example.com',
              controller: _emailCtrl,
              icon: Icons.email_outlined,
              validator: (val) {
                if (val == null || val.isEmpty) return 'Vui lòng nhập Email';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) return 'Email không đúng định dạng';
                return null;
              }
            ),
            if (vm.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(vm.errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13))
              ),
            const Spacer(),
            _buildMinimalButton(
              text: 'SEND OTP',
              isLoading: vm.isLoading,
              onPressed: () async {
                if (_formKeyEmail.currentState!.validate()) {
                  final ok = await vm.checkEmailForReset(_emailCtrl.text);
                  if (ok && mounted) {
                    // Hiển thị mô phỏng tin nhắn SMS với mã OTP ngẫu nhiên
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.sms, color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '📱 TIN NHẮN SMS: Mã OTP đặt lại mật khẩu của bạn là: ${vm.generatedOtp}. Có hiệu lực trong 5 phút.',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.green[700],
                        duration: const Duration(seconds: 10),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    _nextPage();
                  }
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // BƯỚC B: XÁC THỰC MÃ OTP
  Widget _buildOTPStep(AuthViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKeyOTP,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text('Verify OTP', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Text('We sent a verification code to ${_emailCtrl.text}', style: const TextStyle(color: Colors.black54, fontSize: 14)),
            const SizedBox(height: 40),
            _buildMinimalInput(
              label: 'OTP CODE',
              hint: 'Nhập mã 6 chữ số từ tin nhắn SMS',
              controller: _otpCtrl,
              icon: Icons.lock_open_outlined,
              isNumber: true,
              validator: (val) {
                if (val == null || val.isEmpty) return 'Vui lòng nhập mã OTP';
                if (val.trim().length != 6) return 'Mã OTP phải có đúng 6 chữ số';
                return null;
              }
            ),
            if (vm.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(vm.errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13))
              ),
            const Spacer(),
            _buildMinimalButton(
              text: 'VERIFY CODE',
              isLoading: false,
              onPressed: () {
                if (_formKeyOTP.currentState!.validate()) {
                  if (vm.verifyOTP(_otpCtrl.text)) _nextPage();
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // BƯỚC C: THIẾT LẬP MẬT KHẨU MỚI
  Widget _buildNewPasswordStep(AuthViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKeyPass,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text('Reset Password', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            const Text('Create a new, secure password for your account.', style: TextStyle(color: Colors.black54, fontSize: 14)),
            const SizedBox(height: 40),
            _buildMinimalInput(
              label: 'NEW PASSWORD',
              hint: 'Minimum 6 characters',
              controller: _passCtrl,
              icon: Icons.lock_outline,
              isPassword: true,
              validator: (val) {
                if (val == null || val.isEmpty) return 'Vui lòng nhập mật khẩu mới';
                if (val.length < 6) return 'Mật khẩu phải từ 6 ký tự trở lên';
                return null;
              }
            ),
            const SizedBox(height: 24),
            _buildMinimalInput(
              label: 'CONFIRM NEW PASSWORD',
              hint: 'Re-enter your password',
              controller: _confirmPassCtrl,
              icon: Icons.done_all_outlined,
              isPassword: true,
              validator: (val) {
                if (val == null || val.isEmpty) return 'Vui lòng xác nhận lại mật khẩu';
                if (val != _passCtrl.text) return 'Mật khẩu xác nhận không khớp!';
                return null;
              }
            ),
            if (vm.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(vm.errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13))
              ),
            const Spacer(),
            _buildMinimalButton(
              text: 'RESET PASSWORD',
              isLoading: vm.isLoading,
              onPressed: () async {
                if (_formKeyPass.currentState!.validate()) {
                  final ok = await vm.resetPassword(_passCtrl.text);
                  if (ok && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đổi mật khẩu mới thành công!'), backgroundColor: Colors.green)
                    );
                    Navigator.pop(context); // Đẩy ngược về trang đăng nhập
                  }
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Tái sử dụng thiết kế Input trường phẳng gạch chân tối giản
  Widget _buildMinimalInput({required String label, required String hint, required TextEditingController controller, required IconData icon, bool isPassword = false, bool isNumber = false, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(icon, color: Colors.black87),
            border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2)),
            errorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
          ),
        ),
      ],
    );
  }

  // Nút nhấn chuẩn Solid Black phẳng không bóng đổ nặng
  Widget _buildMinimalButton({required String text, required VoidCallback onPressed, required bool isLoading}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
      ),
    );
  }
}

// Lớp hình nền mờ ảo Mesh Gradient chuyển động đồng bộ toàn app
class _AnimatedBlurBackground extends StatefulWidget {
  const _AnimatedBlurBackground();

  @override
  State<_AnimatedBlurBackground> createState() => _AnimatedBlurBackgroundState();
}

class _AnimatedBlurBackgroundState extends State<_AnimatedBlurBackground> {
  Alignment _alignment1 = const Alignment(-0.8, -0.8);
  Alignment _alignment2 = const Alignment(0.8, 0.8);
  late Timer _timer;

  @override
  void initState() {
    super.initState();
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
          AnimatedAlign(
            alignment: _alignment1,
            duration: const Duration(seconds: 4),
            curve: Curves.easeInOut,
            child: Container(width: 250, height: 250, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF8E2DE2))),
          ),
          AnimatedAlign(
            alignment: _alignment2,
            duration: const Duration(seconds: 4),
            curve: Curves.easeInOut,
            child: Container(width: 200, height: 200, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF4A00E0))),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(color: Colors.white.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}