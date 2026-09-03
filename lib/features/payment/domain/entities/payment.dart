// ============================================
// ENTITÉ PAYMENT (DOMAINE) - VERSION PREMIUM
// ============================================
// Représente une tentative de paiement avec
// états, références et sécurité. Design ShopPro.
// ============================================

class Payment {
  final int id;
  final String paymentNumber;
  final int orderId;
  final String orderNumber;
  final int userId;
  final double amount;
  final double fee;
  final double totalAmount;
  final String currency;
  final String method;
  final String status;
  final String? transactionId;
  final String? gatewayReference;
  final String? authorizationCode;
  final String? errorMessage;
  final DateTime? paidAt;
  final DateTime? failedAt;
  final DateTime? expiredAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Payment({
    required this.id,
    required this.paymentNumber,
    required this.orderId,
    required this.orderNumber,
    required this.userId,
    required this.amount,
    this.fee = 0,
    required this.totalAmount,
    this.currency = 'FCFA',
    required this.method,
    this.status = 'pending',
    this.transactionId,
    this.gatewayReference,
    this.authorizationCode,
    this.errorMessage,
    this.paidAt,
    this.failedAt,
    this.expiredAt,
    required this.createdAt,
    required this.updatedAt,
  });

  // ============================================
  // ÉTATS
  // ============================================

  /// Le paiement est-il en attente ?
  bool get isPending => status == 'pending';

  /// Le paiement est-il en cours de traitement ?
  bool get isProcessing => status == 'processing';

  /// Le paiement est-il réussi ?
  bool get isSuccess => status == 'success' || status == 'completed';

  /// Le paiement a-t-il échoué ?
  bool get isFailed => status == 'failed';

  /// Le paiement est-il annulé ?
  bool get isCancelled => status == 'cancelled';

  /// Le paiement est-il expiré ?
  bool get isExpired => status == 'expired';

  /// Le paiement est-il remboursé ?
  bool get isRefunded => status == 'refunded';

  /// Le paiement est-il en cours de remboursement ?
  bool get isRefundPending => status == 'refund_pending';

  /// Statut formaté
  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'processing':
        return 'En traitement';
      case 'success':
      case 'completed':
        return 'Réussi';
      case 'failed':
        return 'Échoué';
      case 'cancelled':
        return 'Annulé';
      case 'expired':
        return 'Expiré';
      case 'refund_pending':
        return 'Remboursement en cours';
      case 'refunded':
        return 'Remboursé';
      case 'partially_refunded':
        return 'Partiellement remboursé';
      default:
        return status;
    }
  }

  /// Couleur du statut (hex)
  int get statusColorHex {
    switch (status) {
      case 'pending':
        return 0xFFF4B942; // Gold
      case 'processing':
        return 0xFF3B82F6; // Bleu
      case 'success':
      case 'completed':
        return 0xFF087F5B; // Emerald
      case 'failed':
        return 0xFFFF6B6B; // Coral
      case 'cancelled':
        return 0xFF68756F; // Gris
      case 'expired':
        return 0xFF68756F; // Gris
      case 'refund_pending':
        return 0xFFF4B942; // Gold
      case 'refunded':
        return 0xFF3B82F6; // Bleu
      default:
        return 0xFF68756F;
    }
  }

  // ============================================
  // FORMATAGE
  // ============================================

  /// Montant formaté
  String get formattedAmount => _formatPrice(amount);

  /// Frais formatés
  String get formattedFee => _formatPrice(fee);

  /// Total formaté
  String get formattedTotalAmount => _formatPrice(totalAmount);

  /// Date formatée
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} jour(s)';
    }
    if (difference.inHours > 0) {
      return '${difference.inHours} heure(s)';
    }
    if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min';
    }
    return 'À l\'instant';
  }

  // ============================================
  // MÉTHODES
  // ============================================

  /// Vérifier si le paiement a expiré
  bool get hasExpired {
    if (expiredAt == null) return false;
    return DateTime.now().isAfter(expiredAt!);
  }

  /// Le paiement peut-il être retenté ?
  bool get canRetry {
    return isFailed || isCancelled || isExpired;
  }

  /// Le paiement est-il en cours ?
  bool get isInProgress => isPending || isProcessing;

  // ============================================
  // VALIDATION
  // ============================================

  /// Le paiement a-t-il des données valides ?
  bool get isValid {
    return id > 0 &&
        paymentNumber.isNotEmpty &&
        orderId > 0 &&
        amount > 0 &&
        method.isNotEmpty;
  }

  // ============================================
  // FORMATAGE INTERNE
  // ============================================

  String _formatPrice(double amount) {
    final formatted = amount.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < formatted.length; i++) {
      buffer.write(formatted[i]);
      if ((formatted.length - 1 - i) % 3 == 0 && i != formatted.length - 1) {
        buffer.write(' ');
      }
    }
    return '$buffer $currency';
  }

  // ============================================
  // COPIE
  // ============================================

  Payment copyWith({
    int? id,
    String? paymentNumber,
    int? orderId,
    String? orderNumber,
    int? userId,
    double? amount,
    double? fee,
    double? totalAmount,
    String? currency,
    String? method,
    String? status,
    String? transactionId,
    String? gatewayReference,
    String? authorizationCode,
    String? errorMessage,
    DateTime? paidAt,
    DateTime? failedAt,
    DateTime? expiredAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Payment(
      id: id ?? this.id,
      paymentNumber: paymentNumber ?? this.paymentNumber,
      orderId: orderId ?? this.orderId,
      orderNumber: orderNumber ?? this.orderNumber,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      fee: fee ?? this.fee,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      method: method ?? this.method,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      gatewayReference: gatewayReference ?? this.gatewayReference,
      authorizationCode: authorizationCode ?? this.authorizationCode,
      errorMessage: errorMessage ?? this.errorMessage,
      paidAt: paidAt ?? this.paidAt,
      failedAt: failedAt ?? this.failedAt,
      expiredAt: expiredAt ?? this.expiredAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ============================================
  // JSON
  // ============================================

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

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as int? ?? 0,
      paymentNumber: json['payment_number'] as String? ?? '',
      orderId: json['order_id'] as int? ?? 0,
      orderNumber: json['order_number'] as String? ?? '',
      userId: json['user_id'] as int? ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      fee: (json['fee'] as num?)?.toDouble() ?? 0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'FCFA',
      method: json['method'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      transactionId: json['transaction_id'] as String?,
      gatewayReference: json['gateway_reference'] as String?,
      authorizationCode: json['authorization_code'] as String?,
      errorMessage: json['error_message'] as String?,
      paidAt: DateTime.tryParse(json['paid_at'] as String? ?? ''),
      failedAt: DateTime.tryParse(json['failed_at'] as String? ?? ''),
      expiredAt: DateTime.tryParse(json['expired_at'] as String? ?? ''),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'Payment(id: $id, number: $paymentNumber, '
        'order: $orderNumber, amount: $formattedAmount, '
        'method: $method, status: $statusLabel)';
  }
}