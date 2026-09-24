// ============================================
// ENTITÉ FAQ (DOMAINE) - VERSION PREMIUM
// ============================================
// Représente une question fréquente avec
// catégorie, popularité et compteurs.
// Design ShopPro.
// ============================================

class Faq {
  final int id;
  final int? faqCategoryId;
  final String question;
  final String answer;
  final String slug;
  final bool isActive;
  final bool isPopular;
  final int sortOrder;
  final int viewsCount;
  final int helpfulCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Faq({
    required this.id,
    this.faqCategoryId,
    required this.question,
    required this.answer,
    required this.slug,
    this.isActive = true,
    this.isPopular = false,
    this.sortOrder = 0,
    this.viewsCount = 0,
    this.helpfulCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  // ============================================
  // VALIDATION
  // ============================================

  /// La FAQ a-t-elle des données valides ?
  bool get isValid {
    return id > 0 && question.isNotEmpty && answer.isNotEmpty;
  }

  /// La FAQ est-elle populaire ?
  bool get isPopularFaq => isPopular;

  /// La FAQ a-t-elle été utile ?
  bool get hasHelpfulVotes => helpfulCount > 0;

  /// La FAQ a-t-elle été consultée ?
  bool get hasViews => viewsCount > 0;

  // ============================================
  // FORMATAGE
  // ============================================

  /// Nombre de vues formaté
  String get formattedViewsCount {
    if (viewsCount >= 1000) {
      return '${(viewsCount / 1000).toStringAsFixed(1)}k';
    }
    return '$viewsCount';
  }

  /// Nombre de votes utiles formaté
  String get formattedHelpfulCount {
    if (helpfulCount >= 1000) {
      return '${(helpfulCount / 1000).toStringAsFixed(1)}k';
    }
    return '$helpfulCount';
  }

  // ============================================
  // MÉTHODES
  // ============================================

  /// Copier avec modifications
  Faq copyWith({
    int? id,
    int? faqCategoryId,
    String? question,
    String? answer,
    String? slug,
    bool? isActive,
    bool? isPopular,
    int? sortOrder,
    int? viewsCount,
    int? helpfulCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Faq(
      id: id ?? this.id,
      faqCategoryId: faqCategoryId ?? this.faqCategoryId,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      slug: slug ?? this.slug,
      isActive: isActive ?? this.isActive,
      isPopular: isPopular ?? this.isPopular,
      sortOrder: sortOrder ?? this.sortOrder,
      viewsCount: viewsCount ?? this.viewsCount,
      helpfulCount: helpfulCount ?? this.helpfulCount,
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
      'faq_category_id': faqCategoryId,
      'question': question,
      'answer': answer,
      'slug': slug,
      'is_active': isActive,
      'is_popular': isPopular,
      'sort_order': sortOrder,
      'views_count': viewsCount,
      'helpful_count': helpfulCount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Faq.fromJson(Map<String, dynamic> json) {
    return Faq(
      id: json['id'] as int? ?? 0,
      faqCategoryId: json['faq_category_id'] as int?,
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
      isPopular: json['is_popular'] as bool? ?? false,
      sortOrder: json['sort_order'] as int? ?? 0,
      viewsCount: json['views_count'] as int? ?? 0,
      helpfulCount: json['helpful_count'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
    );
  }

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'Faq(id: $id, question: $question, '
        'popular: $isPopular, views: $viewsCount, helpful: $helpfulCount)';
  }
}