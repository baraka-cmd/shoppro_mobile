// ============================================
// ENTITÉ : AdminNotification
// ============================================
// Représente une notification système pour l'administration.
// Cette entité est pure (pas de dépendances Flutter) et contient
// toutes les informations nécessaires pour la gestion des notifications :
// - Type de notification (commande, stock, avis, système)
// - Priorité
// - Statut de lecture
// - Données associées
// ============================================

/// Type d'une notification admin
enum AdminNotificationType {
  newOrder('new_order', 'Nouvelle commande'),
  lowStock('low_stock', 'Stock faible'),
  outOfStock('out_of_stock', 'Rupture de stock'),
  newReview('new_review', 'Nouvel avis'),
  newUser('new_user', 'Nouvel utilisateur'),
  paymentReceived('payment_received', 'Paiement reçu'),
  paymentFailed('payment_failed', 'Paiement échoué'),
  orderCancelled('order_cancelled', 'Commande annulée'),
  orderReturned('order_returned', 'Commande retournée'),
  refundRequest('refund_request', 'Demande de remboursement'),
  system('system', 'Système'),
  security('security', 'Sécurité'),
  error('error', 'Erreur');

  final String code;
  final String displayName;

  const AdminNotificationType(this.code, this.displayName);

  static AdminNotificationType fromCode(String? code) {
    return AdminNotificationType.values.firstWhere(
      (type) => type.code == code,
      orElse: () => AdminNotificationType.system,
    );
  }
}

/// Priorité d'une notification
enum AdminNotificationPriority {
  low('low', 'Basse'),
  medium('medium', 'Moyenne'),
  high('high', 'Haute'),
  urgent('urgent', 'Urgente');

  final String code;
  final String displayName;

  const AdminNotificationPriority(this.code, this.displayName);

  static AdminNotificationPriority fromCode(String? code) {
    return AdminNotificationPriority.values.firstWhere(
      (priority) => priority.code == code,
      orElse: () => AdminNotificationPriority.medium,
    );
  }
}

/// Entité représentant une notification administrateur
class AdminNotification {
  // ============================================
  // INFORMATIONS DE BASE
  // ============================================

  /// Identifiant unique
  final int id;

  /// Titre de la notification
  final String title;

  /// Corps de la notification
  final String body;

  /// Type de notification
  final AdminNotificationType type;

  /// Priorité de la notification
  final AdminNotificationPriority priority;

  /// Date de création
  final DateTime createdAt;

  // ============================================
  // STATUT DE LECTURE
  // ============================================

  /// Notification lue ?
  final bool isRead;

  /// Date de lecture
  final DateTime? readAt;

  /// Notification archivée ?
  final bool isArchived;

  /// Date d'archivage
  final DateTime? archivedAt;

  // ============================================
  // DONNÉES ASSOCIÉES
  // ============================================

  /// Type de la cible (ex: "order", "product", "user")
  final String? targetType;

  /// Identifiant de la cible
  final int? targetId;

  /// URL de navigation associée
  final String? targetUrl;

  /// Image associée
  final String? image;

  /// Icône associée
  final String? icon;

