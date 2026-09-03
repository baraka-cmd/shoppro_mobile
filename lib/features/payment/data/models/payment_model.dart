// ============================================
// MODÈLE PAYMENT (DATA) - VERSION PREMIUM
// ============================================
// Gère la sérialisation/désérialisation JSON
// avec parsing robuste et valeurs par défaut.
// ============================================

import '../../domain/entities/payment.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    required super.id,
    required super.paymentNumber,
    required super.orderId,
    required super.orderNumber,
    required super.userId,
    required super.amount,
    super.fee,
    required super.totalAmount,
    super.currency,
    required super.method,
    super.status,
    super.transactionId,
    super.gatewayReference,
    super.authorizationCode,
    super.errorMessage,
    super.paidAt,
    super.failedAt,
    super.expiredAt,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Créer depuis JSON
  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: _parseInt(json['id']),
      paymentNumber: _parseString(json['payment_number']),
      orderId: _parseInt(json['order_id']),
      orderNumber: _parseString(json['order_number']),
      userId: _parseInt(json['user_id']),
      amount: _parseDouble(json['amount']),
      fee: _parseDouble(json['fee']),
      totalAmount: _parseDouble(json['total_amount']),
      currency: _parseString(json['currency'], defaultValue: 'FCFA'),
      method: _parseString(json['method']),
      status: _parseString(json['status'], defaultValue: 'pending'),
      transactionId: _parseNullableString(json['transaction_id']),
      gatewayReference: _parseNullableString(json['gateway_reference']),
      authorizationCode: _parseNullableString(json['authorization_code']),
      errorMessage: _parseNullableString(json['error_message']),
      paidAt: _parseDate(json['paid_at']),
      failedAt: _parseDate(json['failed_at']),
      expiredAt: _parseDate(json['expired_at']),
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updated_at']) ?? DateTime.now(),
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
      'user_id': userId,
      'amount': amount,
      'fee': fee,
      'total_amount': totalAmount,
      'currency': currency,
      'method': method,
      'status': status,
      'transaction_id': transactionId,
      'gateway_reference': gatewayReference,
      'authorization_code': authorizationCode,
      'error_message': errorMessage,
      'paid_at': paidAt?.toIso8601String(),
      'failed_at': failedAt?.toIso8601String(),
      'expired_at': expiredAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Copier depuis l'entité
  static PaymentModel fromEntity(Payment payment) {
    return PaymentModel(
      id: payment.id,
      paymentNumber: payment.paymentNumber,
      orderId: payment.orderId,
      orderNumber: payment.orderNumber,
      userId: payment.userId,
      amount: payment.amount,
      fee: payment.fee,
      totalAmount: payment.totalAmount,
      currency: payment.currency,
      method: payment.method,
      status: payment.status,
      transactionId: payment.transactionId,
      gatewayReference: payment.gatewayReference,
      authorizationCode: payment.authorizationCode,
      errorMessage: payment.errorMessage,
      paidAt: payment.paidAt,
      failedAt: payment.failedAt,
      expiredAt: payment.expiredAt,
      createdAt: payment.createdAt,
      updatedAt: payment.updatedAt,
    );
  }

  // ============================================
  // HELPERS DE PARSING
  // ============================================

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static String _parseString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    final string = value.toString().trim();
    return string.isEmpty ? defaultValue : string;
  }

  static String? _parseNullableString(dynamic value) {
    if (value == null) return null;
    final string = value.toString().trim();
    return string.isEmpty ? null : string;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}