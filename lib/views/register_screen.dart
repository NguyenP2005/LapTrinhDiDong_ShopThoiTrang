import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AuthViewModel>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Họ tên')),
          TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
          TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Mật khẩu')),
          if (vm.errorMessage != null) Text(vm.errorMessage!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          vm.isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () async {
                  final ok = await vm.register(nameCtrl.text, emailCtrl.text, passCtrl.text);
                  if (ok) { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng ký thành công!'))); }
                },
                child: const Text('Đăng ký')),
        ]),
      ),
    );
  }
}