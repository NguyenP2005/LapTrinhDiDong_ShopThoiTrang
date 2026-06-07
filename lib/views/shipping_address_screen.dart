import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/address_viewmodel.dart';
import 'add_address_screen.dart';

class ShippingAddressScreen extends StatefulWidget {
  final String userId;
  const ShippingAddressScreen({super.key, required this.userId});

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AddressViewModel>(context, listen: false).loadAddresses(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final addressVM = Provider.of<AddressViewModel>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        title: Text(
          'SHIPPING ADDRESSES',
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w800, letterSpacing: 1.5, fontSize: 18),
        ),
        centerTitle: true,
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1.0), child: Container(color: Colors.grey[200], height: 1.0)),
      ),
      body: addressVM.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: addressVM.addresses.length,
              itemBuilder: (context, index) {
                final address = addressVM.addresses[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.grey[50],
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(address.receiverName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const Spacer(),
                          if (address.isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)),
                              child: const Text('Default', style: TextStyle(color: Colors.white, fontSize: 10)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(address.phone, style: const TextStyle(color: Colors.black54)),
                      const SizedBox(height: 4),
                      Text(address.address),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => AddAddressScreen(userId: widget.userId)));
          if (result == true) addressVM.loadAddresses(widget.userId);
        },
      ),
    );
  }
}