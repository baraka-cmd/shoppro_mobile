// ============================================
// MODEL : SellerProfileModel
// ============================================
// Sérialisation JSON pour SellerProfile.
//
// Responsabilités :
//   - Parser la réponse API /seller/profile
//   - Gérer les valeurs null (parsing défensif)
//   - Convertir types (num → double/int)
//   - Fournir des fallbacks sûrs
// ============================================

import '../../domain/entities/seller_profile.dart';

// ============================================
// MODEL PRINCIPAL
// ============================================

class SellerProfileModel extends SellerProfile {
  const SellerProfileModel({
    required super.id,
    required super.userId,
    required super.shopName,
    required super.shopSlug,
    super.description,
    super.logo,
    super.logoUrl,
    super.banner,
    super.bannerUrl,
    super.phone,
    super.email,
    super.address,
    super.city,
    super.country,
    required super.kycStatus,
    required super.kycStatusLabel,
    super.kycVerifiedAt,
    super.kycVerifiedAtFormatted,
    super.kycRejectionReason,
    super.commissionRate,
    super.balance,
    super.balanceFormatted,
    super.pendingBalance,
    super.pendingBalanceFormatted,
    super.totalRevenue,
    super.totalRevenueFormatted,
    super.payoutMethod,
    super.payoutAccountMasked,
    super.hasPayoutMethod,
    super.productsCount,
    super.ordersCount,
    super.salesCount,
    super.reviewsCount,
    super.averageRating,
    super.averageRatingFormatted,
    super.isActive,
    super.isFeatured,
    super.isVerified,
    super.statusLabel,
    super.canPublishProducts,
    super.canRequestPayout,
    super.createdAt,
    super.updatedAt,
    super.user,
  });

  // ============================================
  // JSON → MODEL
  // ============================================

