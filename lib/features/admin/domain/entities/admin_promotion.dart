// ============================================
// ENTITÉ : AdminPromotion
// ============================================
// Représente une promotion vue depuis le backoffice admin.
// Cette entité est pure (pas de dépendances Flutter) et contient
// toutes les informations nécessaires pour la gestion des promotions :
// - Type de promotion (réduction, BOGO, bundle, vente flash)
// - Période de validité
// - Règles de réduction
// - Statistiques d'utilisation
// ============================================

/// Type de promotion disponible
enum AdminPromotionType {
  discount('discount', 'Réduction'),
  bogo('bogo', 'Achetez-en 1, obtenez-en 1'),
  bundle('bundle', 'Pack/Package'),
  flashSale('flash_sale', 'Vente Flash'),
  clearance('clearance', 'Liquidation');

  final String code;
  final String displayName;

  const AdminPromotionType(this.code, this.displayName);

  static AdminPromotionType fromCode(String? code) {
    return AdminPromotionType.values.firstWhere(
      (type) => type.code == code,
      orElse: () => AdminPromotionType.discount,
    );
  }
}

/// Type de réduction appliquée
enum AdminDiscountType {
  percentage('percentage', 'Pourcentage (%)'),
  fixed('fixed', 'Montant fixe (FCFA)');

  final String code;
  final String displayName;

  const AdminDiscountType(this.code, this.displayName);

  static AdminDiscountType fromCode(String? code) {
    return AdminDiscountType.values.firstWhere(
      (type) => type.code == code,
      orElse: () => AdminDiscountType.percentage,
    );
  }
}

/// Statut d'une promotion
enum AdminPromotionStatus {
  upcoming('upcoming', 'À venir'),
  active('active', 'Active'),
  expired('expired', 'Expirée'),
  paused('paused', 'En pause'),
  cancelled('cancelled', 'Annulée');

  final String code;
  final String displayName;

  const AdminPromotionStatus(this.code, this.displayName);

  static AdminPromotionStatus fromCode(String? code) {
    return AdminPromotionStatus.values.firstWhere(
      (status) => status.code == code,
      orElse: () => AdminPromotionStatus.upcoming,
    );
  }
}

/// Entité représentant une promotion pour l'administration
class AdminPromotion {
  // ============================================
  // INFORMATIONS DE BASE
  // ============================================

  /// Identifiant unique
  final int id;

  /// Nom de la promotion
  final String name;

  /// Slug unique (URL)
  final String slug;

  /// Description détaillée
  final String? description;

  /// Type de promotion
  final AdminPromotionType type;

  /// Type de réduction
  final AdminDiscountType discountType;

  /// Valeur de la réduction (pourcentage ou montant)
  final double discountValue;

  // ============================================
  // PÉRIODE DE VALIDITÉ
  // ============================================

  /// Date de début
  final DateTime startDate;

  /// Date de fin
  final DateTime endDate;

  // ============================================
  // RÈGLES DE RÉDUCTION
  // ============================================

  /// Montant minimum de commande pour bénéficier de la promotion
  final double minimumOrder;

  /// Limite d'utilisation (null = illimitée)
  final int? usageLimit;

  /// Nombre d'utilisations actuel
  final int usageCount;

  /// Limite d'utilisation par utilisateur (null = illimitée)
  final int? usagePerUser;

  // ============================================
  // BANNIÈRES ET IMAGES
  // ============================================

  /// Bannière desktop
  final String? banner;

  /// Bannière mobile
  final String? bannerMobile;

  // ============================================
  // STATUT
  // ============================================

  /// Statut actuel
  final AdminPromotionStatus status;

  /// Promotion active ?
  final bool isActive;

  /// Promotion mise en avant ?
  final bool isFeatured;

  /// Afficher le compte à rebours ?
  final bool showCountdown;

  // ============================================
  // STATISTIQUES
  // ============================================

  /// Nombre total de produits concernés
  final int productsCount;

  /// Revenu total généré par la promotion
  final double totalRevenue;

  /// Nombre total de commandes utilisant la promotion
  final int ordersCount;

