// ============================================
// MODEL : SellerNotificationModel
// ============================================
// Sérialisation JSON pour SellerNotification.
//
// Responsabilités :
//   - Parser la réponse API /seller/notifications
//   - Convertir la couleur hex en int
//   - Convertir le type de notification
//   - Gérer les valeurs null (parsing défensif)
// ============================================

import '../../domain/entities/seller_notification.dart';

// ============================================
// MODEL PRINCIPAL
// ============================================

class SellerNotificationModel extends SellerNotification {
  const SellerNotificationModel({
    required super.id,
    required super.type,
    required super.typeLabel,
    required super.icon,
    required super.colorHex,
    required super.title,
    required super.message,
    required super.isRead,
    super.readAt,
    super.actionUrl,
    super.data,
    super.createdAt,
    super.createdAtHuman,
  });

  // ============================================
  // JSON → MODEL
  // ============================================

  factory SellerNotificationModel.fromJson(Map<String, dynamic> json) {
    return SellerNotificationModel(
      id: _parseString(json['id']),
      type: SellerNotificationType.fromCode(json['type'] as String?),
      typeLabel: _parseString(json['type_label'], 'Notification'),
      icon: _parseString(json['icon'], 'notifications'),
      colorHex: _parseColorHex(json['color']),
      title: _parseString(json['title'], 'Notification'),
      message: _parseString(json['message']),
      isRead: _parseBool(json['is_read']),
      readAt: _parseDate(json['read_at']),
      actionUrl: _parseNullableString(json['action_url']),
      data: _parseData(json['data']),
      createdAt: _parseDate(json['created_at']),
      createdAtHuman: _parseNullableString(json['created_at_human']),
    );
  }

  // ============================================
  // MODEL → JSON
  // ============================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.code,
      'type_label': typeLabel,
      'icon': icon,
      'color': _colorHexToString(colorHex),
      'title': title,
      'message': message,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'action_url': actionUrl,
      'data': data,
      'created_at': createdAt?.toIso8601String(),
      'created_at_human': createdAtHuman,
    };
  }

  // ============================================
  // fromEntity
  // ============================================

  factory SellerNotificationModel.fromEntity(SellerNotification entity) {
    return SellerNotificationModel(
      id: entity.id,
      type: entity.type,
      typeLabel: entity.typeLabel,
      icon: entity.icon,
      colorHex: entity.colorHex,
      title: entity.title,
      message: entity.message,
      isRead: entity.isRead,
      readAt: entity.readAt,
      actionUrl: entity.actionUrl,
      data: entity.data,
      createdAt: entity.createdAt,
      createdAtHuman: entity.createdAtHuman,
    );
  }
}

// ============================================
// MODEL : SellerNotificationsStatsModel
// ============================================

class SellerNotificationsStatsModel extends SellerNotificationsStats {
  const SellerNotificationsStatsModel({
    super.total,
    super.unread,
    super.read,
  });

  factory SellerNotificationsStatsModel.fromJson(Map<String, dynamic> json) {
    return SellerNotificationsStatsModel(
      total: _parseInt(json['total']),
      unread: _parseInt(json['unread']),
      read: _parseInt(json['read']),
    );
  }

  factory SellerNotificationsStatsModel.fromEntity(
    SellerNotificationsStats entity,
  ) {
    return SellerNotificationsStatsModel(
      total: entity.total,
      unread: entity.unread,
      read: entity.read,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'unread': unread,
      'read': read,
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
/// Accepte les formats :
///   - "#3B82F6" (avec #)
///   - "3B82F6" (sans #)
///   - "#FF3B82F6" (avec alpha)
int _parseColorHex(dynamic value, {int defaultValue = 0xFF6B7280}) {
  if (value == null) return defaultValue;

  try {
    String hex = value.toString().replaceFirst('#', '').trim();

    if (hex.isEmpty) return defaultValue;

    // Si pas d'alpha (6 chars), ajouter FF
    if (hex.length == 6) {
      hex = 'FF$hex';
    }

    // Si alpha (8 chars), garder tel quel
    if (hex.length == 8) {
      return int.parse(hex, radix: 16);
    }

    return defaultValue;
  } catch (e) {
    return defaultValue;
  }
}

/// Convertit un int couleur en string hex.
String _colorHexToString(int colorHex) {
  final hex = colorHex.toRadixString(16).padLeft(8, '0');
  // Si alpha est FF, ne garder que les 6 derniers caractères
  if (hex.startsWith('ff')) {
    return '#${hex.substring(2)}';
  }
  return '#$hex';
}

/// Parse le payload `data` (Map sécurisée).
Map<String, dynamic> _parseData(dynamic value) {
  if (value is! Map) return const {};

  final result = <String, dynamic>{};
  value.forEach((key, val) {
    if (key is String) {
      // Filtrer les champs potentiellement dangereux
      if (key == 'token' ||
          key == 'access_token' ||
          key == 'password' ||
          key == 'api_key') {
        return;
      }
      result[key] = val;
    }
  });

  return result;
}