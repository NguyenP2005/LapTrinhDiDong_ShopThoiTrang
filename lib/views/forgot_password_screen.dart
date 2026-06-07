import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
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

  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset('assets/images/PC_TSHIRT.mp4')
      ..initialize().then((_) {
        _videoController.setVolume(0.0);
        _videoController.setLooping(true);
        _videoController.play();
        setState(() {});
      });
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut
    );
  }

  @override
  void dispose() {
    _videoController.dispose();
    _pageController.dispose();
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // Đổi icon mũi tên sang trắng
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // LỚP VIDEO NỀN
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
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.55)),
          ),

          // LUỒNG PAGEVIEW CỦA EM ĐƯỢC GIỮ NGUYÊN
          SafeArea(
            child: Column(
              children: [
                // Logo Brevk cho đẹp đồng bộ
                Text(
                  'Brevk',
                  style: GoogleFonts.pacifico(
                    fontSize: 48, color: Colors.white, fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildEmailStep(vm),
                      _buildOTPStep(vm),
                      _buildNewPasswordStep(vm),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // BƯỚC 1: NHẬP EMAIL
  Widget _buildEmailStep(AuthViewModel vm) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Form(
        key: _formKeyEmail,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text('Forgot Password', style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('Enter your email address to receive a verification code.', style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 40),
            _buildInputField(
              hint: 'name@example.com',
              icon: Icons.email_outlined,
              controller: _emailCtrl,
              validator: (val) {
                if (val == null || val.isEmpty) return 'Vui lòng nhập Email';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) return 'Email không đúng định dạng';
                return null;
              }
            ),
            if (vm.errorMessage != null)
              Padding(padding: const EdgeInsets.only(top: 12), child: Text(vm.errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 13))),
            const SizedBox(height: 40),
            _buildMinimalButton(
              text: 'SEND OTP',
              isLoading: vm.isLoading,
              onPressed: () async {
                if (_formKeyEmail.currentState!.validate()) {
                  final ok = await vm.checkEmailForReset(_emailCtrl.text);
                  if (ok && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('📱 TIN NHẮN SMS: Mã OTP của bạn là: ${vm.generatedOtp}'),
                        backgroundColor: Colors.green[700], duration: const Duration(seconds: 10), behavior: SnackBarBehavior.floating,
                      ),
                    );
                    _nextPage();
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // BƯỚC 2: XÁC THỰC MÃ OTP
  Widget _buildOTPStep(AuthViewModel vm) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Form(
        key: _formKeyOTP,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text('Verify OTP', style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('We sent a verification code to ${_emailCtrl.text}', style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 40),
            _buildInputField(
              hint: 'Enter 6-digit code',
              icon: Icons.lock_open_outlined,
              controller: _otpCtrl,
              keyboardType: TextInputType.number,
              validator: (val) {
                if (val == null || val.isEmpty) return 'Vui lòng nhập mã OTP';
                if (val.trim().length != 6) return 'Mã OTP phải có đúng 6 chữ số';
                return null;
              }
            ),
            if (vm.errorMessage != null)
              Padding(padding: const EdgeInsets.only(top: 12), child: Text(vm.errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 13))),
            const SizedBox(height: 40),
            _buildMinimalButton(
              text: 'VERIFY CODE',
              isLoading: false,
              onPressed: () {
                if (_formKeyOTP.currentState!.validate()) {
                  if (vm.verifyOTP(_otpCtrl.text)) _nextPage();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // BƯỚC 3: THIẾT LẬP MẬT KHẨU MỚI
  Widget _buildNewPasswordStep(AuthViewModel vm) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Form(
        key: _formKeyPass,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text('Reset Password', style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('Create a new, secure password for your account.', style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 40),
            _buildInputField(
              hint: 'New Password',
              icon: Icons.lock_outline,
              controller: _passCtrl,
              obscure: true,
              validator: (val) {
                if (val == null || val.isEmpty) return 'Vui lòng nhập mật khẩu mới';
                if (val.length < 6) return 'Mật khẩu phải từ 6 ký tự trở lên';
                return null;
              }
            ),
            const SizedBox(height: 16),
            _buildInputField(
              hint: 'Confirm Password',
              icon: Icons.done_all_outlined,
              controller: _confirmPassCtrl,
              obscure: true,
              validator: (val) {
                if (val == null || val.isEmpty) return 'Vui lòng xác nhận lại mật khẩu';
                if (val != _passCtrl.text) return 'Mật khẩu xác nhận không khớp!';
                return null;
              }
            ),
            if (vm.errorMessage != null)
              Padding(padding: const EdgeInsets.only(top: 12), child: Text(vm.errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 13))),
            const SizedBox(height: 40),
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
                    Navigator.pop(context); // Trở về Login
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Khung Input bo tròn chuẩn Brevk
  Widget _buildInputField({required String hint, required IconData icon, required TextEditingController controller, bool obscure = false, TextInputType? keyboardType, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      keyboardType: keyboardType,
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

  // Nút nhấn Đen Minimalist
  Widget _buildMinimalButton({required String text, required VoidCallback onPressed, required bool isLoading}) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // Bo góc như Login
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
      ),
    );
  }
}