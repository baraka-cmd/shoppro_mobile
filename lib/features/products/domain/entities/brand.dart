// Entité Brand (Domaine)
// Représente une marque de produits dans la couche domaine

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

  /// URL du logo
  String? get logoUrl => logo;

  /// URL de la bannière
  String? get bannerUrl => banner;

  /// Note moyenne formatée
  String get formattedRating => averageRating.toStringAsFixed(1);

  /// La marque a-t-elle des produits ?
  bool get hasProducts => productsCount > 0;

  /// La marque a-t-elle une note ?
  bool get hasRating => averageRating > 0;

  /// La marque a-t-elle un site web ?
  bool get hasWebsite => website != null && website!.isNotEmpty;

  /// La marque a-t-elle un contact ?
  bool get hasContact => (email != null && email!.isNotEmpty) || (phone != null && phone!.isNotEmpty);

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
    );
  }
}