  /// Données supplémentaires (JSON)
  final Map<String, dynamic>? metadata;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  const AdminNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.priority = AdminNotificationPriority.medium,
    required this.createdAt,
    this.isRead = false,
    this.readAt,
    this.isArchived = false,
    this.archivedAt,
    this.targetType,
    this.targetId,
    this.targetUrl,
    this.image,
    this.icon,
    this.metadata,
  });

  // ============================================
  // GETTERS CALCULÉS
  // ============================================

  /// Vrai si la notification n'est pas lue
  bool get isUnread => !isRead;

  /// Vrai si la notification est archivée
  bool get isArchivedNotification => isArchived;

  /// Vrai si la notification est urgente
  bool get isUrgent => priority == AdminNotificationPriority.urgent;

  /// Vrai si la notification est haute priorité
  bool get isHighPriority => priority == AdminNotificationPriority.high;

  /// Vrai si la notification est basse priorité
  bool get isLowPriority => priority == AdminNotificationPriority.low;

  /// Vrai si la notification a une cible
  bool get hasTarget => targetType != null && targetId != null;

  /// Vrai si la notification a une URL
  bool get hasUrl => targetUrl != null && targetUrl!.isNotEmpty;

  /// Vrai si la notification a une image
  bool get hasImage => image != null && image!.isNotEmpty;

  /// Vrai si la notification a une icône
  bool get hasIcon => icon != null && icon!.isNotEmpty;

  /// Vrai si la notification a des métadonnées
  bool get hasMetadata => metadata != null && metadata!.isNotEmpty;

  /// Vrai si la notification est récente (moins de 1 heure)
  bool get isRecent {
    final difference = DateTime.now().difference(createdAt);
    return difference.inHours < 1;
  }

  /// Vrai si la notification est vieille (plus de 7 jours)
  bool get isOld {
    final difference = DateTime.now().difference(createdAt);
    return difference.inDays >= 7;
  }

  /// Icône par défaut selon le type
  String get defaultIcon {
    switch (type) {
      case AdminNotificationType.newOrder:
        return '🛒';
      case AdminNotificationType.lowStock:
        return '⚠️';
      case AdminNotificationType.outOfStock:
        return '❌';
      case AdminNotificationType.newReview:
        return '⭐';
      case AdminNotificationType.newUser:
        return '👤';
      case AdminNotificationType.paymentReceived:
        return '💰';
      case AdminNotificationType.paymentFailed:
        return '💳';
      case AdminNotificationType.orderCancelled:
        return '🚫';
      case AdminNotificationType.orderReturned:
        return '📦';
      case AdminNotificationType.refundRequest:
        return '💸';
      case AdminNotificationType.system:
        return '⚙️';
      case AdminNotificationType.security:
        return '🔒';
      case AdminNotificationType.error:
        return '🚨';
    }
  }

  /// Couleur par défaut selon la priorité
  String get priorityColor {
    switch (priority) {
      case AdminNotificationPriority.low:
        return '#7F8C8D'; // Gris
      case AdminNotificationPriority.medium:
        return '#3498DB'; // Bleu
      case AdminNotificationPriority.high:
        return '#F39C12'; // Orange
      case AdminNotificationPriority.urgent:
        return '#E74C3C'; // Rouge
    }
  }

  /// Couleur par défaut selon le type
  String get typeColor {
    switch (type) {
      case AdminNotificationType.newOrder:
        return '#3498DB'; // Bleu
      case AdminNotificationType.lowStock:
        return '#F39C12'; // Orange
      case AdminNotificationType.outOfStock:
        return '#E74C3C'; // Rouge
      case AdminNotificationType.newReview:
        return '#27AE60'; // Vert
      case AdminNotificationType.newUser:
        return '#9B59B6'; // Violet
      case AdminNotificationType.paymentReceived:
        return '#27AE60'; // Vert
      case AdminNotificationType.paymentFailed:
        return '#E74C3C'; // Rouge
      case AdminNotificationType.orderCancelled:
        return '#E74C3C'; // Rouge
      case AdminNotificationType.orderReturned:
        return '#F39C12'; // Orange
      case AdminNotificationType.refundRequest:
        return '#E67E22'; // Orange foncé
      case AdminNotificationType.system:
        return '#7F8C8D'; // Gris
      case AdminNotificationType.security:
        return '#E74C3C'; // Rouge
      case AdminNotificationType.error:
        return '#E74C3C'; // Rouge
    }
  }

  /// Type avec emoji
  String get typeWithIcon => '$defaultIcon ${type.displayName}';

  /// Priorité avec emoji
  String get priorityWithIcon {
    switch (priority) {
      case AdminNotificationPriority.low:
        return '🟢 ${priority.displayName}';
      case AdminNotificationPriority.medium:
        return '🔵 ${priority.displayName}';
      case AdminNotificationPriority.high:
        return '🟠 ${priority.displayName}';
      case AdminNotificationPriority.urgent:
        return '🔴 ${priority.displayName}';
    }
  }

  /// Statut de lecture avec emoji
  String get readStatusWithIcon {
    if (isArchived) return '📁 Archivée';
    if (isRead) return '✅ Lue';
    return '🔵 Non lue';
  }

  /// Extrait court du corps (pour les listes)
  String get shortBody {
    if (body.length <= 150) return body;
    return '${body.substring(0, 150)}...';
  }

  /// Formatage de la date de création
  String get createdAtFormatted => _formatDate(createdAt);

  /// Formatage de la date de lecture
  String get readAtFormatted {
    if (readAt == null) return 'Non lue';
    return _formatDate(readAt!);
  }

  /// Temps écoulé depuis la création
  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);
    
    if (difference.inMinutes < 1) return "à l'instant";
    if (difference.inMinutes < 60) return 'il y a ${difference.inMinutes} min';
    if (difference.inHours < 24) return 'il y a ${difference.inHours} h';
    if (difference.inDays < 7) return 'il y a ${difference.inDays} j';
    if (difference.inDays < 30) return 'il y a ${(difference.inDays / 7).floor()} sem';
    if (difference.inDays < 365) return 'il y a ${(difference.inDays / 30).floor()} mois';
    return 'il y a ${(difference.inDays / 365).floor()} an(s)';
  }

  // ============================================
  // HELPERS PRIVÉS
  // ============================================

  /// Formate une date en format lisible
  String _formatDate(DateTime date) {
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year} '
        'à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // ============================================
  // SERIALIZATION
  // ============================================

  /// Convertit l'entité en Map pour la sérialisation
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.code,
      'priority': priority.code,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'is_archived': isArchived,
      'archived_at': archivedAt?.toIso8601String(),
      'target_type': targetType,
      'target_id': targetId,
      'target_url': targetUrl,
      'image': image,
      'icon': icon,
      'metadata': metadata,
    };
  }

  /// Crée une entité à partir d'une Map
  factory AdminNotification.fromJson(Map<String, dynamic> json) {
    return AdminNotification(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      type: AdminNotificationType.fromCode(json['type'] as String?),
      priority: AdminNotificationPriority.fromCode(json['priority'] as String?),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] != null
          ? DateTime.tryParse(json['read_at'] as String)
          : null,
      isArchived: json['is_archived'] as bool? ?? false,
      archivedAt: json['archived_at'] != null
          ? DateTime.tryParse(json['archived_at'] as String)
          : null,
      targetType: json['target_type'] as String?,
      targetId: (json['target_id'] as num?)?.toInt(),
      targetUrl: json['target_url'] as String?,
      image: json['image'] as String?,
      icon: json['icon'] as String?,
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
    );
  }

  // ============================================
  // COPYWITH
  // ============================================

  /// Crée une copie avec des champs modifiés
  AdminNotification copyWith({
    int? id,
    String? title,
    String? body,
    AdminNotificationType? type,
    AdminNotificationPriority? priority,
    DateTime? createdAt,
    bool? isRead,
    DateTime? readAt,
    bool? isArchived,
    DateTime? archivedAt,
    String? targetType,
    int? targetId,
    String? targetUrl,
    String? image,
    String? icon,
    Map<String, dynamic>? metadata,
  }) {
    return AdminNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      isArchived: isArchived ?? this.isArchived,
      archivedAt: archivedAt ?? this.archivedAt,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      targetUrl: targetUrl ?? this.targetUrl,
      image: image ?? this.image,
      icon: icon ?? this.icon,
      metadata: metadata ?? this.metadata,
    );
  }

  // ============================================
  // ÉGALITÉ ET HASHCODE
  // ============================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdminNotification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'AdminNotification(id: $id, title: $title, '
        'type: ${type.displayName}, priority: ${priority.displayName}, '
        'read: $isRead, time: $timeAgo)';
  }
}