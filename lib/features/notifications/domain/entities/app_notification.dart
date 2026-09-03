// ============================================
// ENTITÉ APP NOTIFICATION (DOMAINE) - PREMIUM
// ============================================
// Représente une notification dans l'application
// avec types métier, destination et actions.
// Design ShopPro.
// ============================================

class AppNotification {
  final int id;
  final String title;
  final String body;
  final String type;
  final String? imageUrl;
  final String? targetType;
  final String? targetId;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  final bool isArchived;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.type = 'system',
    this.imageUrl,
    this.targetType,
    this.targetId,
    this.isRead = false,
    this.readAt,
    required this.createdAt,
    this.isArchived = false,
  });

  // ============================================
  // TYPES DE NOTIFICATIONS
  // ============================================

  /// Types métier disponibles
  static const String typeOrder = 'order';
  static const String typePromotion = 'promotion';
  static const String typePriceAlert = 'price_alert';
  static const String typeStockAlert = 'stock_alert';
  static const String typeDelivery = 'delivery';
  static const String typeSystem = 'system';

  /// Liste des types valides
  static const List<String> validTypes = [
    typeOrder,
    typePromotion,
    typePriceAlert,
    typeStockAlert,
    typeDelivery,
    typeSystem,
  ];

  // ============================================
  // LABEL DU TYPE
  // ============================================

  String get typeLabel {
    switch (type) {
      case typeOrder:
        return 'Commande';
      case typePromotion:
        return 'Promotion';
      case typePriceAlert:
        return 'Alerte prix';
      case typeStockAlert:
        return 'Retour en stock';
      case typeDelivery:
        return 'Livraison';
      case typeSystem:
        return 'Système';
      default:
        return type;
    }
  }

  // ============================================
  // EMOJI DU TYPE
  // ============================================

  String get typeEmoji {
    switch (type) {
      case typeOrder:
        return '🛒';
      case typePromotion:
        return '🎉';
      case typePriceAlert:
        return '🔔';
      case typeStockAlert:
        return '📦';
      case typeDelivery:
        return '🚚';
      case typeSystem:
        return '⚙️';
      default:
        return '🔔';
    }
  }

  // ============================================
  // COULEUR DU TYPE (HEX)
  // ============================================

  int get typeColorHex {
    switch (type) {
      case typeOrder:
        return 0xFF3B82F6; // Bleu
      case typePromotion:
        return 0xFFF4B942; // Gold
      case typePriceAlert:
        return 0xFFFF6B6B; // Coral
      case typeStockAlert:
        return 0xFF087F5B; // Emerald
      case typeDelivery:
        return 0xFF20C997; // Mint
      case typeSystem:
        return 0xFF68756F; // Gris
      default:
        return 0xFF68756F;
    }
  }

  // ============================================
  // DESTINATION / ACTION
  // ============================================

  /// Route de navigation selon le type
  String get navigationRoute {
    switch (type) {
      case typeOrder:
      case typeDelivery:
        return '/order/detail';
      case typePriceAlert:
      case typeStockAlert:
        return '/product/detail';
      case typePromotion:
        return '/product/list';
      case typeSystem:
      default:
        return '/profile';
    }
  }

  /// La notification a-t-elle une destination ?
  bool get hasDestination =>
      targetType != null && targetId != null && targetId!.isNotEmpty;

  /// La notification est-elle actionnable ?
  bool get isActionable => hasDestination || navigationRoute.isNotEmpty;

  // ============================================
  // ÉTAT DE LECTURE
  // ============================================

  /// Date relative
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} an(s)';
    }
    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} mois';
    }
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

  /// Date complète formatée
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui';
    }
    if (difference.inDays == 1) {
      return 'Hier';
    }
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  /// La notification est-elle récente (moins de 24h) ?
  bool get isRecent {
    return DateTime.now().difference(createdAt).inHours < 24;
  }

  // ============================================
  // VALIDATION
  // ============================================

  /// La notification a-t-elle des données valides ?
  bool get isValid {
    return id > 0 && title.isNotEmpty && body.isNotEmpty;
  }

  /// Le type est-il valide ?
  bool get hasValidType => validTypes.contains(type);

  // ============================================
  // MÉTHODES
  // ============================================

  /// Marquer comme lue
  AppNotification markAsRead() {
    return copyWith(
      isRead: true,
      readAt: DateTime.now(),
    );
  }

  /// Marquer comme non lue
  AppNotification markAsUnread() {
    return copyWith(
      isRead: false,
      readAt: null,
    );
  }

  /// Archiver
  AppNotification archive() {
    return copyWith(isArchived: true);
  }

  /// Désarchiver
  AppNotification unarchive() {
    return copyWith(isArchived: false);
  }

  /// Copier avec modifications
  AppNotification copyWith({
    int? id,
    String? title,
    String? body,
    String? type,
    String? imageUrl,
    String? targetType,
    String? targetId,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
    bool? isArchived,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  // ============================================
  // JSON
  // ============================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'image_url': imageUrl,
      'target_type': targetType,
      'target_id': targetId,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'is_archived': isArchived,
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      type: json['type'] as String? ?? 'system',
      imageUrl: json['image_url'] as String?,
      targetType: json['target_type'] as String?,
      targetId: json['target_id'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      readAt: DateTime.tryParse(json['read_at'] as String? ?? ''),
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      isArchived: json['is_archived'] as bool? ?? false,
    );
  }

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'AppNotification(id: $id, type: $typeLabel, '
        'title: $title, read: $isRead, archived: $isArchived, '
        'createdAt: $relativeTime)';
  }
}