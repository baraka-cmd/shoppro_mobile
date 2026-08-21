// Entité ProductImage (Domaine)
// Représente une image de produit

class ProductImage {
  final int id;
  final String url;
  final String? thumbnail;
  final bool isPrimary;

  const ProductImage({
    required this.id,
    required this.url,
    this.thumbnail,
    this.isPrimary = false,
  });

  /// URL de la miniature (fallback)
  String get thumbnailUrl => thumbnail ?? url;
}