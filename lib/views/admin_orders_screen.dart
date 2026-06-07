import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/order_viewmodel.dart';
import '../models/order_model.dart';
import 'order_detail_screen.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  String _selectedStatus = 'all'; 
  String _sortOrder = 'newest';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderViewModel>().loadAllOrders();
    });
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.').replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VND';
  }

  String _translateStatus(String status) {
    switch (status) {
      case 'pending':
        return 'CH? DUY?T';
      case 'shipping':
        return '�ANG GIAO';
      case 'delivered':
        return 'HO�N TH�NH';
      case 'cancelled':
        return '�� H?Y';
      default:
        return status.toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'shipping':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  void _showStatusUpdateDialog(BuildContext context, OrderModel order) {
    final List<String> statuses = ['pending', 'shipping', 'delivered', 'cancelled'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'C?P NH?T TR?NG TH�I',
                style: TextStyle(
                  color: Color(0xFF2B2B2B),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              ...statuses.map((status) {
                return ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  title: Text(
                    _translateStatus(status),
                    style: TextStyle(
                      fontWeight: order.status == status ? FontWeight.bold : FontWeight.normal,
                      color: _getStatusColor(status),
                    ),
                  ),
                  trailing: order.status == status ? Icon(Icons.check, color: _getStatusColor(status)) : null,
                  onTap: () {
                    Navigator.pop(bottomSheetContext); // ��ng bottom sheet
                    if (order.status != status) {
                      showDialog(
                        context: context,
                        builder: (dialogContext) {
                          return AlertDialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Text('X�c nh?n', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2B2B2B))),
                            content: Text('B?n c� ch?c ch?n mu?n chuy?n tr?ng th�idon h�ng th�nh ${_translateStatus(status)} kh�ng?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text('Hủy', style: TextStyle(color: Colors.black54)),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  Navigator.pop(dialogContext);
                                  final orderVM = context.read<OrderViewModel>();
                                  final messenger = ScaffoldMessenger.of(context);
                                  final success = await orderVM.updateOrderStatus(
                                        order.id,
                                        status,
                                        isAdmin: true,
                                      );
                                  if (mounted) {
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            success ? 'C?p nh?t tr?ng th�i th�nh c�ng!' : 'C� l?i x?y ra!'),
                                        backgroundColor: success ? Colors.green : Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4361EE),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('�?ng �', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('B? l?c tr?ng th�i', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54)),
              DropdownButton<String>(
                value: _sortOrder,
                icon: const Icon(Icons.sort, size: 16, color: Color(0xFF4361EE)),
                underline: const SizedBox(),
                style: const TextStyle(fontSize: 13, color: Color(0xFF4361EE), fontWeight: FontWeight.bold),
                onChanged: (val) {
                  if (val != null) setState(() => _sortOrder = val);
                },
                items: const [
                  DropdownMenuItem(value: 'newest', child: Text('M?i nh?t')),
                  DropdownMenuItem(value: 'oldest', child: Text('Cu nh?t')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('T?t c?', 'all'),
                _buildFilterChip('Ch? duy?t', 'pending'),
                _buildFilterChip('�ang giao', 'shipping'),
                _buildFilterChip('Ho�n th�nh', 'delivered'),
                _buildFilterChip('�� h?y', 'cancelled'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String statusValue) {
    final isSelected = _selectedStatus == statusValue;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() => _selectedStatus = statusValue);
          }
        },
        selectedColor: const Color(0xFF4361EE),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        backgroundColor: Colors.grey[100],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.transparent)),
        showCheckmark: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const colorBackground = Color(0xFFF4F7FC);
    const colorPrimary = Color(0xFF4361EE);
    const colorTextPrimary = Color(0xFF2B2B2B);

    return Scaffold(
      backgroundColor: colorBackground,
      appBar: AppBar(
        backgroundColor: colorBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: colorTextPrimary),
        title: const Text(
          'ORDER MANAGEMENT',
          style: TextStyle(
            color: colorTextPrimary,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<OrderViewModel>(
        builder: (context, orderVM, child) {
          if (orderVM.isLoading) {
            return const Center(child: CircularProgressIndicator(color: colorPrimary));
          }

          List<OrderModel> filteredOrders = orderVM.orders.where((order) {
            if (_selectedStatus == 'all') return true;
            return order.status == _selectedStatus;
          }).toList();

          if (_sortOrder == 'newest') {
            filteredOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          } else {
            filteredOrders.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          }

          return Column(
            children: [
              _buildFilterSection(),
              Expanded(
                child: RefreshIndicator(
                  color: colorPrimary,
                  backgroundColor: Colors.white,
                  onRefresh: () => orderVM.loadAllOrders(),
                  child: filteredOrders.isEmpty
                      ? ListView( // Using ListView so RefreshIndicator still works when empty
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 100),
                            Center(
                              child: Text(
                                'Kh�ng t�m th?ydon h�ng n�o.',
                                style: TextStyle(color: Colors.black54, fontSize: 16),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: filteredOrders.length,
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderDetailScreen(order: order),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '�ON H�NG #${order.id}',
                                style: const TextStyle(
                                    color: colorTextPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Ng�yd?t: ${order.createdAt.split('T')[0]}',
                                style: const TextStyle(color: Colors.black54, fontSize: 12),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Tổng tiền: ${_formatCurrency(order.finalAmount)}',
                                style: const TextStyle(
                                    color: colorPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => _showStatusUpdateDialog(context, order),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(order.status).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _translateStatus(order.status),
                                      style: TextStyle(
                                        color: _getStatusColor(order.status),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.edit, size: 12, color: _getStatusColor(order.status)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  },
      ),
    );
  }
}

