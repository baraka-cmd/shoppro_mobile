// ============================================
// ENTITÉ : SellerReview
// ============================================
// Représente un avis client du point de vue VENDEUR.
//
// Différences avec AdminReview :
//   - Le vendeur ne voit QUE les avis sur SES produits
//   - L'email du client est masqué (vie privée)
//   - Les actions disponibles sont pré-calculées (can_respond, etc.)
//   - Les stats (pending, approved...) sont fournies par l'API
//
// Aucune dépendance Flutter : entité PURE Dart.
// ============================================

class SellerReview {
  // ============================================
  // IDENTIFIANTS & NOTES
  // ============================================
  final int id;
  final int rating;
  final String ratingLabel;
  final String? title;
  final String content;

  // ============================================
  // STATUT DE MODÉRATION
  // ============================================
  final String status;
  final String statusLabel;
  final String statusColor;

  // ============================================
  // DATES
  // ============================================
  final DateTime? createdAt;
  final String? createdAtHuman;

  // ============================================
  // CLIENT (anonymisé)
  // ============================================
  final SellerReviewCustomer? customer;

  // ============================================
  // PRODUIT
  // ============================================
  final SellerReviewProduct? product;

  // ============================================
  // PHOTOS
  // ============================================
  final List<SellerReviewImage> images;

  // ============================================
  // STATISTIQUES
  // ============================================
  final bool isVerifiedPurchase;
  final int helpfulCount;
  final int notHelpfulCount;
  final double helpfulRate;
  final String helpfulRateFormatted;

  // ============================================
  // RÉPONSE VENDEUR
  // ============================================
  final String? adminResponse;
  final DateTime? adminResponseAt;
  final bool hasAdminResponse;

  // ============================================
  // ACTIONS POSSIBLES
  // ============================================
  final bool canRespond;
  final bool canApprove;
  final bool canReject;
  final bool canMarkSpam;

  const SellerReview({
    required this.id,
    required this.rating,
    required this.ratingLabel,
    this.title,
    required this.content,
    required this.status,
    required this.statusLabel,
    required this.statusColor,
    this.createdAt,
    this.createdAtHuman,
    this.customer,
    this.product,
    this.images = const [],
    this.isVerifiedPurchase = false,
    this.helpfulCount = 0,
    this.notHelpfulCount = 0,
    this.helpfulRate = 0,
    this.helpfulRateFormatted = '0%',
    this.adminResponse,
    this.adminResponseAt,
    this.hasAdminResponse = false,
    this.canRespond = false,
    this.canApprove = false,
    this.canReject = false,
    this.canMarkSpam = false,
  });

  // ============================================
  // GETTERS STATUT
  // ============================================

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isSpam => status == 'spam';

  // ============================================
  // GETTERS TITRE
  // ============================================

  /// Titre affichable (titre ou extrait du contenu).
  String get displayTitle {
    if (title != null && title!.isNotEmpty) return title!;
    if (content.length <= 50) return content;
    return '${content.substring(0, 50)}...';
  }

  /// Contenu tronqué pour les listes.
  String get shortContent {
    if (content.length <= 120) return content;
    return '${content.substring(0, 120)}...';
  }

  // ============================================
  // GETTERS IMAGES
  // ============================================

  bool get hasImages => images.isNotEmpty;
  int get imagesCount => images.length;

  // ============================================
  // GETTERS STATISTIQUES
  // ============================================

  int get totalVotes => helpfulCount + notHelpfulCount;

  /// Le vendeur a-t-il répondu à cet avis ?
  bool get hasResponse => hasAdminResponse;

  @override
  String toString() {
    return 'SellerReview(id: $id, rating: $rating/5, '
        'status: $statusLabel, hasResponse: $hasAdminResponse)';
  }
}

// ============================================
// SOUS-ENTITÉ : SellerReviewCustomer
// ============================================
// Client partiellement anonymisé (nom + initiales).
// ============================================

class SellerReviewCustomer {
  final String name;
  final String initials;

  const SellerReviewCustomer({
    required this.name,
    required this.initials,
  });

  @override
  String toString() => 'SellerReviewCustomer(name: $name)';
}

// ============================================
// SOUS-ENTITÉ : SellerReviewProduct
// ============================================
// Produit concerné par l'avis.
// ============================================

class SellerReviewProduct {
  final int id;
  final String name;
  final String? imageUrl;
  final String? sku;

  const SellerReviewProduct({
    required this.id,
    required this.name,
    this.imageUrl,
    this.sku,
  });

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  @override
  String toString() => 'SellerReviewProduct(name: $name)';
}

// ============================================
// SOUS-ENTITÉ : SellerReviewImage
// ============================================
// Image attachée à un avis.
// ============================================

class SellerReviewImage {
  final int id;
  final String url;
  final String? thumbnail;
  final String? altText;

  const SellerReviewImage({
    required this.id,
    required this.url,
    this.thumbnail,
    this.altText,
  });

  /// URL de la miniature (fallback sur url).
  String get thumbnailUrl => thumbnail ?? url;

  @override
  String toString() => 'SellerReviewImage(id: $id)';
}

// ============================================
// ENTITÉ : SellerReviewsStats
// ============================================
// Statistiques globales des avis du vendeur.
// ============================================

class SellerReviewsStats {
  final int total;
  final int pending;
  final int approved;
  final int rejected;
  final int spam;
  final int withPhotos;
  final int verified;
  final double averageRating;
  final int toModerate;

  const SellerReviewsStats({
    this.total = 0,
    this.pending = 0,
    this.approved = 0,
    this.rejected = 0,
    this.spam = 0,
    this.withPhotos = 0,
    this.verified = 0,
    this.averageRating = 0,
    this.toModerate = 0,
  });

  const SellerReviewsStats.empty()
      : total = 0,
        pending = 0,
        approved = 0,
        rejected = 0,
        spam = 0,
        withPhotos = 0,
        verified = 0,
        averageRating = 0,
        toModerate = 0;

  /// Note moyenne formatée (ex: "4.5").
  String get formattedRating => averageRating.toStringAsFixed(1);

  bool get hasReviews => total > 0;

  @override
  String toString() =>
      'SellerReviewsStats(total: $total, pending: $pending, avg: $averageRating)';
}