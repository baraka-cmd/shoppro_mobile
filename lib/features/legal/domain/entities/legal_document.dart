// ============================================
// ENTITÉ LEGAL DOCUMENT (DOMAINE) - PREMIUM
// ============================================
// Représente un document légal versionné.
// Design ShopPro.
// ============================================

class LegalDocument {
  final int id;
  final String title;
  final String slug;
  final String type;
  final String content;
  final String version;
  final DateTime? publishedAt;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const LegalDocument({
    required this.id,
    required this.title,
    required this.slug,
    required this.type,
    required this.content,
    this.version = '1.0.0',
    this.publishedAt,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  // ============================================
  // TYPES DE DOCUMENTS
  // ============================================

  static const String typeTermsConditions = 'terms_conditions';
  static const String typePrivacyPolicy = 'privacy_policy';
  static const String typeRefundPolicy = 'refund_policy';
  static const String typeShippingPolicy = 'shipping_policy';
  static const String typeAbout = 'about';
  static const String typeOther = 'other';

  // ============================================
  // LABEL DU TYPE
  // ============================================

  String get typeLabel {
    switch (type) {
      case typeTermsConditions:
        return 'Conditions d\'utilisation';
      case typePrivacyPolicy:
        return 'Politique de confidentialité';
      case typeRefundPolicy:
        return 'Politique de remboursement';
      case typeShippingPolicy:
        return 'Politique de livraison';
      case typeAbout:
        return 'À propos';
      case typeOther:
        return 'Autre';
      default:
        return 'Document';
    }
  }

  // ============================================
  // VALIDATION
  // ============================================

  bool get isValid {
    return id > 0 && title.isNotEmpty && content.isNotEmpty;
  }

  /// Le document est-il publié ?
  bool get isPublished {
    return isActive && publishedAt != null && publishedAt!.isBefore(DateTime.now());
  }

  // ============================================
  // FORMATAGE
  // ============================================

  /// Date de publication formatée
  String get formattedPublishedAt {
    if (publishedAt == null) return 'Non publié';
    return '${publishedAt!.day}/${publishedAt!.month}/${publishedAt!.year}';
  }

  // ============================================
  // MÉTHODES
  // ============================================

  LegalDocument copyWith({
    int? id,
    String? title,
    String? slug,
    String? type,
    String? content,
    String? version,
    DateTime? publishedAt,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LegalDocument(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      type: type ?? this.type,
      content: content ?? this.content,
      version: version ?? this.version,
      publishedAt: publishedAt ?? this.publishedAt,
      isActive: isActive ?? this.isActive,
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
      'title': title,
      'slug': slug,
      'type': type,
      'content': content,
      'version': version,
      'published_at': publishedAt?.toIso8601String(),
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory LegalDocument.fromJson(Map<String, dynamic> json) {
    return LegalDocument(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      type: json['type'] as String? ?? 'other',
      content: json['content'] as String? ?? '',
      version: json['version'] as String? ?? '1.0.0',
      publishedAt: DateTime.tryParse(json['published_at'] as String? ?? ''),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
    );
  }

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'LegalDocument(id: $id, title: $title, '
        'type: $typeLabel, version: $version, published: $isPublished)';
  }
}