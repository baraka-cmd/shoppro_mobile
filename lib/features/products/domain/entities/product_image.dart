// ============================================
// ENTITÉ PRODUCT IMAGE (DOMAINE)
// ============================================
// Représente une image de produit avec support
// des angles de vue pour l'effet 360° premium.
// ============================================

class ProductImage {
  final int id;
  final String url;
  final String? thumbnail;
  final bool isPrimary;
  final int position;
  final String? angle;
  final String? caption;
  final int? width;
  final int? height;
  final String? type;

  const ProductImage({
    required this.id,
    required this.url,
    this.thumbnail,
    this.isPrimary = false,
    this.position = 0,
    this.angle,
    this.caption,
    this.width,
    this.height,
    this.type = 'image',
  });

  /// URL complète de l'image
  String get fullUrl {
    if (url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return 'http://127.0.0.1:8000/storage/$url';
  }

  /// URL de la miniature (fallback)
  String get fullThumbnailUrl {
    final thumb = thumbnail ?? url;
    if (thumb.isEmpty) return '';
    if (thumb.startsWith('http')) return thumb;
    return 'http://127.0.0.1:8000/storage/$thumb';
  }

  /// Angle normalisé pour l'effet 360°
  String get normalizedAngle {
    if (angle == null || angle!.isEmpty) return '0°';
    if (angle!.contains('°')) return angle!;
    return '$angle°';
  }

  /// L'image a-t-elle un angle de vue défini ?
  bool get hasAngle => angle != null && angle!.isNotEmpty;

  /// L'image est-elle une vidéo ?
  bool get isVideo => type == 'video';

  /// L'image est-elle un GIF ?
  bool get isGif => type == 'gif';

  /// L'image est-elle valide ?
  bool get isValid => id > 0 && url.isNotEmpty;

  /// Copier avec modifications
  ProductImage copyWith({
    int? id,
    String? url,
    String? thumbnail,
    bool? isPrimary,
    int? position,
    String? angle,
    String? caption,
    int? width,
    int? height,
    String? type,
  }) {
    return ProductImage(
      id: id ?? this.id,
      url: url ?? this.url,
      thumbnail: thumbnail ?? this.thumbnail,
      isPrimary: isPrimary ?? this.isPrimary,
      position: position ?? this.position,
      angle: angle ?? this.angle,
      caption: caption ?? this.caption,
      width: width ?? this.width,
      height: height ?? this.height,
      type: type ?? this.type,
    );
  }

  @override
  String toString() {
    return 'ProductImage(id: $id, angle: $normalizedAngle, primary: $isPrimary)';
  }
}