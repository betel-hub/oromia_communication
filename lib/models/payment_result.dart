class PaymentCheckout {
  final int saleId;
  final String orderId;
  final double amount;
  final String currency;
  final String gateway;
  final String checkoutUrl;
  final String status;

  PaymentCheckout({
    required this.saleId,
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.gateway,
    required this.checkoutUrl,
    required this.status,
  });

  factory PaymentCheckout.fromJson(Map<String, dynamic> json) {
    return PaymentCheckout(
      saleId: _toInt(json['sale_id']),
      orderId: (json['order_id'] ?? '').toString(),
      amount: _toDouble(json['amount']),
      currency: (json['currency'] ?? 'ETB').toString(),
      gateway: (json['gateway'] ?? '').toString(),
      checkoutUrl: (json['checkout_url'] ?? '').toString(),
      status: (json['status'] ?? 'pending').toString(),
    );
  }
}

class PaymentStatus {
  final String orderId;
  final String status;
  final double amount;

  PaymentStatus({
    required this.orderId,
    required this.status,
    required this.amount,
  });

  factory PaymentStatus.fromJson(Map<String, dynamic> json) {
    return PaymentStatus(
      orderId: (json['order_id'] ?? '').toString(),
      status: (json['status'] ?? 'pending').toString(),
      amount: _toDouble(json['amount']),
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isFailed => status == 'failed' || status == 'cancelled';
}

int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

double _toDouble(dynamic v) {
  if (v == null) return 0;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0;
  return 0;
}