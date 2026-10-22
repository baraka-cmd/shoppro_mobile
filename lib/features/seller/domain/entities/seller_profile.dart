// ============================================
// ENTITÉ : SellerProfile
// ============================================
// Représente le profil boutique du vendeur.
//
// Responsabilités :
//   - Contenir toutes les infos du profil (boutique + KYC + finance)
//   - Exposer les getters métier (isVerified, canPublish, etc.)
//   - Servir de contrat entre le backend et l'UI
//
// ⚠️ Sécurité :
//   - `payoutAccount` est NULLABLE et non exposé en clair (masqué côté API)
//   - `kycRejectionReason` n'est exposé que si le statut est 'rejected'
//
// Aucune dépendance Flutter : entité PURE Dart.
// ============================================

// ============================================
// ENUM : SellerKycStatus
// ============================================
// Statut KYC du vendeur.
// ============================================

enum SellerKycStatus {
  pending('pending', 'En attente', 0xFFF59E0B),  // warning
  verified('verified', 'Vérifié', 0xFF10B981),    // success
  rejected('rejected', 'Refusé', 0xFFEF4444);     // error

  final String code;
  final String displayName;
  final int colorHex;

  const SellerKycStatus(this.code, this.displayName, this.colorHex);

  static SellerKycStatus fromCode(String? code) {
    return SellerKycStatus.values.firstWhere(
      (status) => status.code == code,
      orElse: () => SellerKycStatus.pending,
    );
  }
}

// ============================================
// ENTITÉ PRINCIPALE : SellerProfile
// ============================================

class SellerProfile {
  // ============================================
  // IDENTIFIANTS
  // ============================================
  final int id;
  final int userId;

  // ============================================
  // IDENTITÉ BOUTIQUE
  // ============================================
  final String shopName;
  final String shopSlug;
  final String? description;
  final String? logo;
  final String? logoUrl;
  final String? banner;
  final String? bannerUrl;

  // ============================================
  // CONTACT & LOCALISATION
  // ============================================
  final String? phone;
  final String? email;
  final String? address;
  final String? city;
  final String? country;

  // ============================================
  // KYC
  // ============================================
  final SellerKycStatus kycStatus;
  final String kycStatusLabel;
  final DateTime? kycVerifiedAt;
  final String? kycVerifiedAtFormatted;
  final String? kycRejectionReason;

  // ============================================
  // FINANCE
  // ============================================
  final double commissionRate;
  final double balance;
  final String balanceFormatted;
  final double pendingBalance;
  final String pendingBalanceFormatted;
  final double totalRevenue;
  final String totalRevenueFormatted;
  final String? payoutMethod;
  final String? payoutAccountMasked;
  final bool hasPayoutMethod;

  // ============================================
  // STATISTIQUES
  // ============================================
  final int productsCount;
  final int ordersCount;
  final int salesCount;
  final int reviewsCount;
  final double averageRating;
  final String averageRatingFormatted;

  // ============================================
  // STATUTS
  // ============================================
  final bool isActive;
  final bool isFeatured;
  final bool isVerified;
  final String statusLabel;

  // ============================================
  // CHAMPS DÉRIVÉS (calculés côté serveur)
  // ============================================
  final bool canPublishProducts;
  final bool canRequestPayout;

  // ============================================
  // HORODATAGE
  // ============================================
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // ============================================
  // USER (relation optionnelle)
  // ============================================
  final SellerProfileUser? user;

