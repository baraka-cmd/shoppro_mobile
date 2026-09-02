// Entité Payment (Domaine)
// Représente un paiement

class Payment {
  final int id;
  final String paymentNumber;
  final int orderId;
  final String orderNumber;
  final double amount;
  final double fee;
  final double totalAmount;
  final String currency;
  final String method;
  final String status;
  final String? transactionId;
  final String? gatewayReference;
  final DateTime? paidAt;
  final DateTime? failedAt;
  final DateTime? refundedAt;
  final String? errorMessage;
  final DateTime createdAt;

  const Payment({
    required this.id,
    required this.paymentNumber,
    required this.orderId,
    required this.orderNumber,
    required this.amount,
    this.fee = 0,
    required this.totalAmount,
    this.currency = 'FCFA',
    required this.method,
    this.status = 'pending',
    this.transactionId,
    this.gatewayReference,
    this.paidAt,
    this.failedAt,
    this.refundedAt,
    this.errorMessage,
    required this.createdAt,
  });

  /// Label de la méthode de paiement
  String get methodLabel {
    switch (method) {
      case 'cash_on_delivery':
        return 'À la livraison';
      case 'mobile_money':
        return 'Mobile Money';
      case 'card':
        return 'Carte bancaire';
      case 'paypal':
        return 'PayPal';
      case 'bank_transfer':
        return 'Virement bancaire';
      default:
        return method;
    }
  }

  /// Icône de la méthode
  String get methodIcon {
    switch (method) {
      case 'cash_on_delivery':
        return '💵';
      case 'mobile_money':
        return '📱';
      case 'card':
        return '💳';
      case 'paypal':
        return '🅿️';
      case 'bank_transfer':
        return '🏦';
      default:
        return '💰';
    }
  }

  /// Label du statut
  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'processing':
        return 'En cours';
      case 'completed':
        return 'Complété';
      case 'failed':
        return 'Échoué';
      case 'cancelled':
        return 'Annulé';
      case 'refunded':
        return 'Remboursé';
      default:
        return status;
    }
  }

  /// Couleur du statut
  int get statusColor {
    switch (status) {
      case 'pending':
        return 0xFFF39C12;
      case 'processing':
        return 0xFF3498DB;
      case 'completed':
        return 0xFF27AE60;
      case 'failed':
        return 0xFFE74C3C;
      case 'cancelled':
        return 0xFF7F8C8D;
      case 'refunded':
        return 0xFF7F8C8D;
      default:
        return 0xFF7F8C8D;
    }
  }

  /// Le paiement est-il réussi ?
  bool get isSuccessful => status == 'completed';

  /// Le paiement est-il en attente ?
  bool get isPending => status == 'pending';

  /// Le paiement a-t-il échoué ?
  bool get isFailed => status == 'failed';

  /// Le paiement est-il remboursé ?
  bool get isRefunded => status == 'refunded';

  /// Montant formaté
  String get formattedAmount => _formatPrice(amount);

  /// Frais formatés
  String get formattedFee => _formatPrice(fee);

  /// Total formaté
  String get formattedTotal => _formatPrice(totalAmount);

  /// Formater un prix
  String _formatPrice(double value) {
    final formatted = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < formatted.length; i++) {
      buffer.write(formatted[i]);
      if ((formatted.length - 1 - i) % 3 == 0 && i != formatted.length - 1) {
        buffer.write(' ');
      }
    }
    return '$buffer $currency';
  }

  /// Copier avec modifications
  Payment copyWith({
    int? id,
    String? paymentNumber,
    int? orderId,
    String? orderNumber,
    double? amount,
    double? fee,
    double? totalAmount,
    String? currency,
    String? method,
    String? status,
    String? transactionId,
    String? gatewayReference,
    DateTime? paidAt,
    DateTime? failedAt,
    DateTime? refundedAt,
    String? errorMessage,
    DateTime? createdAt,
  }) {
    return Payment(
      id: id ?? this.id,
      paymentNumber: paymentNumber ?? this.paymentNumber,
      orderId: orderId ?? this.orderId,
      orderNumber: orderNumber ?? this.orderNumber,
      amount: amount ?? this.amount,
      fee: fee ?? this.fee,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      method: method ?? this.method,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      gatewayReference: gatewayReference ?? this.gatewayReference,
      paidAt: paidAt ?? this.paidAt,
      failedAt: failedAt ?? this.failedAt,
      refundedAt: refundedAt ?? this.refundedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payment_number': paymentNumber,
      'order_id': orderId,
      'order_number': orderNumber,
      'amount': amount,
      'fee': fee,
      'total_amount': totalAmount,
      'currency': currency,
      'method': method,
      'status': status,
      'transaction_id': transactionId,
      'gateway_reference': gatewayReference,
      'paid_at': paidAt?.toIso8601String(),
      'failed_at': failedAt?.toIso8601String(),
      'refunded_at': refundedAt?.toIso8601String(),
      'error_message': errorMessage,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Créer depuis JSON
  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as int? ?? 0,
      paymentNumber: json['payment_number'] as String? ?? '',
      orderId: json['order_id'] as int? ?? 0,
      orderNumber: json['order_number'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      fee: (json['fee'] as num?)?.toDouble() ?? 0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'FCFA',
      method: json['method'] as String? ?? 'cash_on_delivery',
      status: json['status'] as String? ?? 'pending',
      transactionId: json['transaction_id'] as String?,
      gatewayReference: json['gateway_reference'] as String?,
      paidAt: DateTime.tryParse(json['paid_at'] as String? ?? ''),
      failedAt: DateTime.tryParse(json['failed_at'] as String? ?? ''),
      refundedAt: DateTime.tryParse(json['refunded_at'] as String? ?? ''),
      errorMessage: json['error_message'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}