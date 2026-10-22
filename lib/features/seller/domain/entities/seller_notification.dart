// ============================================
// ENTITÉ : SellerNotification
// ============================================
// Représente une notification vendeur.
//
// Types supportés :
//   - new_order        : Nouvelle commande reçue
//   - order_status_changed : Statut de commande modifié
//   - new_review       : Nouvel avis client
//   - low_stock        : Alerte stock bas / rupture
//   - payout_received  : Versement reçu
//   - kyc_validated    : KYC validé
//   - kyc_rejected     : KYC refusé
//
// Aucune dépendance Flutter : entité PURE Dart.
// ============================================

// ============================================
// ENUM : SellerNotificationType
// ============================================
// Types de notifications vendeur.
// ============================================

enum SellerNotificationType {
  newOrder('new_order', 'Nouvelle commande'),
  orderStatusChanged('order_status_changed', 'Commande'),
  newReview('new_review', 'Avis client'),
  lowStock('low_stock', 'Stock'),
  payoutReceived('payout_received', 'Versement'),
  kycValidated('kyc_validated', 'KYC validé'),
  kycRejected('kyc_rejected', 'KYC refusé'),
  general('general', 'Notification');

  final String code;
  final String displayName;

  const SellerNotificationType(this.code, this.displayName);

  static SellerNotificationType fromCode(String? code) {
    return SellerNotificationType.values.firstWhere(
      (type) => type.code == code,
      orElse: () => SellerNotificationType.general,
    );
  }
}

// ============================================
// ENTITÉ PRINCIPALE : SellerNotification
// ============================================

class SellerNotification {
  // ============================================
  // IDENTIFIANTS
  // ============================================
  final String id;

  // ============================================
  // TYPE
  // ============================================
  final SellerNotificationType type;
  final String typeLabel;
  final String icon;
  final int colorHex;

  // ============================================
  // CONTENU
  // ============================================
  final String title;
  final String message;

  // ============================================
  // ÉTAT DE LECTURE
  // ============================================
  final bool isRead;
  final DateTime? readAt;

  // ============================================
  // ACTION
  // ============================================
  final String? actionUrl;

  // ============================================
  // PAYLOAD SPÉCIFIQUE (selon le type)
  // ============================================
  final Map<String, dynamic> data;

  // ============================================
  // HORODATAGE
  // ============================================
  final DateTime? createdAt;
  final String? createdAtHuman;

  const SellerNotification({
    required this.id,
    required this.type,
    required this.typeLabel,
    required this.icon,
    required this.colorHex,
    required this.title,
    required this.message,
    required this.isRead,
    this.readAt,
    this.actionUrl,
    this.data = const {},
    this.createdAt,
    this.createdAtHuman,
  });

  // ============================================
  // GETTERS ÉTAT
  // ============================================

  bool get isUnread => !isRead;

  // ============================================
  // GETTERS DATA (accès sécurisé)
  // ============================================

  /// Order ID (si type = new_order)
  int? get orderId => _getInt('order_id');

  /// Order number (si type = new_order)
  String? get orderNumber => _getString('order_number');

  /// Amount (si type = new_order ou payout)
  double? get amount => _getDouble('amount');

  /// Customer name (si type = new_order ou new_review)
  String? get customerName => _getString('customer_name');

  /// Product name (si type = low_stock ou new_review)
  String? get productName => _getString('product_name');

  /// Product SKU (si type = low_stock)
  String? get productSku => _getString('product_sku');

  /// Stock ID (si type = low_stock)
  int? get stockId => _getInt('stock_id');

  /// Available quantity (si type = low_stock)
  int? get availableQuantity => _getInt('available_quantity');

  /// Min quantity (si type = low_stock)
  int? get minQuantity => _getInt('min_quantity');

  /// Review ID (si type = new_review)
  int? get reviewId => _getInt('review_id');

  /// Rating (si type = new_review)
  int? get rating => _getInt('rating');

  /// Payout ID (si type = payout_received)
  int? get payoutId => _getInt('payout_id');

  /// Amount formatted (si type = payout)
  String? get amountFormatted => _getString('amount_formatted');

  /// KYC rejection reason (si type = kyc_rejected)
  String? get rejectionReason => _getString('rejection_reason');

  // ============================================
  // HELPERS
  // ============================================

  int? _getInt(String key) {
    final value = data[key];
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  double? _getDouble(String key) {
    final value = data[key];
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  String? _getString(String key) {
    final value = data[key];
    if (value == null) return null;
    final str = value.toString();
    return str.isEmpty ? null : str;
  }

  // ============================================
  // COPYWITH
  // ============================================

  SellerNotification copyWith({
    String? id,
    SellerNotificationType? type,
    String? typeLabel,
    String? icon,
    int? colorHex,
    String? title,
    String? message,
    bool? isRead,
    DateTime? readAt,
    String? actionUrl,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    String? createdAtHuman,
  }) {
    return SellerNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      typeLabel: typeLabel ?? this.typeLabel,
      icon: icon ?? this.icon,
      colorHex: colorHex ?? this.colorHex,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      actionUrl: actionUrl ?? this.actionUrl,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      createdAtHuman: createdAtHuman ?? this.createdAtHuman,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SellerNotification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'SellerNotification(id: $id, type: ${type.displayName}, '
        'isRead: $isRead)';
  }
}

// ============================================
// ENTITÉ : SellerNotificationsStats
// ============================================
// Statistiques globales des notifications.
// ============================================

class SellerNotificationsStats {
  final int total;
  final int unread;
  final int read;

  const SellerNotificationsStats({
    this.total = 0,
    this.unread = 0,
    this.read = 0,
  });

  const SellerNotificationsStats.empty()
      : total = 0,
        unread = 0,
        read = 0;

  bool get hasUnread => unread > 0;
  bool get hasNotifications => total > 0;

  /// Label du badge (ex: "99+").
  String get badgeLabel {
    if (unread > 99) return '99+';
    return unread.toString();
  }

  @override
  String toString() {
    return 'SellerNotificationsStats(total: $total, unread: $unread)';
  }
}