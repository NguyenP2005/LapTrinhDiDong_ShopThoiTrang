import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final phoneCtrl = TextEditingController(); // THÊM CONTROLLER CHO SĐT
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();
  bool isAgreed = false;

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AuthViewModel>(context);
    const primaryBlue = Color(0xFF2344D1);

    return Scaffold(
      backgroundColor: const Color(0xFFE5E5E5),
      body: Stack(
        children: [
          Positioned(bottom: 0, left: 0, right: 0, height: MediaQuery.of(context).size.height * 0.4, child: Container(color: primaryBlue)),
          Positioned.fill(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container(color: Colors.transparent))),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 30),
                  const Text('Sign Up', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('SIGN UP', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 30),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.black.withOpacity(0.05)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 2)],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildInputField(
                            label: 'Name', hint: 'Full Name', icon: Icons.person_outline, controller: nameCtrl,
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Vui lòng nhập họ tên';
                              if (val.length < 3) return 'Tên phải có ít nhất 3 ký tự';
                              // VALIDATE KHÔNG ĐƯỢC CHỨA SỐ
                              if (RegExp(r'[0-9]').hasMatch(val)) return 'Tên không được chứa chữ số';
                              return null;
                            }
                          ),
                          _buildInputField(
                            label: 'Phone Number', hint: 'Enter Phone Number', icon: Icons.phone_outlined, controller: phoneCtrl,
                            keyboardType: TextInputType.phone, // Hiện bàn phím số
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Vui lòng nhập số điện thoại';
                              // VALIDATE SĐT VN: Bắt đầu bằng 0, tổng cộng 10 số
                              if (!RegExp(r'^(0)[0-9]{9}$').hasMatch(val)) return 'Số điện thoại không hợp lệ (10 số)';
                              return null;
                            }
                          ),
                          _buildInputField(
                            label: 'Email Address', hint: 'Enter Email', icon: Icons.email_outlined, controller: emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Vui lòng nhập email';
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) return 'Định dạng email không hợp lệ';
                              return null;
                            }
                          ),
                          _buildInputField(
                            label: 'Password', hint: 'Password', icon: Icons.lock_outline, controller: passCtrl, obscure: true,
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Vui lòng nhập mật khẩu';
                              if (val.length < 8) return 'Mật khẩu phải >= 8 ký tự';
                              if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[A-Za-z\d@$!%*?&]').hasMatch(val)) {
                                return 'Cần có chữ hoa, thường và số';
                              }
                              return null;
                            }
                          ),
                          _buildInputField(
                            label: 'Confirm Password', hint: 'Confirm Password', icon: Icons.lock_outline, controller: confirmPassCtrl, obscure: true,
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Vui lòng xác nhận mật khẩu';
                              if (val != passCtrl.text) return 'Mật khẩu nhập lại không khớp!';
                              return null;
                            }
                          ),

                          Row(
                            children: [
                              Checkbox(value: isAgreed, activeColor: primaryBlue, onChanged: (val) => setState(() => isAgreed = val ?? false)),
                              const Expanded(child: Text('I agree with terms and privacy policy.', style: TextStyle(color: Colors.grey, fontSize: 13))),
                            ],
                          ),

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
                                onPressed: isAgreed ? () async {
                                  if (_formKey.currentState!.validate()) {
                                    // TRUYỀN THÊM SĐT VÀO HÀM REGISTER
                                    final ok = await vm.register(nameCtrl.text, phoneCtrl.text, emailCtrl.text, passCtrl.text);
                                    if (!mounted) return;
                                    if (ok) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng ký thành công!')));
                                    }
                                  }
                                } : null,
                                child: const Text('SIGN UP', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? ", style: TextStyle(color: Colors.grey)),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text('Login', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label, required String hint, required IconData icon,
    required TextEditingController controller, bool obscure = false,
    String? Function(String?)? validator, TextInputType? keyboardType
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF616161), fontSize: 13)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
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
}