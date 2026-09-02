// ============================================
// ENTITÉ : AdminReview
// ============================================
// Représente un avis client vu depuis le backoffice admin.
// Cette entité est pure (pas de dépendances Flutter) et contient
// toutes les informations nécessaires pour la modération des avis :
// - Informations sur l'avis
// - Auteur et produit concerné
// - Notes détaillées
// - Statut de modération
// - Statistiques d'utilité
// ============================================

/// Statut de modération d'un avis
enum AdminReviewStatus {
  pending('pending', 'En attente'),
  approved('approved', 'Approuvé'),
  rejected('rejected', 'Rejeté'),
  spam('spam', 'Spam');

  final String code;
  final String displayName;

  const AdminReviewStatus(this.code, this.displayName);

  static AdminReviewStatus fromCode(String? code) {
    return AdminReviewStatus.values.firstWhere(
      (status) => status.code == code,
      orElse: () => AdminReviewStatus.pending,
    );
  }
}

/// Entité représentant un avis client pour l'administration
class AdminReview {
  // ============================================
  // INFORMATIONS DE BASE
  // ============================================

  /// Identifiant unique
  final int id;

  /// Titre de l'avis
  final String? title;

  /// Contenu de l'avis
  final String content;

  /// Date de création
  final DateTime createdAt;

  /// Date de dernière mise à jour
  final DateTime updatedAt;

  // ============================================
  // NOTES
  // ============================================

  /// Note globale (1-5)
  final int rating;

  /// Note qualité (1-5)
  final int? qualityRating;

  /// Note prix (1-5)
  final int? priceRating;

  /// Note livraison (1-5)
  final int? shippingRating;

  /// Note moyenne calculée
  final double averageRating;

  // ============================================
  // AUTEUR
  // ============================================

  /// Identifiant de l'utilisateur
  final int userId;

  /// Nom de l'utilisateur
  final String userName;

  /// Avatar de l'utilisateur
  final String? userAvatar;

  // ============================================
  // PRODUIT
  // ============================================

  /// Identifiant du produit
  final int productId;

  /// Nom du produit
  final String productName;

  /// Image du produit
  final String? productImage;

  // ============================================
  // COMMANDE
  // ============================================

  /// Identifiant de la commande (si achat vérifié)
  final int? orderId;

  /// Numéro de commande
  final String? orderNumber;

  /// Achat vérifié ?
  final bool isVerifiedPurchase;

  // ============================================
  // MODÉRATION
  // ============================================

  /// Statut de modération
  final AdminReviewStatus status;

  /// Réponse de l'admin
  final String? adminResponse;

  /// Date de la réponse admin
  final DateTime? adminResponseAt;

  /// Date d'approbation
  final DateTime? approvedAt;

  /// Avis recommandé ?
  final bool isRecommended;

  // ============================================
  // STATISTIQUES
  // ============================================

  /// Nombre de votes "utile"
  final int helpfulCount;

  /// Nombre de votes "pas utile"
  final int notHelpfulCount;

  /// Nombre de vues
  final int viewsCount;

  /// Nombre d'images attachées
  final int imagesCount;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  const AdminReview({
    required this.id,
    this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.rating,
    this.qualityRating,
    this.priceRating,
    this.shippingRating,
    required this.averageRating,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.productId,
    required this.productName,
    this.productImage,
    this.orderId,
    this.orderNumber,
    this.isVerifiedPurchase = false,
    this.status = AdminReviewStatus.pending,
    this.adminResponse,
    this.adminResponseAt,
    this.approvedAt,
    this.isRecommended = true,
    this.helpfulCount = 0,
    this.notHelpfulCount = 0,
    this.viewsCount = 0,
    this.imagesCount = 0,
  });

  // ============================================
  // GETTERS CALCULÉS
  // ============================================

  /// Vrai si l'avis est en attente de modération
  bool get isPending => status == AdminReviewStatus.pending;

  /// Vrai si l'avis est approuvé
  bool get isApproved => status == AdminReviewStatus.approved;

  /// Vrai si l'avis est rejeté
  bool get isRejected => status == AdminReviewStatus.rejected;

  /// Vrai si l'avis est marqué comme spam
  bool get isSpam => status == AdminReviewStatus.spam;

  /// Vrai si l'avis a une réponse admin
  bool get hasAdminResponse => adminResponse != null && adminResponse!.isNotEmpty;

  /// Vrai si l'avis a un titre
  bool get hasTitle => title != null && title!.isNotEmpty;

