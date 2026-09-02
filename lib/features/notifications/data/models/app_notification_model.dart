// Modèle AppNotification (Data)
// Gère la sérialisation/désérialisation JSON de la notification

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
  });

  /// Créer depuis JSON
  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
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
    };
  }
}