  factory SellerProfileModel.fromJson(Map<String, dynamic> json) {
    return SellerProfileModel(
      // Identifiants
      id: _parseInt(json['id']),
      userId: _parseInt(json['user_id']),
      shopName: _parseString(json['shop_name'], 'Ma boutique'),
      shopSlug: _parseString(json['shop_slug'], 'ma-boutique'),
      description: _parseNullableString(json['description']),
      logo: _parseNullableString(json['logo']),
      logoUrl: _parseNullableString(json['logo_url']),
      banner: _parseNullableString(json['banner']),
      bannerUrl: _parseNullableString(json['banner_url']),

      // Contact
      phone: _parseNullableString(json['phone']),
      email: _parseNullableString(json['email']),
      address: _parseNullableString(json['address']),
      city: _parseNullableString(json['city']),
      country: _parseNullableString(json['country']),

      // KYC
      kycStatus: SellerKycStatus.fromCode(json['kyc_status'] as String?),
      kycStatusLabel: _parseString(json['kyc_status_label'], 'En attente'),
      kycVerifiedAt: _parseDate(json['kyc_verified_at']),
      kycVerifiedAtFormatted:
          _parseNullableString(json['kyc_verified_at_formatted']),
      kycRejectionReason: _parseNullableString(json['kyc_rejection_reason']),

      // Finance
      commissionRate: _parseDouble(json['commission_rate'], defaultValue: 10),
      balance: _parseDouble(json['balance']),
      balanceFormatted: _parseString(json['balance_formatted'], '0 FCFA'),
      pendingBalance: _parseDouble(json['pending_balance']),
      pendingBalanceFormatted:
          _parseString(json['pending_balance_formatted'], '0 FCFA'),
      totalRevenue: _parseDouble(json['total_revenue']),
      totalRevenueFormatted:
          _parseString(json['total_revenue_formatted'], '0 FCFA'),
      payoutMethod: _parseNullableString(json['payout_method']),
      payoutAccountMasked: _parseNullableString(json['payout_account_masked']),
      hasPayoutMethod: _parseBool(json['has_payout_method']),

      // Statistiques
      productsCount: _parseInt(json['products_count']),
      ordersCount: _parseInt(json['orders_count']),
      salesCount: _parseInt(json['sales_count']),
      reviewsCount: _parseInt(json['reviews_count']),
      averageRating: _parseDouble(json['average_rating']),
      averageRatingFormatted:
          _parseString(json['average_rating_formatted'], '0.0/5'),

      // Statuts
      isActive: _parseBool(json['is_active'], defaultValue: true),
      isFeatured: _parseBool(json['is_featured']),
      isVerified: _parseBool(json['is_verified']),
      statusLabel: _parseString(json['status_label'], 'Actif'),

      // Champs dérivés
      canPublishProducts: _parseBool(json['can_publish_products']),
      canRequestPayout: _parseBool(json['can_request_payout']),

      // Horodatage
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),

      // User (relation optionnelle)
      user: json['user'] is Map
          ? SellerProfileUserModel.fromJson(
              Map<String, dynamic>.from(json['user'] as Map),
            )
          : null,
    );
  }

  // ============================================
  // MODEL → JSON
  // ============================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'shop_name': shopName,
      'shop_slug': shopSlug,
      'description': description,
      'logo': logo,
      'logo_url': logoUrl,
      'banner': banner,
      'banner_url': bannerUrl,
      'phone': phone,
      'email': email,
      'address': address,
      'city': city,
      'country': country,
      'kyc_status': kycStatus.code,
      'kyc_status_label': kycStatusLabel,
      'kyc_verified_at': kycVerifiedAt?.toIso8601String(),
      'kyc_verified_at_formatted': kycVerifiedAtFormatted,
      'kyc_rejection_reason': kycRejectionReason,
      'commission_rate': commissionRate,
      'balance': balance,
      'balance_formatted': balanceFormatted,
      'pending_balance': pendingBalance,
      'pending_balance_formatted': pendingBalanceFormatted,
      'total_revenue': totalRevenue,
      'total_revenue_formatted': totalRevenueFormatted,
      'payout_method': payoutMethod,
      'payout_account_masked': payoutAccountMasked,
      'has_payout_method': hasPayoutMethod,
      'products_count': productsCount,
      'orders_count': ordersCount,
      'sales_count': salesCount,
      'reviews_count': reviewsCount,
      'average_rating': averageRating,
      'average_rating_formatted': averageRatingFormatted,
      'is_active': isActive,
      'is_featured': isFeatured,
      'is_verified': isVerified,
      'status_label': statusLabel,
      'can_publish_products': canPublishProducts,
      'can_request_payout': canRequestPayout,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'user': user != null
          ? SellerProfileUserModel.fromEntity(user!).toJson()
          : null,
    };
  }

  // ============================================
  // fromEntity
  // ============================================

  factory SellerProfileModel.fromEntity(SellerProfile entity) {
    return SellerProfileModel(
      id: entity.id,
      userId: entity.userId,
      shopName: entity.shopName,
      shopSlug: entity.shopSlug,
      description: entity.description,
      logo: entity.logo,
      logoUrl: entity.logoUrl,
      banner: entity.banner,
      bannerUrl: entity.bannerUrl,
      phone: entity.phone,
      email: entity.email,
      address: entity.address,
      city: entity.city,
      country: entity.country,
      kycStatus: entity.kycStatus,
      kycStatusLabel: entity.kycStatusLabel,
      kycVerifiedAt: entity.kycVerifiedAt,
      kycVerifiedAtFormatted: entity.kycVerifiedAtFormatted,
      kycRejectionReason: entity.kycRejectionReason,
      commissionRate: entity.commissionRate,
      balance: entity.balance,
      balanceFormatted: entity.balanceFormatted,
      pendingBalance: entity.pendingBalance,
      pendingBalanceFormatted: entity.pendingBalanceFormatted,
      totalRevenue: entity.totalRevenue,
      totalRevenueFormatted: entity.totalRevenueFormatted,
      payoutMethod: entity.payoutMethod,
      payoutAccountMasked: entity.payoutAccountMasked,
      hasPayoutMethod: entity.hasPayoutMethod,
      productsCount: entity.productsCount,
      ordersCount: entity.ordersCount,
      salesCount: entity.salesCount,
      reviewsCount: entity.reviewsCount,
      averageRating: entity.averageRating,
      averageRatingFormatted: entity.averageRatingFormatted,
      isActive: entity.isActive,
      isFeatured: entity.isFeatured,
      isVerified: entity.isVerified,
      statusLabel: entity.statusLabel,
      canPublishProducts: entity.canPublishProducts,
      canRequestPayout: entity.canRequestPayout,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      user: entity.user,
    );
  }
}

// ============================================
// MODEL : SellerProfileUserModel
// ============================================

class SellerProfileUserModel extends SellerProfileUser {
  const SellerProfileUserModel({
    required super.id,
    required super.name,
    required super.email,
    super.avatar,
  });

  factory SellerProfileUserModel.fromJson(Map<String, dynamic> json) {
    return SellerProfileUserModel(
      id: _parseInt(json['id']),
      name: _parseString(json['name'], 'Utilisateur'),
      email: _parseString(json['email']),
      avatar: _parseNullableString(json['avatar']),
    );
  }

  factory SellerProfileUserModel.fromEntity(SellerProfileUser e) {
    return SellerProfileUserModel(
      id: e.id,
      name: e.name,
      email: e.email,
      avatar: e.avatar,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
    };
  }
}

// ============================================
// HELPERS DE PARSING
// ============================================

int _parseInt(dynamic value, {int defaultValue = 0}) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? defaultValue;
  return defaultValue;
}

double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
  if (value == null) return defaultValue;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? defaultValue;
  return defaultValue;
}

String _parseString(dynamic value, [String defaultValue = '']) {
  if (value == null) return defaultValue;
  return value.toString();
}

String? _parseNullableString(dynamic value) {
  if (value == null) return null;
  final str = value.toString();
  return str.isEmpty ? null : str;
}

bool _parseBool(dynamic value, {bool defaultValue = false}) {
  if (value == null) return defaultValue;
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) {
    final lower = value.toLowerCase();
    return lower == 'true' || lower == '1' || lower == 'yes';
  }
  return defaultValue;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}