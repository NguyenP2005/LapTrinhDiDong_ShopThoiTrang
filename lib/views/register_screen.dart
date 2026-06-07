import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
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

  @override
  void dispose() {
    _videoController.dispose();
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    confirmPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AuthViewModel>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
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
            child: Container(color: Colors.black.withValues(alpha: 0.55)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  const Text('Create Account', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  const Text('Sign up to get started with Brevk.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.white70)),
                  const SizedBox(height: 40),

                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildInputField(
                          hint: 'Full Name', icon: Icons.person_outline, controller: nameCtrl,
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Vui lòng nhập họ tên';
                            if (val.length < 3) return 'Tên phải có ít nhất 3 ký tự';
                            if (RegExp(r'[0-9]').hasMatch(val)) return 'Tên không được chứa chữ số';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          hint: 'Phone Number', icon: Icons.phone_outlined, controller: phoneCtrl, keyboardType: TextInputType.phone,
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Vui lòng nhập số điện thoại';
                            if (!RegExp(r'^(0)[0-9]{9}$').hasMatch(val)) return 'Số điện thoại không hợp lệ (10 số)';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          hint: 'Email Address', icon: Icons.email_outlined, controller: emailCtrl, keyboardType: TextInputType.emailAddress,
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Vui lòng nhập email';
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) return 'Định dạng email không hợp lệ';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          hint: 'Password', icon: Icons.lock_outline, controller: passCtrl, obscure: true,
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Vui lòng nhập mật khẩu';
                            if (val.length < 8) return 'Mật khẩu phải >= 8 ký tự';
                            if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[A-Za-z\d@$!%*?&]').hasMatch(val)) return 'Cần có chữ hoa, thường và số';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          hint: 'Confirm Password', icon: Icons.done_all_outlined, controller: confirmPassCtrl, obscure: true,
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Vui lòng xác nhận mật khẩu';
                            if (val != passCtrl.text) return 'Mật khẩu nhập lại không khớp!';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: isAgreed,
                                activeColor: Colors.white,
                                checkColor: Colors.black,
                                side: const BorderSide(color: Colors.white70),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                onChanged: (val) => setState(() => isAgreed = val ?? false),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(child: Text('I agree with terms and privacy policy.', style: TextStyle(color: Colors.white70, fontSize: 13))),
                          ],
                        ),

                        if (vm.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(vm.errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 13), textAlign: TextAlign.center),
                          ),

                        const SizedBox(height: 32),

                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey[800],
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            onPressed: isAgreed && !vm.isLoading
                                ? () async {
                                    if (_formKey.currentState!.validate()) {
                                      final messenger = ScaffoldMessenger.of(context);
                                      final navigator = Navigator.of(context);
                                      final ok = await vm.register(nameCtrl.text, phoneCtrl.text, emailCtrl.text, passCtrl.text);
                                      if (!mounted) return;
                                      if (ok) {
                                        messenger.showSnackBar(
                                          const SnackBar(content: Text('Đăng ký tài khoản mới thành công!'), backgroundColor: Colors.green),
                                        );
                                        navigator.pop();
                                      }
                                    }
                                  }
                                : null,
                            child: vm.isLoading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('SIGN UP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? ", style: TextStyle(color: Colors.white70)),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text('LOG IN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
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

  Widget _buildInputField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool obscure = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
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
