import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/address_viewmodel.dart';
import '../models/address_model.dart';

class AddAddressScreen extends StatefulWidget {
  final String userId;

  const AddAddressScreen({super.key, required this.userId});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isDefault = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final addressVM = Provider.of<AddressViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Th�md?a ch? m?i',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF4361EE),
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // T�n ngu?i nh?n
            _buildTextField(
              controller: _nameController,
              label: 'T�n ngu?i nh?n',
              hint: 'Nh?p h? v� t�nd?yd?',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui l�ng nh?p t�n ngu?i nh?n';
                }
                if (value.trim().length < 3) {
                  return 'T�n ph?i c� �t nh?t 3 k� t?';
                }
                // Ki?m tra t�n ch? ch?a ch? c�i v� kho?ng tr?ng
                if (!RegExp(r"^[\p{L}\s]+$", unicode: true).hasMatch(value.trim())) {
                  return 'T�n kh�ngdu?c ch?a s? ho?c k� t?d?c bi?t';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // S?di?n tho?i
            _buildTextField(
              controller: _phoneController,
              label: 'S?di?n tho?i',
              hint: 'VD: 0901234567',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui l�ng nh?p s?di?n tho?i';
                }
                // Chu?n Vi?t Nam: 10 s?, b?td?u b?ng 03/05/07/08/09
                final phoneRegex = RegExp(r'^(03|05|07|08|09)[0-9]{8}$');
                if (!phoneRegex.hasMatch(value.trim())) {
                  return 'S?di?n tho?i kh�ng h?p l? (VD: 0901234567)';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // �?a ch? c? th?
            _buildTextField(
              controller: _addressController,
              label: '�?a ch? c? th?',
              hint: 'S? nh�, t�ndu?ng, phu?ng/x�, qu?n/huy?n, t?nh/th�nh ph?',
              icon: Icons.location_on_outlined,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui l�ng nh?pd?a ch?';
                }
                if (value.trim().length < 10) {
                  return '�?a ch? qu� ng?n, vui l�ng nh?pd?yd?';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Checkboxd?t l�m m?cd?nh
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _isDefault,
                    onChanged: (value) {
                      setState(() {
                        _isDefault = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFF4361EE),
                  ),
                  const Text(
                    '�?t l�md?a ch? m?cd?nh',
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // N�t luu
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: addressVM.isLoading ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4361EE),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: addressVM.isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Luud?a ch?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF4361EE)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final addressVM = Provider.of<AddressViewModel>(context, listen: false);

    final newAddress = AddressModel(
      id: '', // Server s? t? t?o
      userId: widget.userId,
      receiverName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      isDefault: _isDefault,
    );

    final success = await addressVM.addAddress(newAddress);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('�� th�md?a ch? th�nh c�ng'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // Tr? v? trued? reload
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(addressVM.errorMessage ?? 'C� l?i x?y ra'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

