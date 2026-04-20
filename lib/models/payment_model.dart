class PaymentModel {
  final String id;
  final String orderId;
  final String method; // COD, BANK_TRANSFER
  final double amount;
  final String status; // pending, success, failed
  final String? bankName;
  final String? accountNumber;
  final String? paidAt;

  PaymentModel({
    required this.id,
    required this.orderId,
    required this.method,
    required this.amount,
    required this.status,
    this.bankName,
    this.accountNumber,
    this.paidAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? '',
      method: json['method'] ?? 'COD',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      bankName: json['bank_name'],
      accountNumber: json['account_number'],
      paidAt: json['paid_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    'order_id': orderId,
    'method': method,
    'amount': amount,
    'status': status,
    'bank_name': bankName,
    'account_number': accountNumber,
    'paid_at': paidAt,
  };
}
