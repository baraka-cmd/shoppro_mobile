// ============================================
// ENTITÉ BRAND (DOMAINE)
// ============================================
// Représente une marque de produits avec
// logo, bannière, contact et statistiques.
// ============================================

class Brand {
  final int id;
  final String name;
  final String slug;
  final String? description;

  // Images
  final String? logo;
  final String? banner;

  // Contact
  final String? website;
  final String? email;
  final String? phone;

  // Origine
  final String? country;

  // Statistiques
  final int productsCount;
  final double averageRating;

  // Statut
  final bool isActive;
  final bool isFeatured;

  // Dates
  final DateTime? createdAt;

  const Brand({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.logo,
    this.banner,
    this.website,
    this.email,
    this.phone,
    this.country,
    this.productsCount = 0,
    this.averageRating = 0,
    this.isActive = true,
    this.isFeatured = false,
    this.createdAt,
  });

  // ============================================
  // GETTERS IMAGES
  // ============================================

  /// URL complète du logo
  String get fullLogoUrl {
    if (logo == null || logo!.isEmpty) return '';
    if (logo!.startsWith('http')) return logo!;
    return 'http://127.0.0.1:8000/storage/$logo';
  }

  /// URL complète de la bannière
  String get fullBannerUrl {
    if (banner == null || banner!.isEmpty) return '';
    if (banner!.startsWith('http')) return banner!;
    return 'http://127.0.0.1:8000/storage/$banner';
  }

  /// Le logo est-il disponible ?
  bool get hasLogo => logo != null && logo!.isNotEmpty;

  /// La bannière est-elle disponible ?
  bool get hasBanner => banner != null && banner!.isNotEmpty;

  /// Les images de la marque sont-elles disponibles ?
  bool get hasImages => hasLogo || hasBanner;

  // ============================================
  // GETTERS CONTACT
  // ============================================

  /// Le site web est-il disponible ?
  bool get hasWebsite => website != null && website!.isNotEmpty;

  /// L'email est-il disponible ?
  bool get hasEmail => email != null && email!.isNotEmpty;

  /// Le téléphone est-il disponible ?
  bool get hasPhone => phone != null && phone!.isNotEmpty;

  /// La marque a-t-elle un contact ?
  bool get hasContact => hasEmail || hasPhone || hasWebsite;

  /// Le pays est-il disponible ?
  bool get hasCountry => country != null && country!.isNotEmpty;

  // ============================================
  // GETTERS STATISTIQUES
  // ============================================

  /// Note moyenne formatée (ex: 4.5)
  String get formattedRating => averageRating.toStringAsFixed(1);

  /// Note sur 5 étoiles (pour affichage)
  double get ratingOutOfFive => averageRating.clamp(0, 5).toDouble();

  /// La marque a-t-elle des produits ?
  bool get hasProducts => productsCount > 0;

  /// La marque a-t-elle une note ?
  bool get hasRating => averageRating > 0;

  /// Nombre de produits formaté (ex: 1.2k)
  String get formattedProductsCount {
    if (productsCount >= 1000) {
      return '${(productsCount / 1000).toStringAsFixed(1)}k';
    }
    return '$productsCount';
  }

  // ============================================
  // GETTERS STATUT
  // ============================================

  /// La marque est-elle visible ?
  bool get isVisible => isActive && (isFeatured || hasProducts || hasRating);

  // ============================================
  // VALIDATION
  // ============================================

  /// La marque a-t-elle des données valides ?
  bool get isValid => id > 0 && name.isNotEmpty && slug.isNotEmpty;

  // ============================================
  // MÉTHODES
  // ============================================

  /// Copier avec modifications
  Brand copyWith({
    int? id,
    String? name,
    String? slug,
    String? description,
    String? logo,
    String? banner,
    String? website,
    String? email,
    String? phone,
    String? country,
    int? productsCount,
    double? averageRating,
    bool? isActive,
    bool? isFeatured,
    DateTime? createdAt,
  }) {
    return Brand(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      logo: logo ?? this.logo,
      banner: banner ?? this.banner,
      website: website ?? this.website,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      productsCount: productsCount ?? this.productsCount,
      averageRating: averageRating ?? this.averageRating,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Brand(id: $id, name: $name, products: $productsCount, '
        'rating: $formattedRating, featured: $isFeatured)';
  }
}