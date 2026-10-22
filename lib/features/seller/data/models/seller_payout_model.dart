// ============================================
// MODEL : SellerPayoutModel
// ============================================
// Sérialisation JSON pour SellerPayout + SellerBalance + Stats.
//
// Responsabilités :
//   - Parser la réponse API /seller/payouts
//   - Convertir les statuts (String → Enum)
//   - Convertir les couleurs hex
//   - Gérer les valeurs null (parsing défensif)
// ============================================

import '../../domain/entities/seller_payout.dart';

// ============================================
// MODEL : SellerPayoutModel
// ============================================

class SellerPayoutModel extends SellerPayout {
  const SellerPayoutModel({
    required super.id,
    required super.reference,
    required super.amount,
    required super.amountFormatted,
    required super.fee,
    required super.feeFormatted,
    required super.netAmount,
    required super.netAmountFormatted,
    super.currency,
    required super.method,
    required super.methodLabel,
    required super.methodIcon,
    super.accountMasked,
    required super.status,
    required super.statusLabel,
    required super.statusColorHex,
    super.isPending,
    super.isProcessing,
    super.isCompleted,
    super.isFailed,
    super.isCancelled,
    super.isCancellable,
    super.requestedAt,
    super.requestedAtHuman,
    super.processedAt,
    super.processedAtHuman,
    super.completedAt,
    super.completedAtHuman,
    super.failedAt,
    super.cancelledAt,
    super.note,
    super.externalReference,
    super.externalProvider,
    super.failureReason,
  });

  // ============================================
  // JSON → MODEL
  // ============================================

  factory SellerPayoutModel.fromJson(Map<String, dynamic> json) {
    return SellerPayoutModel(
      id: _parseInt(json['id']),
      reference: _parseString(json['reference'], 'PAYOUT-XXXX'),
      amount: _parseDouble(json['amount']),
      amountFormatted: _parseString(json['amount_formatted'], '0 FCFA'),
      fee: _parseDouble(json['fee']),
      feeFormatted: _parseString(json['fee_formatted'], '0 FCFA'),
      netAmount: _parseDouble(json['net_amount']),
      netAmountFormatted: _parseString(json['net_amount_formatted'], '0 FCFA'),
      currency: _parseString(json['currency'], 'FCFA'),
      method: SellerPayoutMethod.fromCode(json['method'] as String?),
      methodLabel: _parseString(json['method_label'], 'Autre'),
      methodIcon: _parseString(json['method_icon'], 'payment'),
      accountMasked: _parseNullableString(json['account_masked']),
      status: SellerPayoutStatus.fromCode(json['status'] as String?),
      statusLabel: _parseString(json['status_label'], 'Inconnu'),
      statusColorHex: _parseColorHex(json['status_color']),
      isPending: _parseBool(json['is_pending']),
      isProcessing: _parseBool(json['is_processing']),
      isCompleted: _parseBool(json['is_completed']),
      isFailed: _parseBool(json['is_failed']),
      isCancelled: _parseBool(json['is_cancelled']),
      isCancellable: _parseBool(json['is_cancellable']),
      requestedAt: _parseDate(json['requested_at']),
      requestedAtHuman: _parseNullableString(json['requested_at_human']),
      processedAt: _parseDate(json['processed_at']),
      processedAtHuman: _parseNullableString(json['processed_at_human']),
      completedAt: _parseDate(json['completed_at']),
      completedAtHuman: _parseNullableString(json['completed_at_human']),
      failedAt: _parseDate(json['failed_at']),
      cancelledAt: _parseDate(json['cancelled_at']),
      note: _parseNullableString(json['note']),
      externalReference: _parseNullableString(json['external_reference']),
      externalProvider: _parseNullableString(json['external_provider']),
      failureReason: _parseNullableString(json['failure_reason']),
    );
  }

