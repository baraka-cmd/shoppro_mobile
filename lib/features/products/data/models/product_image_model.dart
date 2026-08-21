// Modèle ProductImage (Data)
// Gère la sérialisation/désérialisation JSON de l'image produit

class ProductImageModel {
  final int id;
  final String url;
  final String? thumbnail;
  final bool isPrimary;
  final int position;
  final String? altText;
  final String? caption;

  const ProductImageModel({
    required this.id,
    required this.url,
    this.thumbnail,
    this.isPrimary = false,
    this.position = 0,
    this.altText,
    this.caption,
  });

  /// Créer un ProductImageModel depuis JSON
  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      id: json['id'] as int? ?? 0,
      url: json['url'] as String? ?? '',
      thumbnail: json['thumbnail'] as String?,
      isPrimary: json['is_primary'] as bool? ?? false,
      position: json['position'] as int? ?? 0,
      altText: json['alt_text'] as String?,
      caption: json['caption'] as String?,
    );
  }

  /// Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'thumbnail': thumbnail,
      'is_primary': isPrimary,
      'position': position,
      'alt_text': altText,
      'caption': caption,
    };
  }

  /// URL de la miniature (fallback à l'URL principale)
  String get thumbnailUrl => thumbnail ?? url;

  /// Copier avec modifications
  ProductImageModel copyWith({
    int? id,
    String? url,
    String? thumbnail,
    bool? isPrimary,
    int? position,
    String? altText,
    String? caption,
  }) {
    return ProductImageModel(
      id: id ?? this.id,
      url: url ?? this.url,
      thumbnail: thumbnail ?? this.thumbnail,
      isPrimary: isPrimary ?? this.isPrimary,
      position: position ?? this.position,
      altText: altText ?? this.altText,
      caption: caption ?? this.caption,
    );
  }
}