  const SellerProfile({
    required this.id,
    required this.userId,
    required this.shopName,
    required this.shopSlug,
    this.description,
    this.logo,
    this.logoUrl,
    this.banner,
    this.bannerUrl,
    this.phone,
    this.email,
    this.address,
    this.city,
    this.country,
    required this.kycStatus,
    required this.kycStatusLabel,
    this.kycVerifiedAt,
    this.kycVerifiedAtFormatted,
    this.kycRejectionReason,
    this.commissionRate = 10,
    this.balance = 0,
    this.balanceFormatted = '0 FCFA',
    this.pendingBalance = 0,
    this.pendingBalanceFormatted = '0 FCFA',
    this.totalRevenue = 0,
    this.totalRevenueFormatted = '0 FCFA',
    this.payoutMethod,
    this.payoutAccountMasked,
    this.hasPayoutMethod = false,
    this.productsCount = 0,
    this.ordersCount = 0,
    this.salesCount = 0,
    this.reviewsCount = 0,
    this.averageRating = 0,
    this.averageRatingFormatted = '0.0/5',
    this.isActive = true,
    this.isFeatured = false,
    this.isVerified = false,
    this.statusLabel = 'Actif',
    this.canPublishProducts = false,
    this.canRequestPayout = false,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  // ============================================
  // GETTERS KYC
  // ============================================

  bool get isKycPending => kycStatus == SellerKycStatus.pending;
  bool get isKycVerified => kycStatus == SellerKycStatus.verified;
  bool get isKycRejected => kycStatus == SellerKycStatus.rejected;

  /// Le vendeur peut-il re-soumettre son KYC ?
  bool get canSubmitKyc => isKycPending || isKycRejected;

  /// Le vendeur a-t-il une raison de rejet affichable ?
  bool get hasRejectionReason =>
      isKycRejected &&
      kycRejectionReason != null &&
      kycRejectionReason!.isNotEmpty;

  // ============================================
  // GETTERS IMAGES
  // ============================================

  bool get hasLogo => logoUrl != null && logoUrl!.isNotEmpty;
  bool get hasBanner => bannerUrl != null && bannerUrl!.isNotEmpty;

  /// Initiales du nom de boutique (pour fallback logo).
  String get shopInitials {
    final words = shopName.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return shopName.isNotEmpty ? shopName[0].toUpperCase() : 'B';
  }

  // ============================================
  // GETTERS LOCALISATION
  // ============================================

  /// Localisation complète formatée (ex: "Douala, Cameroun").
  String get formattedLocation {
    final parts = <String>[];
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.join(', ');
  }

  bool get hasLocation =>
      (city?.isNotEmpty ?? false) || (country?.isNotEmpty ?? false);

  bool get hasPhone => phone != null && phone!.isNotEmpty;
  bool get hasEmail => email != null && email!.isNotEmpty;
  bool get hasDescription =>
      description != null && description!.isNotEmpty;

  // ============================================
  // GETTERS FINANCE
  // ============================================

  /// Solde total (disponible + en attente).
  double get totalBalance => balance + pendingBalance;

  /// Solde total formaté.
  String get formattedTotalBalance {
    final total = totalBalance.round().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < total.length; i++) {
      buffer.write(total[i]);
      final remaining = total.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write(' ');
      }
    }
    return '${buffer.toString()} FCFA';
  }

  bool get hasBalance => balance > 0;
  bool get hasPendingBalance => pendingBalance > 0;

  // ============================================
  // GETTERS STATISTIQUES
  // ============================================

  /// Le vendeur a-t-il des ventes ?
  bool get hasSales => salesCount > 0;

  /// Le vendeur a-t-il des avis ?
  bool get hasReviews => reviewsCount > 0;

  // ============================================
  // GETTERS RÉSUMÉ (pour l'UI)
  // ============================================

  /// Le profil est-il complet (pour publier) ?
  bool get isProfileComplete =>
      shopName.isNotEmpty &&
      hasDescription &&
      hasLogo &&
      hasPhone;

  // ============================================
  // COPYWITH
  // ============================================

