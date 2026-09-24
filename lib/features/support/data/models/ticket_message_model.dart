// ============================================
// MODÈLE TICKET MESSAGE (DATA) - VERSION PREMIUM
// ============================================
// Gère la sérialisation/désérialisation JSON
// avec parsing robuste et valeurs par défaut.
// ============================================

import '../../domain/entities/ticket_message.dart';

class TicketMessageModel extends TicketMessage {
  const TicketMessageModel({
    required super.id,
    required super.supportTicketId,
    super.userId,
    required super.message,
    super.attachment,
    super.senderType,
    super.isRead,
    super.readAt,
    super.createdAt,
    super.updatedAt,
  });

  /// Créer depuis JSON
  factory TicketMessageModel.fromJson(Map<String, dynamic> json) {
    return TicketMessageModel(
      id: _parseInt(json['id']),
      supportTicketId: _parseInt(json['support_ticket_id']),
      userId: _parseNullableInt(json['user_id']),
      message: _parseString(json['message']),
      attachment: _parseNullableString(json['attachment']),
      senderType: _parseString(json['sender_type'], defaultValue: 'user'),
      isRead: _parseBool(json['is_read']),
      readAt: _parseDate(json['read_at']),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  /// Convertir en JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'support_ticket_id': supportTicketId,
      'user_id': userId,
      'message': message,
      'attachment': attachment,
      'sender_type': senderType,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Copier depuis l'entité
  static TicketMessageModel fromEntity(TicketMessage message) {
    return TicketMessageModel(
      id: message.id,
      supportTicketId: message.supportTicketId,
      userId: message.userId,
      message: message.message,
      attachment: message.attachment,
      senderType: message.senderType,
      isRead: message.isRead,
      readAt: message.readAt,
      createdAt: message.createdAt,
      updatedAt: message.updatedAt,
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

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
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