  /// Vrai si l'avis est un achat vérifié
  bool get isVerified => isVerifiedPurchase;

  /// Vrai si l'avis est recommandé
  bool get isRecommendedReview => isRecommended;

  /// Taux d'utilité (pourcentage de votes positifs)
  double get helpfulRate {
    final totalVotes = helpfulCount + notHelpfulCount;
    if (totalVotes == 0) return 0;
    return (helpfulCount / totalVotes) * 100;
  }

  /// Nombre total de votes
  int get totalVotes => helpfulCount + notHelpfulCount;

  /// Vrai si l'avis a des votes
  bool get hasVotes => totalVotes > 0;

  /// Vrai si l'avis est majoritairement utile (plus de 70%)
  bool get isMostlyHelpful => helpfulRate >= 70;

  /// Vrai si l'avis est majoritairement inutile (moins de 30%)
  bool get isMostlyNotHelpful => helpfulRate < 30 && hasVotes;

  /// Vrai si l'avis est très consulté (plus de 100 vues)
  bool get isHighlyViewed => viewsCount >= 100;

  /// Vrai si l'avis a des images
  bool get hasImages => imagesCount > 0;

  /// Vrai si l'avis est récent (moins de 7 jours)
  bool get isRecent {
    final difference = DateTime.now().difference(createdAt);
    return difference.inDays <= 7;
  }

  /// Vrai si l'avis est ancien (plus de 30 jours)
  bool get isOld {
    final difference = DateTime.now().difference(createdAt);
    return difference.inDays >= 30;
  }

  /// Note affichée avec étoiles (ex: "★★★★☆")
  String get ratingStars {
    final stars = StringBuffer();
    for (int i = 1; i <= 5; i++) {
      if (i <= rating) {
        stars.write('★');
      } else {
        stars.write('☆');
      }
    }
    return stars.toString();
  }

  /// Note affichée avec emoji (ex: "4/5 ⭐")
  String get ratingDisplay => '$rating/5 ⭐';

  /// Texte de la note (ex: "Excellent", "Bon", "Moyen")
  String get ratingLabel {
    switch (rating) {
      case 5:
        return 'Excellent';
      case 4:
        return 'Très bon';
      case 3:
        return 'Moyen';
      case 2:
        return 'Mauvais';
      case 1:
        return 'Très mauvais';
      default:
        return 'Non noté';
    }
  }

  /// Couleur de la note (pour l'affichage)
  String get ratingColor {
    switch (rating) {
      case 5:
        return '#27AE60'; // Vert
      case 4:
        return '#3498DB'; // Bleu
      case 3:
        return '#F39C12'; // Orange
      case 2:
        return '#E67E22'; // Orange foncé
      case 1:
        return '#E74C3C'; // Rouge
      default:
        return '#7F8C8D'; // Gris
    }
  }

  /// Statut avec emoji
  String get statusWithIcon {
    switch (status) {
      case AdminReviewStatus.pending:
        return '⏳ ${status.displayName}';
      case AdminReviewStatus.approved:
        return '✅ ${status.displayName}';
      case AdminReviewStatus.rejected:
        return '❌ ${status.displayName}';
      case AdminReviewStatus.spam:
        return '🚫 ${status.displayName}';
    }
  }

  /// Extrait court du contenu (pour les listes)
  String get shortContent {
    if (content.length <= 100) return content;
    return '${content.substring(0, 100)}...';
  }

  /// Extrait du titre ou début du contenu
  String get displayTitle {
    if (hasTitle) return title!;
    if (content.length <= 50) return content;
    return '${content.substring(0, 50)}...';
  }

  /// Formatage de la date de création
  String get createdAtFormatted => _formatDate(createdAt);

  /// Formatage de la date d'approbation
  String get approvedAtFormatted {
    if (approvedAt == null) return 'Non approuvé';
    return _formatDate(approvedAt!);
  }

  /// Formatage de la date de réponse admin
  String get adminResponseAtFormatted {
    if (adminResponseAt == null) return 'Pas de réponse';
    return _formatDate(adminResponseAt!);
  }

  /// Formatage du taux d'utilité
  String get helpfulRateFormatted => '${helpfulRate.toStringAsFixed(1)}%';

  /// Formatage du nombre de vues
  String get viewsCountFormatted {
    if (viewsCount >= 1000) {
      return '${(viewsCount / 1000).toStringAsFixed(1)}k';
    }
    return viewsCount.toString();
  }