  SellerProfile copyWith({
    int? id,
    int? userId,
    String? shopName,
    String? shopSlug,
    String? description,
    String? logo,
    String? logoUrl,
    String? banner,
    String? bannerUrl,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? country,
    SellerKycStatus? kycStatus,
    String? kycStatusLabel,
    DateTime? kycVerifiedAt,
    String? kycVerifiedAtFormatted,
    String? kycRejectionReason,
    double? commissionRate,
    double? balance,
    String? balanceFormatted,
    double? pendingBalance,
    String? pendingBalanceFormatted,
    double? totalRevenue,
    String? totalRevenueFormatted,
    String? payoutMethod,
    String? payoutAccountMasked,
    bool? hasPayoutMethod,
    int? productsCount,
    int? ordersCount,
    int? salesCount,
    int? reviewsCount,
    double? averageRating,
    String? averageRatingFormatted,
    bool? isActive,
    bool? isFeatured,
    bool? isVerified,
    String? statusLabel,
    bool? canPublishProducts,
    bool? canRequestPayout,
    DateTime? createdAt,
    DateTime? updatedAt,
    SellerProfileUser? user,
  }) {
    return SellerProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      shopName: shopName ?? this.shopName,
      shopSlug: shopSlug ?? this.shopSlug,
      description: description ?? this.description,
      logo: logo ?? this.logo,
      logoUrl: logoUrl ?? this.logoUrl,
      banner: banner ?? this.banner,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      kycStatus: kycStatus ?? this.kycStatus,
      kycStatusLabel: kycStatusLabel ?? this.kycStatusLabel,
      kycVerifiedAt: kycVerifiedAt ?? this.kycVerifiedAt,
      kycVerifiedAtFormatted:
          kycVerifiedAtFormatted ?? this.kycVerifiedAtFormatted,
      kycRejectionReason: kycRejectionReason ?? this.kycRejectionReason,
      commissionRate: commissionRate ?? this.commissionRate,
      balance: balance ?? this.balance,
      balanceFormatted: balanceFormatted ?? this.balanceFormatted,
      pendingBalance: pendingBalance ?? this.pendingBalance,
      pendingBalanceFormatted:
          pendingBalanceFormatted ?? this.pendingBalanceFormatted,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalRevenueFormatted:
          totalRevenueFormatted ?? this.totalRevenueFormatted,
      payoutMethod: payoutMethod ?? this.payoutMethod,
      payoutAccountMasked: payoutAccountMasked ?? this.payoutAccountMasked,
      hasPayoutMethod: hasPayoutMethod ?? this.hasPayoutMethod,
      productsCount: productsCount ?? this.productsCount,
      ordersCount: ordersCount ?? this.ordersCount,
      salesCount: salesCount ?? this.salesCount,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      averageRating: averageRating ?? this.averageRating,
      averageRatingFormatted:
          averageRatingFormatted ?? this.averageRatingFormatted,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      isVerified: isVerified ?? this.isVerified,
      statusLabel: statusLabel ?? this.statusLabel,
      canPublishProducts: canPublishProducts ?? this.canPublishProducts,
      canRequestPayout: canRequestPayout ?? this.canRequestPayout,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
    );
  }

  @override
  String toString() {
    return 'SellerProfile(id: $id, shopName: $shopName, '
        'kyc: ${kycStatus.displayName}, isActive: $isActive)';
  }
}

// ============================================
// SOUS-ENTITÉ : SellerProfileUser
// ============================================
// Infos utilisateur liées au profil vendeur.
// ============================================

class SellerProfileUser {
  final int id;
  final String name;
  final String email;
  final String? avatar;

  const SellerProfileUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
  });

  bool get hasAvatar => avatar != null && avatar!.isNotEmpty;

  @override
  String toString() => 'SellerProfileUser(id: $id, name: $name)';
}

// ============================================
// CLASSE D'AIDE : SellerProfileStats
// ============================================
// Représente les 4 stats principales (pour l'UI).
// ============================================

class SellerProfileStats {
  final int productsCount;
  final int ordersCount;
  final int reviewsCount;
  final double averageRating;

  const SellerProfileStats({
    this.productsCount = 0,
    this.ordersCount = 0,
    this.reviewsCount = 0,
    this.averageRating = 0,
  });

  factory SellerProfileStats.fromProfile(SellerProfile profile) {
    return SellerProfileStats(
      productsCount: profile.productsCount,
      ordersCount: profile.ordersCount,
      reviewsCount: profile.reviewsCount,
      averageRating: profile.averageRating,
    );
  }

  String get formattedRating => averageRating.toStringAsFixed(1);

  @override
  String toString() {
    return 'SellerProfileStats(products: $productsCount, '
        'orders: $ordersCount, rating: $formattedRating)';
  }
}