  // ============================================
  // MODEL → JSON
  // ============================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
      'amount': amount,
      'amount_formatted': amountFormatted,
      'fee': fee,
      'fee_formatted': feeFormatted,
      'net_amount': netAmount,
      'net_amount_formatted': netAmountFormatted,
      'currency': currency,
      'method': method.code,
      'method_label': methodLabel,
      'method_icon': methodIcon,
      'account_masked': accountMasked,
      'status': status.code,
      'status_label': statusLabel,
      'status_color': _colorHexToString(statusColorHex),
      'is_pending': isPending,
      'is_processing': isProcessing,
      'is_completed': isCompleted,
      'is_failed': isFailed,
      'is_cancelled': isCancelled,
      'is_cancellable': isCancellable,
      'requested_at': requestedAt?.toIso8601String(),
      'requested_at_human': requestedAtHuman,
      'processed_at': processedAt?.toIso8601String(),
      'processed_at_human': processedAtHuman,
      'completed_at': completedAt?.toIso8601String(),
      'completed_at_human': completedAtHuman,
      'failed_at': failedAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'note': note,
      'external_reference': externalReference,
      'external_provider': externalProvider,
      'failure_reason': failureReason,
    };
  }

  // ============================================
  // fromEntity
  // ============================================

  factory SellerPayoutModel.fromEntity(SellerPayout entity) {
    return SellerPayoutModel(
      id: entity.id,
      reference: entity.reference,
      amount: entity.amount,
      amountFormatted: entity.amountFormatted,
      fee: entity.fee,
      feeFormatted: entity.feeFormatted,
      netAmount: entity.netAmount,
      netAmountFormatted: entity.netAmountFormatted,
      currency: entity.currency,
      method: entity.method,
      methodLabel: entity.methodLabel,
      methodIcon: entity.methodIcon,
      accountMasked: entity.accountMasked,
      status: entity.status,
      statusLabel: entity.statusLabel,
      statusColorHex: entity.statusColorHex,
      isPending: entity.isPending,
      isProcessing: entity.isProcessing,
      isCompleted: entity.isCompleted,
      isFailed: entity.isFailed,
      isCancelled: entity.isCancelled,
      isCancellable: entity.isCancellable,
      requestedAt: entity.requestedAt,
      requestedAtHuman: entity.requestedAtHuman,
      processedAt: entity.processedAt,
      processedAtHuman: entity.processedAtHuman,
      completedAt: entity.completedAt,
      completedAtHuman: entity.completedAtHuman,
      failedAt: entity.failedAt,
      cancelledAt: entity.cancelledAt,
      note: entity.note,
      externalReference: entity.externalReference,
      externalProvider: entity.externalProvider,
      failureReason: entity.failureReason,
    );
  }
}

// ============================================
// MODEL : SellerBalanceModel
// ============================================

class SellerBalanceModel extends SellerBalance {
  const SellerBalanceModel({
    super.available,
    super.availableFormatted,
    super.pending,
    super.pendingFormatted,
    super.total,
    super.totalFormatted,
    super.canRequestPayout,
    super.minPayoutAmount,
    super.minPayoutAmountFormatted,
    super.activePayout,
    super.payoutMethod,
    super.payoutAccountMasked,
    super.hasPayoutMethod,
    super.commissionRate,
    super.stats,
  });

  factory SellerBalanceModel.fromJson(Map<String, dynamic> json) {
    return SellerBalanceModel(
      available: _parseDouble(json['available']),
      availableFormatted: _parseString(json['available_formatted'], '0 FCFA'),
      pending: _parseDouble(json['pending']),
      pendingFormatted: _parseString(json['pending_formatted'], '0 FCFA'),
      total: _parseDouble(json['total']),
      totalFormatted: _parseString(json['total_formatted'], '0 FCFA'),
      canRequestPayout: _parseBool(json['can_request_payout']),
      minPayoutAmount: _parseDouble(
        json['min_payout_amount'],
        defaultValue: 1000,
      ),
      minPayoutAmountFormatted: _parseString(
        json['min_payout_amount_formatted'],
        '1 000 FCFA',
      ),
      activePayout: json['active_payout'] is Map
          ? SellerPayoutActiveInfoModel.fromJson(
              Map<String, dynamic>.from(json['active_payout'] as Map),
            )
          : null,
      payoutMethod: _parseNullableString(json['payout_method']),
      payoutAccountMasked: _parseNullableString(json['payout_account_masked']),
      hasPayoutMethod: _parseBool(json['has_payout_method']),
      commissionRate: _parseDouble(json['commission_rate'], defaultValue: 10),
      stats: json['stats'] is Map
          ? SellerPayoutStatsModel.fromJson(
              Map<String, dynamic>.from(json['stats'] as Map),
            )
          : const SellerPayoutStatsModel(),
    );
  }

  factory SellerBalanceModel.fromEntity(SellerBalance e) {
    return SellerBalanceModel(
      available: e.available,
      availableFormatted: e.availableFormatted,
      pending: e.pending,
      pendingFormatted: e.pendingFormatted,
      total: e.total,
      totalFormatted: e.totalFormatted,
      canRequestPayout: e.canRequestPayout,
      minPayoutAmount: e.minPayoutAmount,
      minPayoutAmountFormatted: e.minPayoutAmountFormatted,
      activePayout: e.activePayout,
      payoutMethod: e.payoutMethod,
      payoutAccountMasked: e.payoutAccountMasked,
      hasPayoutMethod: e.hasPayoutMethod,
      commissionRate: e.commissionRate,
      stats: e.stats,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'available': available,
      'available_formatted': availableFormatted,
      'pending': pending,
      'pending_formatted': pendingFormatted,
      'total': total,
      'total_formatted': totalFormatted,
      'can_request_payout': canRequestPayout,
      'min_payout_amount': minPayoutAmount,
      'min_payout_amount_formatted': minPayoutAmountFormatted,
      'active_payout': activePayout != null
          ? SellerPayoutActiveInfoModel.fromEntity(activePayout!).toJson()
          : null,
      'payout_method': payoutMethod,
      'payout_account_masked': payoutAccountMasked,
      'has_payout_method': hasPayoutMethod,
      'commission_rate': commissionRate,
      'stats': SellerPayoutStatsModel.fromEntity(stats).toJson(),
    };
  }
}

// ============================================
// MODEL : SellerPayoutActiveInfoModel
// ============================================

