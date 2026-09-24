// ============================================
// ENTITÉ TICKET MESSAGE (DOMAINE) - VERSION PREMIUM
// ============================================
// Représente un message dans un ticket de support.
// Design ShopPro.
// ============================================

class TicketMessage {
  final int id;
  final int supportTicketId;
  final int? userId;
  final String message;
  final String? attachment;
  final String senderType;
  final bool isRead;
  final DateTime? readAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TicketMessage({
    required this.id,
    required this.supportTicketId,
    this.userId,
    required this.message,
    this.attachment,
    this.senderType = 'user',
    this.isRead = false,
    this.readAt,
    this.createdAt,
    this.updatedAt,
  });

  // ============================================
  // LABEL DE L'EXPÉDITEUR
  // ============================================

  String get senderLabel {
    switch (senderType) {
      case 'user':
        return 'Vous';
      case 'admin':
        return 'Support ShopPro';
      case 'system':
        return 'Système';
      default:
        return 'Utilisateur';
    }
  }

  // ============================================
  // ÉTATS
  // ============================================

  /// Le message est-il de l'utilisateur ?
  bool get isFromUser => senderType == 'user';

  /// Le message est-il de l'admin ?
  bool get isFromAdmin => senderType == 'admin';

  /// Le message est-il du système ?
  bool get isFromSystem => senderType == 'system';

  /// Le message est-il lu ?
  bool get isReadMessage => isRead;

  /// Le message a-t-il une pièce jointe ?
  bool get hasAttachment => attachment != null && attachment!.isNotEmpty;

  // ============================================
  // COULEUR DE L'EXPÉDITEUR (HEX)
  // ============================================

  int get senderColorHex {
    switch (senderType) {
      case 'user':
        return 0xFF087F5B; // Emerald
      case 'admin':
        return 0xFF3B82F6; // Bleu
      case 'system':
        return 0xFF68756F; // Gris
      default:
        return 0xFF68756F;
    }
  }

  // ============================================
  // VALIDATION
  // ============================================

  /// Le message a-t-il des données valides ?
  bool get isValid {
    return id > 0 && supportTicketId > 0 && message.isNotEmpty;
  }

  // ============================================
  // FORMATAGE
  // ============================================

  /// Date relative
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt ?? now);

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
    if (createdAt == null) return '';
    return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year} à '
        '${createdAt!.hour}:${createdAt!.minute.toString().padLeft(2, '0')}';
  }

  // ============================================
  // MÉTHODES
  // ============================================

  /// Copier avec modifications
  TicketMessage copyWith({
    int? id,
    int? supportTicketId,
    int? userId,
    String? message,
    String? attachment,
    String? senderType,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TicketMessage(
      id: id ?? this.id,
      supportTicketId: supportTicketId ?? this.supportTicketId,
      userId: userId ?? this.userId,
      message: message ?? this.message,
      attachment: attachment ?? this.attachment,
      senderType: senderType ?? this.senderType,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ============================================
  // JSON
  // ============================================

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

  factory TicketMessage.fromJson(Map<String, dynamic> json) {
    return TicketMessage(
      id: json['id'] as int? ?? 0,
      supportTicketId: json['support_ticket_id'] as int? ?? 0,
      userId: json['user_id'] as int?,
      message: json['message'] as String? ?? '',
      attachment: json['attachment'] as String?,
      senderType: json['sender_type'] as String? ?? 'user',
      isRead: json['is_read'] as bool? ?? false,
      readAt: DateTime.tryParse(json['read_at'] as String? ?? ''),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
    );
  }

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'TicketMessage(id: $id, ticket: $supportTicketId, '
        'sender: $senderLabel, read: $isRead)';
  }
}