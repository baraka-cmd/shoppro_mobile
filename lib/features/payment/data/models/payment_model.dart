// Modèle Payment (Data)
// Gère la sérialisation/désérialisation JSON du paiement

import '../../domain/entities/payment.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    required super.id,
    required super.paymentNumber,
    required super.orderId,
    required super.orderNumber,
    required super.amount,
    super.fee,
    required super.totalAmount,
    super.currency,
    required super.method,
    super.status,
    super.transactionId,
    super.gatewayReference,
    super.paidAt,
    super.failedAt,
    super.refundedAt,
    super.errorMessage,
    required super.createdAt,
  });

  /// Créer depuis JSON
  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as int? ?? 0,
      paymentNumber: json['payment_number'] as String? ?? '',
      orderId: json['order_id'] as int? ?? 0,
      orderNumber: json['order_number'] as String? ?? '',
      amount: _parseDouble(json['amount']),
      fee: _parseDouble(json['fee']),
      totalAmount: _parseDouble(json['total_amount']),
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

  /// Convertir en JSON
  @override
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

  /// Parser un double
  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}