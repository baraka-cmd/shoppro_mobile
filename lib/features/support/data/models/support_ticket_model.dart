// ============================================
// MODÈLE SUPPORT TICKET (DATA) - VERSION PREMIUM
// ============================================
// Gère la sérialisation/désérialisation JSON
// avec parsing robuste et valeurs par défaut.
// ============================================

import '../../domain/entities/support_ticket.dart';

class SupportTicketModel extends SupportTicket {
  const SupportTicketModel({
    required super.id,
    required super.ticketNumber,
    required super.userId,
    super.orderId,
    required super.subject,
    required super.description,
    super.category,
    super.priority,
    super.status,
    super.assignedTo,
    super.resolvedAt,
    super.closedAt,
    super.lastReplyAt,
    super.satisfactionRating,
    super.createdAt,
    super.updatedAt,
  });

  /// Créer depuis JSON
  factory SupportTicketModel.fromJson(Map<String, dynamic> json) {
    return SupportTicketModel(
      id: _parseInt(json['id']),
      ticketNumber: _parseString(json['ticket_number']),
      userId: _parseInt(json['user_id']),
      orderId: _parseNullableInt(json['order_id']),
      subject: _parseString(json['subject']),
      description: _parseString(json['description']),
      category: _parseString(json['category'], defaultValue: 'other'),
      priority: _parseString(json['priority'], defaultValue: 'medium'),
      status: _parseString(json['status'], defaultValue: 'open'),
      assignedTo: _parseNullableInt(json['assigned_to']),
      resolvedAt: _parseDate(json['resolved_at']),
      closedAt: _parseDate(json['closed_at']),
      lastReplyAt: _parseDate(json['last_reply_at']),
      satisfactionRating: _parseNullableInt(json['satisfaction_rating']),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  /// Convertir en JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_number': ticketNumber,
      'user_id': userId,
      'order_id': orderId,
      'subject': subject,
      'description': description,
      'category': category,
      'priority': priority,
      'status': status,
      'assigned_to': assignedTo,
      'resolved_at': resolvedAt?.toIso8601String(),
      'closed_at': closedAt?.toIso8601String(),
      'last_reply_at': lastReplyAt?.toIso8601String(),
      'satisfaction_rating': satisfactionRating,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Copier depuis l'entité
  static SupportTicketModel fromEntity(SupportTicket ticket) {
    return SupportTicketModel(
      id: ticket.id,
      ticketNumber: ticket.ticketNumber,
      userId: ticket.userId,
      orderId: ticket.orderId,
      subject: ticket.subject,
      description: ticket.description,
      category: ticket.category,
      priority: ticket.priority,
      status: ticket.status,
      assignedTo: ticket.assignedTo,
      resolvedAt: ticket.resolvedAt,
      closedAt: ticket.closedAt,
      lastReplyAt: ticket.lastReplyAt,
      satisfactionRating: ticket.satisfactionRating,
      createdAt: ticket.createdAt,
      updatedAt: ticket.updatedAt,
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

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}