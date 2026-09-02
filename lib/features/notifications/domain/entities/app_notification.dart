// Entité AppNotification (Domaine)
// Représente une notification dans l'application

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
  });

  /// Label du type
  String get typeLabel {
    switch (type) {
      case 'order':
        return 'Commande';
      case 'promotion':
        return 'Promotion';
      case 'delivery':
        return 'Livraison';
      case 'price_alert':
        return 'Alerte prix';
      case 'system':
        return 'Système';
      default:
        return type;
    }
  }

  /// Icône du type
  String get typeIcon {
    switch (type) {
      case 'order':
        return '🛒';
      case 'promotion':
        return '🎉';
      case 'delivery':
        return '📦';
      case 'price_alert':
        return '💰';
      case 'system':
        return '⚙️';
      default:
        return '🔔';
    }
  }

  /// Couleur du type
  int get typeColor {
    switch (type) {
      case 'order':
        return 0xFF3498DB;
      case 'promotion':
        return 0xFFE67E22;
      case 'delivery':
        return 0xFF27AE60;
      case 'price_alert':
        return 0xFFE74C3C;
      case 'system':
        return 0xFF7F8C8D;
      default:
        return 0xFF7F8C8D;
    }
  }

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
    );
  }

  /// Convertir en JSON
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
    };
  }

  /// Créer depuis JSON
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
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}