  // ============================================
  // HELPERS PRIVÉS
  // ============================================

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
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'rating': rating,
      'quality_rating': qualityRating,
      'price_rating': priceRating,
      'shipping_rating': shippingRating,
      'average_rating': averageRating,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'product_id': productId,
      'product_name': productName,
      'product_image': productImage,
      'order_id': orderId,
      'order_number': orderNumber,
      'is_verified_purchase': isVerifiedPurchase,
      'status': status.code,
      'admin_response': adminResponse,
      'admin_response_at': adminResponseAt?.toIso8601String(),
      'approved_at': approvedAt?.toIso8601String(),
      'is_recommended': isRecommended,
      'helpful_count': helpfulCount,
      'not_helpful_count': notHelpfulCount,
      'views_count': viewsCount,
      'images_count': imagesCount,
    };
  }

  /// Crée une entité à partir d'une Map
  factory AdminReview.fromJson(Map<String, dynamic> json) {
    return AdminReview(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String?,
      content: json['content'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      qualityRating: (json['quality_rating'] as num?)?.toInt(),
      priceRating: (json['price_rating'] as num?)?.toInt(),
      shippingRating: (json['shipping_rating'] as num?)?.toInt(),
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      userName: json['user_name'] as String? ?? 'Utilisateur',
      userAvatar: json['user_avatar'] as String?,
      productId: (json['product_id'] as num?)?.toInt() ?? 0,
      productName: json['product_name'] as String? ?? 'Produit',
      productImage: json['product_image'] as String?,
      orderId: (json['order_id'] as num?)?.toInt(),
      orderNumber: json['order_number'] as String?,
      isVerifiedPurchase: json['is_verified_purchase'] as bool? ?? false,
      status: AdminReviewStatus.fromCode(json['status'] as String?),
      adminResponse: json['admin_response'] as String?,
      adminResponseAt: json['admin_response_at'] != null
          ? DateTime.tryParse(json['admin_response_at'] as String)
          : null,
      approvedAt: json['approved_at'] != null
          ? DateTime.tryParse(json['approved_at'] as String)
          : null,
      isRecommended: json['is_recommended'] as bool? ?? true,
      helpfulCount: (json['helpful_count'] as num?)?.toInt() ?? 0,
      notHelpfulCount: (json['not_helpful_count'] as num?)?.toInt() ?? 0,
      viewsCount: (json['views_count'] as num?)?.toInt() ?? 0,
      imagesCount: (json['images_count'] as num?)?.toInt() ?? 0,
    );
  }

  // ============================================
  // COPYWITH
  // ============================================

  /// Crée une copie avec des champs modifiés
  AdminReview copyWith({
    int? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? rating,
    int? qualityRating,
    int? priceRating,
    int? shippingRating,
    double? averageRating,
    int? userId,
    String? userName,
    String? userAvatar,
    int? productId,
    String? productName,
    String? productImage,
    int? orderId,
    String? orderNumber,
    bool? isVerifiedPurchase,
    AdminReviewStatus? status,
    String? adminResponse,
    DateTime? adminResponseAt,
    DateTime? approvedAt,
    bool? isRecommended,
    int? helpfulCount,
    int? notHelpfulCount,
    int? viewsCount,
    int? imagesCount,
  }) {
    return AdminReview(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rating: rating ?? this.rating,
      qualityRating: qualityRating ?? this.qualityRating,
      priceRating: priceRating ?? this.priceRating,
      shippingRating: shippingRating ?? this.shippingRating,
      averageRating: averageRating ?? this.averageRating,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      orderId: orderId ?? this.orderId,
      orderNumber: orderNumber ?? this.orderNumber,
      isVerifiedPurchase: isVerifiedPurchase ?? this.isVerifiedPurchase,
      status: status ?? this.status,
      adminResponse: adminResponse ?? this.adminResponse,
      adminResponseAt: adminResponseAt ?? this.adminResponseAt,
      approvedAt: approvedAt ?? this.approvedAt,
      isRecommended: isRecommended ?? this.isRecommended,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      notHelpfulCount: notHelpfulCount ?? this.notHelpfulCount,
      viewsCount: viewsCount ?? this.viewsCount,
      imagesCount: imagesCount ?? this.imagesCount,
    );
  }

  // ============================================
  // ÉGALITÉ ET HASHCODE
  // ============================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdminReview && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'AdminReview(id: $id, user: $userName, product: $productName, '
        'rating: $rating/5, status: ${status.displayName}, '
        'helpful: $helpfulCount/$totalVotes)';
  }
}