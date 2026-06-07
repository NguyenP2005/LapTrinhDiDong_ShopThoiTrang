import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
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
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    // Khởi tạo video nền
    _videoController = VideoPlayerController.asset('assets/images/PC_TSHIRT.mp4')
      ..initialize().then((_) {
        _videoController.setVolume(0.0);
        _videoController.setLooping(true);
        _videoController.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AuthViewModel>(context);

    return Scaffold(
      body: Stack(
        children: [
          // 1. LỚP VIDEO NỀN
          Positioned.fill(
            child: _videoController.value.isInitialized
                ? SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _videoController.value.size.width,
                        height: _videoController.value.size.height,
                        child: VideoPlayer(_videoController),
                      ),
                    ),
                  )
                : Container(color: const Color(0xFF1F1D2B)),
          ),

          // 2. LỚP PHỦ ĐEN MỜ ĐỂ NỔI BẬT CHỮ
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.55)),
          ),

          // 3. NỘI DUNG GIAO DIỆN
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // LOGO BREVK
                    Column(
                      children: [
                        Text(
                          'Brevk',
                          style: GoogleFonts.pacifico(
                            fontSize: 64,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            shadows: const [Shadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4))],
                          ),
                        ),
                        Text(
                          'A P P A R E L',
                          style: GoogleFonts.montserrat(
                            fontSize: 12, letterSpacing: 4, color: Colors.white, fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 60),

                    const Text(
                      'User Login',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w300),
                    ),
                    const SizedBox(height: 30),

                    // FORM NHẬP LIỆU
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildInputField(
                            hint: 'name@example.com',
                            icon: Icons.person_outline,
                            controller: emailCtrl,
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Vui lòng nhập Email';
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) return 'Email không hợp lệ';
                              return null;
                            }
                          ),
                          const SizedBox(height: 16),
                          _buildInputField(
                            hint: 'Password',
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
                              child: const Text('Forgot Password?', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                            )
                          ),

                          const SizedBox(height: 10),
                          if (vm.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(vm.errorMessage!, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold), textAlign: TextAlign.center)
                            ),

                          // NÚT ĐĂNG NHẬP MÀU ĐEN TUYỀN
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // Bo tròn viên thuốc
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
                                : const Text('LOGIN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
                            ),
                          ),

                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account? ", style: TextStyle(color: Colors.white70)),
                              GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                                child: const Text('SIGN UP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({required String hint, required IconData icon, required TextEditingController controller, bool obscure = false, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon, color: Colors.grey[400]),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}