  /// Économie totale pour les clients
  final double totalSavings;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  const AdminPromotion({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.type,
    required this.discountType,
    required this.discountValue,
    required this.startDate,
    required this.endDate,
    this.minimumOrder = 0,
    this.usageLimit,
    this.usageCount = 0,
    this.usagePerUser,
    this.banner,
    this.bannerMobile,
    this.status = AdminPromotionStatus.upcoming,
    this.isActive = true,
    this.isFeatured = false,
    this.showCountdown = true,
    this.productsCount = 0,
    this.totalRevenue = 0,
    this.ordersCount = 0,
    this.totalSavings = 0,
  });

  // ============================================
  // GETTERS CALCULÉS
  // ============================================

  /// Vrai si la promotion est en cours
  bool get isCurrentlyActive {
    final now = DateTime.now();
    return now.isAfter(startDate) &&
        now.isBefore(endDate) &&
        isActive &&
        status == AdminPromotionStatus.active;
  }

  /// Vrai si la promotion est à venir
  bool get isUpcoming {
    final now = DateTime.now();
    return now.isBefore(startDate) && isActive;
  }

  /// Vrai si la promotion est expirée
  bool get isExpired {
    final now = DateTime.now();
    return now.isAfter(endDate) || status == AdminPromotionStatus.expired;
  }

  /// Vrai si la promotion est en pause
  bool get isPaused => status == AdminPromotionStatus.paused;

  /// Vrai si la promotion est annulée
  bool get isCancelled => status == AdminPromotionStatus.cancelled;

  /// Durée de la promotion en jours
  int get durationInDays {
    return endDate.difference(startDate).inDays;
  }

  /// Jours restants avant la fin
  int get daysRemaining {
    if (isExpired) return 0;
    return endDate.difference(DateTime.now()).inDays;
  }

  /// Jours restants avant le début
  int get daysUntilStart {
    if (isCurrentlyActive || isExpired) return 0;
    return startDate.difference(DateTime.now()).inDays;
  }

  /// Pourcentage d'utilisation (si limitée)
  double? get usagePercentage {
    if (usageLimit == null || usageLimit == 0) return null;
    return (usageCount / usageLimit!) * 100;
  }

  /// Vrai si la limite d'utilisation est atteinte
  bool get isUsageLimitReached {
    if (usageLimit == null) return false;
    return usageCount >= usageLimit!;
  }

  /// Vrai si la promotion est presque expirée (moins de 3 jours)
  bool get isExpiringSoon {
    return isCurrentlyActive && daysRemaining <= 3;
  }

  /// Vrai si la promotion est presque pleine (plus de 80% utilisée)
  bool get isAlmostFull {
    final percentage = usagePercentage;
    return percentage != null && percentage >= 80;
  }

  /// Formatage de la valeur de réduction
  String get discountValueFormatted {
    if (discountType == AdminDiscountType.percentage) {
      return '${discountValue.round()}%';
    }
    return _formatCurrency(discountValue);
  }

  /// Formatage du montant minimum
  String get minimumOrderFormatted {
    if (minimumOrder == 0) return 'Aucun minimum';
    return _formatCurrency(minimumOrder);
  }

  /// Formatage du revenu total
  String get totalRevenueFormatted => _formatCurrency(totalRevenue);

  /// Formatage des économies totales
  String get totalSavingsFormatted => _formatCurrency(totalSavings);

  /// Formatage de la date de début
  String get startDateFormatted => _formatDate(startDate);

  /// Formatage de la date de fin
  String get endDateFormatted => _formatDate(endDate);

  /// Formatage de la période complète
  String get periodFormatted => '$startDateFormatted → $endDateFormatted';

  /// Formatage du statut avec emoji
  String get statusWithIcon {
    switch (status) {
      case AdminPromotionStatus.upcoming:
        return '⏳ ${status.displayName}';
      case AdminPromotionStatus.active:
        return '✅ ${status.displayName}';
      case AdminPromotionStatus.expired:
        return '❌ ${status.displayName}';
      case AdminPromotionStatus.paused:
        return '⏸️ ${status.displayName}';
      case AdminPromotionStatus.cancelled:
        return '🚫 ${status.displayName}';
    }
  }

  /// Vrai si la promotion a un minimum de commande
  bool get hasMinimumOrder => minimumOrder > 0;

  /// Vrai si la promotion est limitée
  bool get hasUsageLimit => usageLimit != null;

  /// Vrai si la promotion a des bannières
  bool get hasBanner => banner != null && banner!.isNotEmpty;

  // ============================================
  // HELPERS PRIVÉS
  // ============================================

