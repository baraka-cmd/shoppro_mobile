// ============================================
// MODÈLE APP NOTIFICATION (DATA) - PREMIUM
// ============================================
// Gère la sérialisation/désérialisation JSON
// avec parsing robuste et valeurs par défaut.
// ============================================

import '../../domain/entities/app_notification.dart';

class AppNotificationModel extends AppNotification {
  const AppNotificationModel({
    required super.id,
    required super.title,
    required super.body,
    super.type,
    super.imageUrl,
    super.targetType,
    super.targetId,
    super.isRead,
    super.readAt,
    required super.createdAt,
    super.isArchived,
  });

  /// Créer depuis JSON
  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: _parseInt(json['id']),
      title: _parseString(json['title']),
      body: _parseString(json['body']),
      type: _parseString(json['type'], defaultValue: 'system'),
      imageUrl: _parseNullableString(json['image_url']),
      targetType: _parseNullableString(json['target_type']),
      targetId: _parseNullableString(json['target_id']),
      isRead: _parseBool(json['is_read']),
      readAt: _parseDate(json['read_at']),
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      isArchived: _parseBool(json['is_archived']),
    );
  }

  /// Convertir en JSON
  @override
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

  /// Copier depuis l'entité
  static AppNotificationModel fromEntity(AppNotification notification) {
    return AppNotificationModel(
      id: notification.id,
      title: notification.title,
      body: notification.body,
      type: notification.type,
      imageUrl: notification.imageUrl,
      targetType: notification.targetType,
      targetId: notification.targetId,
      isRead: notification.isRead,
      readAt: notification.readAt,
      createdAt: notification.createdAt,
      isArchived: notification.isArchived,
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

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}