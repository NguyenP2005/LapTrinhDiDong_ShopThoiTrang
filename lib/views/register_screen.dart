import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();
  bool isAgreed = false;

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Stack(
        children: [
          // 1. Lớp Ambient Mesh Gradient mờ ảo chuyển động đồng bộ
          const _AnimatedBlurBackground(),

          // 2. Form nhập liệu Đăng ký
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign up to get started with your fashion store experience.',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 40),

                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildMinimalInput(
                          label: 'FULL NAME',
                          hint: 'Enter your full name',
                          icon: Icons.person_outline,
                          controller: nameCtrl,
                          validator: (val) {
                            if (val == null || val.isEmpty)
                              return 'Vui lòng nhập họ tên';
                            if (val.length < 3)
                              return 'Tên phải có ít nhất 3 ký tự';
                            if (RegExp(r'[0-9]').hasMatch(val))
                              return 'Tên không được chứa chữ số';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        _buildMinimalInput(
                          label: 'PHONE NUMBER',
                          hint: 'e.g., 0901234567',
                          icon: Icons.phone_outlined,
                          controller: phoneCtrl,
                          keyboardType: TextInputType.phone,
                          validator: (val) {
                            if (val == null || val.isEmpty)
                              return 'Vui lòng nhập số điện thoại';
                            if (!RegExp(r'^(0)[0-9]{9}$').hasMatch(val))
                              return 'Số điện thoại không hợp lệ (10 số)';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        _buildMinimalInput(
                          label: 'EMAIL ADDRESS',
                          hint: 'name@example.com',
                          icon: Icons.email_outlined,
                          controller: emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) {
                            if (val == null || val.isEmpty)
                              return 'Vui lòng nhập email';
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(val))
                              return 'Định dạng email không hợp lệ';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        _buildMinimalInput(
                          label: 'PASSWORD',
                          hint: 'Minimum 8 characters',
                          icon: Icons.lock_outline,
                          controller: passCtrl,
                          obscure: true,
                          validator: (val) {
                            if (val == null || val.isEmpty)
                              return 'Vui lòng nhập mật khẩu';
                            if (val.length < 8)
                              return 'Mật khẩu phải >= 8 ký tự';
                            if (!RegExp(
                              r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[A-Za-z\d@$!%*?&]',
                            ).hasMatch(val)) {
                              return 'Cần có chữ hoa, thường và số';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        _buildMinimalInput(
                          label: 'CONFIRM PASSWORD',
                          hint: 'Re-enter password',
                          icon: Icons.done_all_outlined,
                          controller: confirmPassCtrl,
                          obscure: true,
                          validator: (val) {
                            if (val == null || val.isEmpty)
                              return 'Vui lòng xác nhận mật khẩu';
                            if (val != passCtrl.text)
                              return 'Mật khẩu nhập lại không khớp!';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Checkbox Tối giản
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: isAgreed,
                                activeColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (val) =>
                                    setState(() => isAgreed = val ?? false),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'I agree with terms and privacy policy.',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),

                        if (vm.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(
                              vm.errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        const SizedBox(height: 32),

                        // Nút Đăng ký đồng bộ Đen tuyền phẳng sang trọng
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey[300],
                              disabledForegroundColor: Colors.grey[600],
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            onPressed: isAgreed && !vm.isLoading
                                ? () async {
                                    if (_formKey.currentState!.validate()) {
                                      final messenger = ScaffoldMessenger.of(
                                        context,
                                      );
                                      final navigator = Navigator.of(context);
                                      final ok = await vm.register(
                                        nameCtrl.text,
                                        phoneCtrl.text,
                                        emailCtrl.text,
                                        passCtrl.text,
                                      );
                                      if (!mounted) return;
                                      if (ok) {
                                        messenger.showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Đăng ký tài khoản mới thành công!',
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                        navigator.pop();
                                      }
                                    }
                                  }
                                : null,
                            child: vm.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'SIGN UP',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(color: Colors.black54),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          'LOG IN',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalInput({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool obscure = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(icon, color: Colors.black87),
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black12),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 2),
            ),
            errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
}

// Lớp hình nền Mesh Gradient đồng bộ
class _AnimatedBlurBackground extends StatefulWidget {
  const _AnimatedBlurBackground();

  @override
  State<_AnimatedBlurBackground> createState() =>
      _AnimatedBlurBackgroundState();
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
        _alignment1 = _alignment1 == const Alignment(-0.8, -0.8)
            ? const Alignment(0.8, -0.2)
            : const Alignment(-0.8, -0.8);
        _alignment2 = _alignment2 == const Alignment(0.8, 0.8)
            ? const Alignment(-0.8, 0.2)
            : const Alignment(0.8, 0.8);
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
            child: Container(
              width: 250,
              height: 250,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF8E2DE2),
              ),
            ),
          ),
          AnimatedAlign(
            alignment: _alignment2,
            duration: const Duration(seconds: 4),
            curve: Curves.easeInOut,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF4A00E0),
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(color: Colors.white.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }
}
