// ============================================
// MODEL : AdminNotificationModel
// ============================================
// Modèle de sérialisation pour les notifications système.
// Cette classe est dans la couche DATA et gère la conversion
// JSON ↔ Entité (AdminNotification).
//
// Responsabilités :
// - Conversion JSON → AdminNotification (fromJson)
// - Conversion AdminNotification → JSON (toJson)
// - Conversion AdminNotification → AdminNotificationModel (fromEntity)
// - Conversion AdminNotificationModel → AdminNotification (toEntity)
// ============================================

// ============================================
// IMPORTS
// ============================================

// Dart
import 'dart:convert';

// Flutter
import 'package:flutter/material.dart';

// Entities (même feature admin)
import '../../domain/entities/admin_notification.dart';

// ============================================
// CLASSE PRINCIPALE
// ============================================

/// Modèle de données pour [AdminNotification].
///
/// Cette classe étend [AdminNotification] et ajoute les méthodes
/// de sérialisation JSON nécessaires pour l'API.
class AdminNotificationModel extends AdminNotification {
  // ============================================
  // CONSTRUCTEUR
  // ============================================

  const AdminNotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required super.type,
    super.priority,
    required super.createdAt,
    super.isRead,
    super.readAt,
    super.isArchived,
    super.archivedAt,
    super.targetType,
    super.targetId,
    super.targetUrl,
    super.image,
    super.icon,
    super.metadata,
  });

  // ============================================
  // CONVERSION : ENTITÉ → MODÈLE
  // ============================================

  /// Crée un modèle à partir d'une entité.
  factory AdminNotificationModel.fromEntity(AdminNotification entity) {
    return AdminNotificationModel(
      id: entity.id,
      title: entity.title,
      body: entity.body,
      type: entity.type,
      priority: entity.priority,
      createdAt: entity.createdAt,
      isRead: entity.isRead,
      readAt: entity.readAt,
      isArchived: entity.isArchived,
      archivedAt: entity.archivedAt,
      targetType: entity.targetType,
      targetId: entity.targetId,
      targetUrl: entity.targetUrl,
      image: entity.image,
      icon: entity.icon,
      metadata: entity.metadata,
    );
  }

  // ============================================
  // CONVERSION : JSON → MODÈLE
  // ============================================

  /// Crée un modèle à partir d'une Map JSON.
  ///
  /// Gère toutes les conversions de types sécurisées.
  factory AdminNotificationModel.fromJson(Map<String, dynamic> json) {
    // Parse des métadonnées
    final metadata = _parseMetadata(json['metadata']);

    return AdminNotificationModel(
      // Informations de base
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      type: AdminNotificationType.fromCode(json['type'] as String?),
      priority: AdminNotificationPriority.fromCode(json['priority'] as String?),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),

      // Statut de lecture
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] != null
          ? DateTime.tryParse(json['read_at'] as String)
          : null,
      isArchived: json['is_archived'] as bool? ?? false,
      archivedAt: json['archived_at'] != null
          ? DateTime.tryParse(json['archived_at'] as String)
          : null,

      // Données associées
      targetType: json['target_type'] as String?,
      targetId: (json['target_id'] as num?)?.toInt(),
      targetUrl: json['target_url'] as String?,
      image: json['image'] as String?,
      icon: json['icon'] as String?,
      metadata: metadata,
    );
  }

  // ============================================
  // CONVERSION : MODÈLE → JSON
  // ============================================

  /// Convertit le modèle en Map JSON.
  @override
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

  // ============================================
  // CONVERSION : MODÈLE → ENTITÉ
  // ============================================

  /// Convertit le modèle en entité pure.
  AdminNotification toEntity() {
    return AdminNotification(
      id: id,
      title: title,
      body: body,
      type: type,
      priority: priority,
      createdAt: createdAt,
      isRead: isRead,
      readAt: readAt,
      isArchived: isArchived,
      archivedAt: archivedAt,
      targetType: targetType,
      targetId: targetId,
      targetUrl: targetUrl,
      image: image,
      icon: icon,
      metadata: metadata,
    );
  }

  // ============================================
  // HELPERS DE PARSING
  // ============================================

  /// Parse les métadonnées depuis le JSON.
  ///
  /// Gère les cas :
  /// - null → null
  /// - Map → Map<String, dynamic>
  /// - String JSON → Map<String, dynamic>
  /// - Autre → null
  static Map<String, dynamic>? _parseMetadata(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    if (data is String && data.isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  // ============================================
  // HELPERS DE CRÉATION
  // ============================================

  /// Crée une notification de nouvelle commande.
  factory AdminNotificationModel.createNewOrder({
    required String orderNumber,
    required double total,
    int? targetId,
  }) {
    return AdminNotificationModel(
      id: 0,
      title: 'Nouvelle commande',
      body: 'Commande $orderNumber reçue - Total: $total FCFA',
      type: AdminNotificationType.newOrder,
      priority: AdminNotificationPriority.high,
      createdAt: DateTime.now(),
      targetType: 'order',
      targetId: targetId,
      metadata: {
        'order_number': orderNumber,
        'total': total,
      },
    );
  }

  /// Crée une notification de stock faible.
  factory AdminNotificationModel.createLowStock({
    required String productName,
    required int currentStock,
    required int minStock,
    int? targetId,
  }) {
    return AdminNotificationModel(
      id: 0,
      title: 'Stock faible',
      body: '$productName - Stock: $currentStock (minimum: $minStock)',
      type: AdminNotificationType.lowStock,
      priority: AdminNotificationPriority.high,
      createdAt: DateTime.now(),
      targetType: 'product',
      targetId: targetId,
      metadata: {
        'product_name': productName,
        'current_stock': currentStock,
        'min_stock': minStock,
      },
    );
  }

  /// Crée une notification de rupture de stock.
  factory AdminNotificationModel.createOutOfStock({
    required String productName,
    int? targetId,
  }) {
    return AdminNotificationModel(
      id: 0,
      title: 'Rupture de stock',
      body: '$productName est en rupture de stock',
      type: AdminNotificationType.outOfStock,
      priority: AdminNotificationPriority.urgent,
      createdAt: DateTime.now(),
      targetType: 'product',
      targetId: targetId,
      metadata: {
        'product_name': productName,
      },
    );
  }

  /// Crée une notification de nouvel avis.
  factory AdminNotificationModel.createNewReview({
    required String userName,
    required String productName,
    required int rating,
    int? targetId,
  }) {
    return AdminNotificationModel(
      id: 0,
      title: 'Nouvel avis',
      body: '$userName a noté $productName : $rating/5 ⭐',
      type: AdminNotificationType.newReview,
      priority: AdminNotificationPriority.medium,
      createdAt: DateTime.now(),
      targetType: 'review',
      targetId: targetId,
      metadata: {
        'user_name': userName,
        'product_name': productName,
        'rating': rating,
      },
    );
  }

  /// Crée une notification de nouvel utilisateur.
  factory AdminNotificationModel.createNewUser({
    required String userName,
    int? targetId,
  }) {
    return AdminNotificationModel(
      id: 0,
      title: 'Nouvel utilisateur',
      body: '$userName vient de s\'inscrire',
      type: AdminNotificationType.newUser,
      priority: AdminNotificationPriority.low,
      createdAt: DateTime.now(),
      targetType: 'user',
      targetId: targetId,
      metadata: {
        'user_name': userName,
      },
    );
  }

  /// Crée une notification de paiement reçu.
  factory AdminNotificationModel.createPaymentReceived({
    required String orderNumber,
    required double amount,
    int? targetId,
  }) {
    return AdminNotificationModel(
      id: 0,
      title: 'Paiement reçu',
      body: 'Paiement reçu pour $orderNumber : $amount FCFA',
      type: AdminNotificationType.paymentReceived,
      priority: AdminNotificationPriority.medium,
      createdAt: DateTime.now(),
      targetType: 'payment',
      targetId: targetId,
      metadata: {
        'order_number': orderNumber,
        'amount': amount,
      },
    );
  }

  // ============================================
  // VALIDATION
  // ============================================

  /// Vérifie si le titre est valide.
  bool get hasValidTitle => title.trim().isNotEmpty;

  /// Vérifie si le corps est valide.
  bool get hasValidBody => body.trim().isNotEmpty;

  /// Vérifie si la notification est complète et valide.
  bool get isValid => hasValidTitle && hasValidBody;

  /// Vérifie si la notification peut être marquée comme lue.
  bool get canBeMarkedAsRead => !isRead;

  /// Vérifie si la notification peut être marquée comme non lue.
  bool get canBeMarkedAsUnread => isRead;

  /// Vérifie si la notification peut être archivée.
  bool get canBeArchived => !isArchived;

  /// Vérifie si la notification peut être désarchivée.
  bool get canBeUnarchived => isArchived;

  // ============================================
  // COPYWITH
  // ============================================

  /// Crée une copie avec des champs modifiés.
  @override
  AdminNotificationModel copyWith({
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
    return AdminNotificationModel(
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
    return other is AdminNotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'AdminNotificationModel(id: $id, title: $title, '
        'type: ${type.displayName}, priority: ${priority.displayName}, '
        'read: $isRead, valid: $isValid)';
  }
}