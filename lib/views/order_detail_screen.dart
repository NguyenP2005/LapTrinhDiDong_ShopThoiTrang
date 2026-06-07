import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../models/order_item_model.dart';
import '../viewmodels/order_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  List<OrderItemModel> items = [];
  bool isLoading = true;
  late String currentStatus;

  @override
  void initState() {
    super.initState();
    currentStatus = widget.order.status;
    _loadOrderItems();
  }

  Future<void> _loadOrderItems() async {
    final orderVM = Provider.of<OrderViewModel>(context, listen: false);
    // G?i h�m getOrderItems t? ViewModeld� vi?t ? bu?c tru?c
    final loadedItems = await orderVM.getOrderItems(widget.order.id);

    if (mounted) {
      setState(() {
        items = loadedItems;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Chi tiếtdon h�ng',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4361EE)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Tr?ng th�idon h�ng
                  _buildSectionCard(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.local_shipping_outlined,
                          color: Color(0xFF4361EE),
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Tr?ng th�i: ',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          _getStatusText(currentStatus),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4361EE),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. M�, ng�yd?t & Phương thức TT
                  _buildSectionCard(
                    child: Column(
                      children: [
                        _buildRowInfo('M�don h�ng', '#${widget.order.id}'),
                        const SizedBox(height: 12),
                        _buildRowInfo(
                          'Ng�yd?t',
                          widget.order.createdAt.substring(0, 10),
                        ),
                        const SizedBox(height: 12),
                        _buildRowInfo(
                          'Thanh to�n',
                          _getPaymentMethod(widget.order.paymentMethod),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Danh s�ch sản phẩm
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 12),
                    child: Text(
                      'Sản phẩmd� mua',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  ...items.map((item) => _buildProductItem(item)),

                  const SizedBox(height: 16),

                  // 4. T?ng quan thanh to�n
                  _buildSectionCard(
                    child: Column(
                      children: [
                        _buildRowInfo(
                          'Tổng tiền h�ng',
                          '${widget.order.totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VND',
                        ),
                        const SizedBox(height: 12),
                        _buildRowInfo(
                          'Ph� vận chuyển',
                          '${widget.order.shippingFee.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VND',
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Th�nh ti?n',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${widget.order.finalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VND',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4361EE),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
      bottomNavigationBar: context.watch<AuthViewModel>().userRole == 'admin'
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _showStatusUpdateDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4361EE),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'C?P NH?T TR?NG TH�I',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            )
          : null,
    );
  }

  // Khung tr?ng bo g�c vi?nd? b�ng
  Widget _buildSectionCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // Row th�ng tin text 2 b�n
  Widget _buildRowInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.black54, fontSize: 14)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }

  // Widget hi?n th? 1 sản phẩm trong bill
  Widget _buildProductItem(OrderItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildImage(item.productImage, 60),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  'Số lượng: ${item.quantity}',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            '${item.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VND',
            style: const TextStyle(
              color: Color(0xFF4361EE),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  // X? l� ?nh (h? tr? c? link network v� asset)
  Widget _buildImage(String path, double size) {
    if (path.startsWith("http")) {
      return Image.network(
        path,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _errorImage(size),
      );
    }
    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _errorImage(size),
    );
  }

  Widget _errorImage(double size) {
    return Container(
      width: size,
      height: size,
      color: Colors.grey[200],
      child: const Icon(Icons.image, color: Colors.black54),
    );
  }

  // D?ch tr?ng th�i sang ti?ng Vi?t
  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Ch? x�c nh?n';
      case 'shipping':
        return '�ang giao h�ng';
      case 'delivered':
        return 'Giao th�nh c�ng';
      case 'cancelled':
        return '�� h?y';
      default:
        return '�ang xử lý�';
    }
  }

  // D?ch PT thanh to�n sang ti?ng Vi?t
  String _getPaymentMethod(String method) {
    if (method == 'COD') return 'Thanh to�n khi nh?n h�ng';
    if (method == 'BANK_TRANSFER') return 'Chuyển khoản ng�n h�ng';
    return method;
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

  void _showStatusUpdateDialog() {
    final List<String> statuses = [
      'pending',
      'shipping',
      'delivered',
      'cancelled',
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'C?P NH?T TR?NG TH�I',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              ...statuses.map((status) {
                return ListTile(
                  title: Text(
                    _getStatusText(status),
                    style: TextStyle(
                      fontWeight: currentStatus == status
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: _getStatusColor(status),
                    ),
                  ),
                  trailing: currentStatus == status
                      ? const Icon(Icons.check, color: Colors.black)
                      : null,
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    if (currentStatus != status) {
                      showDialog(
                        context: context,
                        builder: (dialogContext) {
                          return AlertDialog(
                            backgroundColor: Colors.white,
                            title: const Text(
                              'X�c nh?n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            content: Text(
                              'B?n c� ch?c ch?n mu?n chuy?n tr?ng th�idon h�ng th�nh ${_getStatusText(status)} kh�ng?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text(
                                  'Hủy',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  Navigator.pop(dialogContext);
                                  final success = await context
                                      .read<OrderViewModel>()
                                      .updateOrderStatus(
                                        widget.order.id,
                                        status,
                                        isAdmin: true,
                                      );
                                  if (mounted) {
                                    if (success) {
                                      setState(() => currentStatus = status);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'C?p nh?t tr?ng th�i th�nh c�ng!',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('C� l?i x?y ra!'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                ),
                                child: const Text(
                                  '�?ng �',
                                  style: TextStyle(color: Colors.white),
                                ),
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
}