  /// Formate un montant en FCFA avec séparateurs de milliers
  String _formatCurrency(double amount) {
    final buffer = StringBuffer();
    final amountStr = amount.round().toString();

    for (int i = 0; i < amountStr.length; i++) {
      buffer.write(amountStr[i]);
      final remaining = amountStr.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write(' ');
      }
    }

    return '$buffer FCFA';
  }

  /// Formate une date en format lisible
  
  String _formatDate(DateTime? date) {
    if (date == null) return '';
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }


  // ============================================
  // SERIALIZATION
  // ============================================

  /// Convertit l'entité en Map pour la sérialisation
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'type': type.code,
      'discount_type': discountType.code,
      'discount_value': discountValue,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'minimum_order': minimumOrder,
      'usage_limit': usageLimit,
      'usage_count': usageCount,
      'usage_per_user': usagePerUser,
      'banner': banner,
      'banner_mobile': bannerMobile,
      'status': status.code,
      'is_active': isActive,
      'is_featured': isFeatured,
      'show_countdown': showCountdown,
      'products_count': productsCount,
      'total_revenue': totalRevenue,
      'orders_count': ordersCount,
      'total_savings': totalSavings,
    };
  }

  /// Crée une entité à partir d'une Map
  factory AdminPromotion.fromJson(Map<String, dynamic> json) {
    return AdminPromotion(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      type: AdminPromotionType.fromCode(json['type'] as String?),
      discountType: AdminDiscountType.fromCode(json['discount_type'] as String?),
      discountValue: (json['discount_value'] as num?)?.toDouble() ?? 0,
      startDate: DateTime.tryParse(json['start_date'] as String? ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] as String? ?? '') ?? DateTime.now(),
      minimumOrder: (json['minimum_order'] as num?)?.toDouble() ?? 0,
      usageLimit: (json['usage_limit'] as num?)?.toInt(),
      usageCount: (json['usage_count'] as num?)?.toInt() ?? 0,
      usagePerUser: (json['usage_per_user'] as num?)?.toInt(),
      banner: json['banner'] as String?,
      bannerMobile: json['banner_mobile'] as String?,
      status: AdminPromotionStatus.fromCode(json['status'] as String?),
      isActive: json['is_active'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,
      showCountdown: json['show_countdown'] as bool? ?? true,
      productsCount: (json['products_count'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0,
      ordersCount: (json['orders_count'] as num?)?.toInt() ?? 0,
      totalSavings: (json['total_savings'] as num?)?.toDouble() ?? 0,
    );
  }

  // ============================================
  // COPYWITH
  // ============================================

  /// Crée une copie avec des champs modifiés
  AdminPromotion copyWith({
    int? id,
    String? name,
    String? slug,
    String? description,
    AdminPromotionType? type,
    AdminDiscountType? discountType,
    double? discountValue,
    DateTime? startDate,
    DateTime? endDate,
    double? minimumOrder,
    int? usageLimit,
    int? usageCount,
    int? usagePerUser,
    String? banner,
    String? bannerMobile,
    AdminPromotionStatus? status,
    bool? isActive,
    bool? isFeatured,
    bool? showCountdown,
    int? productsCount,
    double? totalRevenue,
    int? ordersCount,
    double? totalSavings,
  }) {
    return AdminPromotion(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      type: type ?? this.type,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      minimumOrder: minimumOrder ?? this.minimumOrder,
      usageLimit: usageLimit ?? this.usageLimit,
      usageCount: usageCount ?? this.usageCount,
      usagePerUser: usagePerUser ?? this.usagePerUser,
      banner: banner ?? this.banner,
      bannerMobile: bannerMobile ?? this.bannerMobile,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      showCountdown: showCountdown ?? this.showCountdown,
      productsCount: productsCount ?? this.productsCount,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      ordersCount: ordersCount ?? this.ordersCount,
      totalSavings: totalSavings ?? this.totalSavings,
    );
  }

  // ============================================
  // ÉGALITÉ ET HASHCODE
  // ============================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdminPromotion &&
        other.id == id &&
        other.slug == slug;
  }

  @override
  int get hashCode => Object.hash(id, slug);

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'AdminPromotion(id: $id, name: $name, type: ${type.displayName}, '
        'discount: $discountValueFormatted, status: ${status.displayName}, '
        'period: $periodFormatted, used: $usageCount/${usageLimit ?? '∞'})';
  }
}