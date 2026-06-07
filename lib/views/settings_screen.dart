import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsVM = Provider.of<SettingsViewModel>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        title: Text(
          'APP SETTINGS',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
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
              'Chế độ Tối (Dark Mode)',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: const Text('Đổi màu nền ứng dụng'),
            activeThumbColor: Colors.black,
            value: settingsVM.isDarkMode,
            onChanged: (val) => settingsVM.toggleTheme(val),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text(
              'Tiền tệ: USD (\$)',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: const Text('Mặc định là VND'),
            activeThumbColor: Colors.black,
            value: settingsVM.isUSD,
            onChanged: (val) => settingsVM.toggleCurrency(val),
          ),
        ],
      ),
    );
  }
}
