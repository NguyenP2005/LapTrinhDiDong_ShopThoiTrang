import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsVM = Provider.of<SettingsViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'CÀI ĐẶT ỨNG DỤNG',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[200], height: 1.0),
        ),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text(
              'Tiền tệ: USD (\$)',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: const Text('Mặc định là VND (đ)'),
            activeColor: const Color(0xFF4361EE),
            value: settingsVM.isUSD,
            onChanged: (val) => settingsVM.toggleCurrency(val),
          ),
        ],
      ),
    );
  }
}