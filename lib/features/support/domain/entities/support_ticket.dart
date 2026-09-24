// ============================================
// ENTITÉ SUPPORT TICKET (DOMAINE) - VERSION PREMIUM
// ============================================
// Représente un ticket de support client.
// Adapté à la table support_tickets existante.
// Design ShopPro.
// ============================================

class SupportTicket {
  final int id;
  final String ticketNumber;
  final int userId;
  final int? orderId;
  final String subject;
  final String description;
  final String category;
  final String priority;
  final String status;
  final int? assignedTo;
  final DateTime? resolvedAt;
  final DateTime? closedAt;
  final DateTime? lastReplyAt;
  final int? satisfactionRating;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SupportTicket({
    required this.id,
    required this.ticketNumber,
    required this.userId,
    this.orderId,
    required this.subject,
    required this.description,
    this.category = 'other',
    this.priority = 'medium',
    this.status = 'open',
    this.assignedTo,
    this.resolvedAt,
    this.closedAt,
    this.lastReplyAt,
    this.satisfactionRating,
    this.createdAt,
    this.updatedAt,
  });

  // ============================================
  // LABELS
  // ============================================

  /// Label de la catégorie
  String get categoryLabel {
    switch (category) {
      case 'order':
        return 'Commande';
      case 'payment':
        return 'Paiement';
      case 'delivery':
        return 'Livraison';
      case 'product':
        return 'Produit';
      case 'account':
        return 'Compte';
      case 'technical':
        return 'Technique';
      case 'other':
        return 'Autre';
      default:
        return 'Autre';
    }
  }

  /// Label du statut
  String get statusLabel {
    switch (status) {
      case 'open':
        return 'Ouvert';
      case 'pending':
        return 'En attente';
      case 'resolved':
        return 'Résolu';
      case 'closed':
        return 'Fermé';
      case 'reopened':
        return 'Rouvert';
      default:
        return 'Ouvert';
    }
  }

  /// Label de la priorité
  String get priorityLabel {
    switch (priority) {
      case 'low':
        return 'Basse';
      case 'medium':
        return 'Moyenne';
      case 'high':
        return 'Haute';
      case 'urgent':
        return 'Urgente';
      default:
        return 'Moyenne';
    }
  }

  // ============================================
  // COULEURS (HEX)
  // ============================================

  /// Couleur du statut
  int get statusColorHex {
    switch (status) {
      case 'open':
        return 0xFF087F5B; // Emerald
      case 'pending':
        return 0xFFF4B942; // Gold
      case 'resolved':
        return 0xFF3B82F6; // Bleu
      case 'closed':
        return 0xFF68756F; // Gris
      case 'reopened':
        return 0xFFFF6B6B; // Coral
      default:
        return 0xFF68756F;
    }
  }

  /// Couleur de la priorité
  int get priorityColorHex {
    switch (priority) {
      case 'low':
        return 0xFF68756F; // Gris
      case 'medium':
        return 0xFF3B82F6; // Bleu
      case 'high':
        return 0xFFF4B942; // Gold
      case 'urgent':
        return 0xFFFF6B6B; // Coral
      default:
        return 0xFF68756F;
    }
  }

  // ============================================
  // ÉTATS
  // ============================================

  /// Le ticket est-il ouvert ?
  bool get isOpen => status == 'open';

  /// Le ticket est-il en attente ?
  bool get isPending => status == 'pending';

  /// Le ticket est-il résolu ?
  bool get isResolved => status == 'resolved';

  /// Le ticket est-il fermé ?
  bool get isClosed => status == 'closed';

  /// Le ticket est-il rouvert ?
  bool get isReopened => status == 'reopened';

  /// Le ticket est-il actif ?
  bool get isActive => status == 'open' || status == 'pending' || status == 'reopened';

  // ============================================
  // VALIDATION
  // ============================================

  /// Le ticket a-t-il des données valides ?
  bool get isValid {
    return id > 0 &&
        ticketNumber.isNotEmpty &&
        subject.isNotEmpty &&
        description.isNotEmpty;
  }

  /// Le ticket a-t-il une commande liée ?
  bool get hasOrder => orderId != null;

  /// Le ticket a-t-il une note de satisfaction ?
  bool get hasSatisfactionRating => satisfactionRating != null;

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

  // ============================================
  // MÉTHODES
  // ============================================

  /// Copier avec modifications
  SupportTicket copyWith({
    int? id,
    String? ticketNumber,
    int? userId,
    int? orderId,
    String? subject,
    String? description,
    String? category,
    String? priority,
    String? status,
    int? assignedTo,
    DateTime? resolvedAt,
    DateTime? closedAt,
    DateTime? lastReplyAt,
    int? satisfactionRating,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupportTicket(
      id: id ?? this.id,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      userId: userId ?? this.userId,
      orderId: orderId ?? this.orderId,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      closedAt: closedAt ?? this.closedAt,
      lastReplyAt: lastReplyAt ?? this.lastReplyAt,
      satisfactionRating: satisfactionRating ?? this.satisfactionRating,
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

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'] as int? ?? 0,
      ticketNumber: json['ticket_number'] as String? ?? '',
      userId: json['user_id'] as int? ?? 0,
      orderId: json['order_id'] as int?,
      subject: json['subject'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'other',
      priority: json['priority'] as String? ?? 'medium',
      status: json['status'] as String? ?? 'open',
      assignedTo: json['assigned_to'] as int?,
      resolvedAt: DateTime.tryParse(json['resolved_at'] as String? ?? ''),
      closedAt: DateTime.tryParse(json['closed_at'] as String? ?? ''),
      lastReplyAt: DateTime.tryParse(json['last_reply_at'] as String? ?? ''),
      satisfactionRating: json['satisfaction_rating'] as int?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
    );
  }

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'SupportTicket(id: $id, number: $ticketNumber, '
        'status: $statusLabel, category: $categoryLabel, '
        'priority: $priorityLabel)';
  }
}