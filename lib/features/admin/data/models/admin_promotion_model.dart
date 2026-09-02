// ============================================
// MODEL : AdminPromotionModel
// ============================================
// Modèle de sérialisation pour les promotions administrées.
// Cette classe est dans la couche DATA et gère la conversion
// JSON ↔ Entité (AdminPromotion).
//
// Responsabilités :
// - Conversion JSON → AdminPromotion (fromJson)
// - Conversion AdminPromotion → JSON (toJson)
// - Conversion AdminPromotion → AdminPromotionModel (fromEntity)
// - Conversion AdminPromotionModel → AdminPromotion (toEntity)
// ============================================

// ============================================
// IMPORTS
// ============================================

// Flutter
import 'package:flutter/material.dart';

// Entities (même feature admin)
import '../../domain/entities/admin_promotion.dart';

// ============================================
// CLASSE PRINCIPALE
// ============================================

/// Modèle de données pour [AdminPromotion].
///
/// Cette classe étend [AdminPromotion] et ajoute les méthodes
/// de sérialisation JSON nécessaires pour l'API.
class AdminPromotionModel extends AdminPromotion {
  // ============================================
  // CONSTRUCTEUR
  // ============================================

  const AdminPromotionModel({
    required super.id,
    required super.name,
    required super.slug,
    super.description,
    required super.type,
    required super.discountType,
    required super.discountValue,
    required super.startDate,
    required super.endDate,
    super.minimumOrder,
    super.usageLimit,
    super.usageCount,
    super.usagePerUser,
    super.banner,
    super.bannerMobile,
    super.status,
    super.isActive,
    super.isFeatured,
    super.showCountdown,
    super.productsCount,
    super.totalRevenue,
    super.ordersCount,
    super.totalSavings,
  });

  // ============================================
  // CONVERSION : ENTITÉ → MODÈLE
  // ============================================

  /// Crée un modèle à partir d'une entité.
  factory AdminPromotionModel.fromEntity(AdminPromotion entity) {
    return AdminPromotionModel(
      id: entity.id,
      name: entity.name,
      slug: entity.slug,
      description: entity.description,
      type: entity.type,
      discountType: entity.discountType,
      discountValue: entity.discountValue,
      startDate: entity.startDate,
      endDate: entity.endDate,
      minimumOrder: entity.minimumOrder,
      usageLimit: entity.usageLimit,
      usageCount: entity.usageCount,
      usagePerUser: entity.usagePerUser,
      banner: entity.banner,
      bannerMobile: entity.bannerMobile,
      status: entity.status,
      isActive: entity.isActive,
      isFeatured: entity.isFeatured,
      showCountdown: entity.showCountdown,
      productsCount: entity.productsCount,
      totalRevenue: entity.totalRevenue,
      ordersCount: entity.ordersCount,
      totalSavings: entity.totalSavings,
    );
  }

  // ============================================
  // CONVERSION : JSON → MODÈLE
  // ============================================

  /// Crée un modèle à partir d'une Map JSON.
  ///
  /// Gère toutes les conversions de types sécurisées.
  factory AdminPromotionModel.fromJson(Map<String, dynamic> json) {
    return AdminPromotionModel(
      // Informations de base
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,

      // Type et réduction
      type: AdminPromotionType.fromCode(json['type'] as String?),
      discountType: AdminDiscountType.fromCode(json['discount_type'] as String?),
      discountValue: (json['discount_value'] as num?)?.toDouble() ?? 0,

      // Période
      startDate: DateTime.tryParse(json['start_date'] as String? ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] as String? ?? '') ?? DateTime.now(),

      // Règles
      minimumOrder: (json['minimum_order'] as num?)?.toDouble() ?? 0,
      usageLimit: (json['usage_limit'] as num?)?.toInt(),
      usageCount: (json['usage_count'] as num?)?.toInt() ?? 0,
      usagePerUser: (json['usage_per_user'] as num?)?.toInt(),

      // Bannières
      banner: json['banner'] as String?,
      bannerMobile: json['banner_mobile'] as String?,

      // Statut
      status: AdminPromotionStatus.fromCode(json['status'] as String?),
      isActive: json['is_active'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,
      showCountdown: json['show_countdown'] as bool? ?? true,

      // Statistiques
      productsCount: (json['products_count'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0,
      ordersCount: (json['orders_count'] as num?)?.toInt() ?? 0,
      totalSavings: (json['total_savings'] as num?)?.toDouble() ?? 0,
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

  // ============================================
  // CONVERSION : MODÈLE → ENTITÉ
  // ============================================

  /// Convertit le modèle en entité pure.
  AdminPromotion toEntity() {
    return AdminPromotion(
      id: id,
      name: name,
      slug: slug,
      description: description,
      type: type,
      discountType: discountType,
      discountValue: discountValue,
      startDate: startDate,
      endDate: endDate,
      minimumOrder: minimumOrder,
      usageLimit: usageLimit,
      usageCount: usageCount,
      usagePerUser: usagePerUser,
      banner: banner,
      bannerMobile: bannerMobile,
      status: status,
      isActive: isActive,
      isFeatured: isFeatured,
      showCountdown: showCountdown,
      productsCount: productsCount,
      totalRevenue: totalRevenue,
      ordersCount: ordersCount,
      totalSavings: totalSavings,
    );
  }

  // ============================================
  // HELPERS DE VALIDATION
  // ============================================

  /// Vérifie si les dates sont cohérentes.
  bool get hasValidDates => endDate.isAfter(startDate);

  /// Vérifie si le slug est valide.
  bool get hasValidSlug => slug.isNotEmpty && !slug.contains(' ');

  /// Vérifie si la valeur de réduction est valide.
  bool get hasValidDiscount {
    if (discountType == AdminDiscountType.percentage) {
      return discountValue > 0 && discountValue <= 100;
    }
    return discountValue > 0;
  }

  /// Vérifie si la promotion est complète et valide.
  bool get isValid {
    return name.isNotEmpty &&
        hasValidSlug &&
        hasValidDates &&
        hasValidDiscount &&
        isActive;
  }

  // ============================================
  // COPYWITH
  // ============================================

  /// Crée une copie avec des champs modifiés.
  @override
  AdminPromotionModel copyWith({
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
    return AdminPromotionModel(
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
    return other is AdminPromotionModel && other.id == id && other.slug == slug;
  }

  @override
  int get hashCode => Object.hash(id, slug);

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'AdminPromotionModel(id: $id, name: $name, type: ${type.displayName}, '
        'discount: $discountValueFormatted, status: ${status.displayName}, '
        'period: $periodFormatted, valid: $isValid)';
  }
}