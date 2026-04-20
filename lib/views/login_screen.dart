import 'dart:ui';
import 'package:clothing_app/views/main.screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); // Key để kích hoạt Validate
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AuthViewModel>(context);
    const primaryBlue = Color(0xFF2344D1);

    return Scaffold(
      backgroundColor: const Color(0xFFE5E5E5),
      body: Stack(
        children: [
          Positioned(top: 0, left: 0, right: 0, height: MediaQuery.of(context).size.height * 0.4, child: Container(color: primaryBlue)),
          Positioned.fill(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container(color: Colors.transparent))),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  const Text('Log In', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('LOG IN', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 60),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.black.withOpacity(0.05)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 2)],
                    ),
                    // BỌC FORM VÀO ĐÂY
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildInputField(
                            label: 'Email', hint: 'Enter your Email', icon: Icons.email_outlined, controller: emailCtrl,
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Vui lòng nhập Email';
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) return 'Email không hợp lệ';
                              return null;
                            }
                          ),
                          _buildInputField(
                            label: 'Password', hint: 'Password', icon: Icons.lock_outline, controller: passCtrl, obscure: true,
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Vui lòng nhập mật khẩu';
                              return null;
                            }
                          ),

                          Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () {}, child: const Text('Forgot Password?', style: TextStyle(color: primaryBlue, fontSize: 13)))),

                          if (vm.errorMessage != null)
                            Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(vm.errorMessage!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center)),

                          const SizedBox(height: 20),

                          vm.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryBlue, foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0,
                                  ),
                                  onPressed: () async {
                                    // Chạy hàm validate, nếu đúng hết mới gọi API
                                    if (_formKey.currentState!.validate()) {
                                      final ok = await vm.login(emailCtrl.text, passCtrl.text);
                                      if (!mounted) return;
                                      if (ok) {
                                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
                                      }
                                    }
                                  },
                                  child: const Text('LOG IN', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  Row(
                    children: [
                      const Expanded(child: Divider(color: Colors.grey)),
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("or", style: TextStyle(color: Colors.grey))),
                      const Expanded(child: Divider(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(icon: Icons.facebook, color: Colors.blue), const SizedBox(width: 20),
                      _buildSocialButton(icon: Icons.apple, color: Colors.black), const SizedBox(width: 20),
                      _buildSocialButton(icon: Icons.g_mobiledata, color: Colors.red),
                    ],
                  ),
                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? ", style: TextStyle(color: Colors.grey)),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                        child: const Text('Sign Up', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
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

  // Thay TextField bằng TextFormField
  Widget _buildInputField({required String label, required String hint, required IconData icon, required TextEditingController controller, bool obscure = false, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF616161), fontSize: 13)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator, // Cắm validator vào đây
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey[400]),
            hintText: hint, hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF2344D1)), borderRadius: BorderRadius.circular(8)),
            errorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.red), borderRadius: BorderRadius.circular(8)),
            focusedErrorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.red), borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSocialButton({required IconData icon, required Color color}) {
    return Container(
      width: 50, height: 50,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
      child: IconButton(icon: Icon(icon, color: color), onPressed: () {}),
    );
  }
}