class SellerPayoutActiveInfoModel extends SellerPayoutActiveInfo {
  const SellerPayoutActiveInfoModel({
    required super.id,
    required super.reference,
    required super.amount,
    required super.amountFormatted,
    required super.status,
    super.requestedAt,
    super.requestedAtHuman,
  });

  factory SellerPayoutActiveInfoModel.fromJson(Map<String, dynamic> json) {
    return SellerPayoutActiveInfoModel(
      id: _parseInt(json['id']),
      reference: _parseString(json['reference']),
      amount: _parseDouble(json['amount']),
      amountFormatted: _parseString(json['amount_formatted'], '0 FCFA'),
      status: _parseString(json['status'], 'pending'),
      requestedAt: _parseDate(json['requested_at']),
      requestedAtHuman: _parseNullableString(json['requested_at_human']),
    );
  }

  factory SellerPayoutActiveInfoModel.fromEntity(SellerPayoutActiveInfo e) {
    return SellerPayoutActiveInfoModel(
      id: e.id,
      reference: e.reference,
      amount: e.amount,
      amountFormatted: e.amountFormatted,
      status: e.status,
      requestedAt: e.requestedAt,
      requestedAtHuman: e.requestedAtHuman,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
      'amount': amount,
      'amount_formatted': amountFormatted,
      'status': status,
      'requested_at': requestedAt?.toIso8601String(),
      'requested_at_human': requestedAtHuman,
    };
  }
}

// ============================================
// MODEL : SellerPayoutStatsModel
// ============================================

class SellerPayoutStatsModel extends SellerPayoutStats {
  const SellerPayoutStatsModel({
    super.totalPayouts,
    super.completedCount,
    super.pendingCount,
    super.processingCount,
    super.totalWithdrawn,
    super.totalWithdrawnFormatted,
    super.totalCancelled,
    super.totalCancelledFormatted,
  });

  factory SellerPayoutStatsModel.fromJson(Map<String, dynamic> json) {
    return SellerPayoutStatsModel(
      totalPayouts: _parseInt(json['total_payouts']),
      completedCount: _parseInt(json['completed_count']),
      pendingCount: _parseInt(json['pending_count']),
      processingCount: _parseInt(json['processing_count']),
      totalWithdrawn: _parseDouble(json['total_withdrawn']),
      totalWithdrawnFormatted: _parseString(
        json['total_withdrawn_formatted'],
        '0 FCFA',
      ),
      totalCancelled: _parseDouble(json['total_cancelled']),
      totalCancelledFormatted: _parseString(
        json['total_cancelled_formatted'],
        '0 FCFA',
      ),
    );
  }

  factory SellerPayoutStatsModel.fromEntity(SellerPayoutStats e) {
    return SellerPayoutStatsModel(
      totalPayouts: e.totalPayouts,
      completedCount: e.completedCount,
      pendingCount: e.pendingCount,
      processingCount: e.processingCount,
      totalWithdrawn: e.totalWithdrawn,
      totalWithdrawnFormatted: e.totalWithdrawnFormatted,
      totalCancelled: e.totalCancelled,
      totalCancelledFormatted: e.totalCancelledFormatted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_payouts': totalPayouts,
      'completed_count': completedCount,
      'pending_count': pendingCount,
      'processing_count': processingCount,
      'total_withdrawn': totalWithdrawn,
      'total_withdrawn_formatted': totalWithdrawnFormatted,
      'total_cancelled': totalCancelled,
      'total_cancelled_formatted': totalCancelledFormatted,
    };
  }
}

// ============================================
// HELPERS DE PARSING
// ============================================

int _parseInt(dynamic value, {int defaultValue = 0}) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? defaultValue;
  return defaultValue;
}

double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
  if (value == null) return defaultValue;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? defaultValue;
  return defaultValue;
}

String _parseString(dynamic value, [String defaultValue = '']) {
  if (value == null) return defaultValue;
  return value.toString();
}

String? _parseNullableString(dynamic value) {
  if (value == null) return null;
  final str = value.toString();
  return str.isEmpty ? null : str;
}

bool _parseBool(dynamic value, {bool defaultValue = false}) {
  if (value == null) return defaultValue;
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) {
    final lower = value.toLowerCase();
    return lower == 'true' || lower == '1' || lower == 'yes';
  }
  return defaultValue;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

/// Parse une couleur hexadécimale en int.
///
/// Accepte "#F59E0B", "F59E0B", "#FFF59E0B"
int _parseColorHex(dynamic value, {int defaultValue = 0xFF6B7280}) {
  if (value == null) return defaultValue;

  try {
    String hex = value.toString().replaceFirst('#', '').trim();
    if (hex.isEmpty) return defaultValue;
    if (hex.length == 6) hex = 'FF$hex';
    if (hex.length == 8) return int.parse(hex, radix: 16);
    return defaultValue;
  } catch (_) {
    return defaultValue;
  }
}

/// Convertit un int couleur en string hex.
String _colorHexToString(int colorHex) {
  final hex = colorHex.toRadixString(16).padLeft(8, '0');
  if (hex.startsWith('ff')) {
    return '#${hex.substring(2)}';
  }
  return '#$hex';
}