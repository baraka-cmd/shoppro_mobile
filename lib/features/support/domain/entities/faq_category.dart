// ============================================
// ENTITÉ FAQ CATEGORY (DOMAINE) - VERSION PREMIUM
// ============================================
// Représente une catégorie de questions fréquentes.
// Design ShopPro.
// ============================================

class FaqCategory {
  final int id;
  final String name;
  final String slug;
  final String? icon;
  final String? description;
  final int sortOrder;
  final bool isActive;
  final int faqsCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const FaqCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
    this.description,
    this.sortOrder = 0,
    this.isActive = true,
    this.faqsCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  // ============================================
  // VALIDATION
  // ============================================

  /// La catégorie a-t-elle des données valides ?
  bool get isValid {
    return id > 0 && name.isNotEmpty && slug.isNotEmpty;
  }

  /// La catégorie a-t-elle une icône ?
  bool get hasIcon => icon != null && icon!.isNotEmpty;

  /// La catégorie a-t-elle une description ?
  bool get hasDescription => description != null && description!.isNotEmpty;

  /// La catégorie a-t-elle des FAQs ?
  bool get hasFaqs => faqsCount > 0;

  // ============================================
  // FORMATAGE
  // ============================================

  /// Nombre de FAQs formaté
  String get formattedFaqsCount {
    if (faqsCount >= 1000) {
      return '${(faqsCount / 1000).toStringAsFixed(1)}k';
    }
    return '$faqsCount';
  }

  // ============================================
  // MÉTHODES
  // ============================================

  /// Copier avec modifications
  FaqCategory copyWith({
    int? id,
    String? name,
    String? slug,
    String? icon,
    String? description,
    int? sortOrder,
    bool? isActive,
    int? faqsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FaqCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      faqsCount: faqsCount ?? this.faqsCount,
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
      'name': name,
      'slug': slug,
      'icon': icon,
      'description': description,
      'sort_order': sortOrder,
      'is_active': isActive,
      'faqs_count': faqsCount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory FaqCategory.fromJson(Map<String, dynamic> json) {
    return FaqCategory(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      icon: json['icon'] as String?,
      description: json['description'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      faqsCount: json['faqs_count'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
    );
  }

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'FaqCategory(id: $id, name: $name, '
        'faqs: $faqsCount, active: $isActive)';
  }
}