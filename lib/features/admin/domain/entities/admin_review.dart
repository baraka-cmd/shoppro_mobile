// ============================================
// ENTITÉ : AdminReview (ENRICHIE)
// ============================================
// Représente un avis client vu depuis le backoffice admin.
// - Informations sur l'avis
// - Auteur et produit concerné
// - Notes détaillées
// - Statut de modération
// - Statistiques d'utilité
// - ✅ Photos (NOUVEAU)
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

  final int id;
  final String? title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  // ============================================
  // NOTES
  // ============================================

  final int rating;
  final int? qualityRating;
  final int? priceRating;
  final int? shippingRating;

  // ============================================
  // AUTEUR
  // ============================================

  final int userId;
  final String userName;
  final String userEmail;
  final String? userAvatar;

  // ============================================
  // PRODUIT
  // ============================================

  final int productId;
  final String productName;
  final String? productSku;
  final String? productImage;

  // ============================================
  // STATUT
  // ============================================

  final AdminReviewStatus status;
  final String? adminResponse;
  final DateTime? adminResponseAt;
  final DateTime? approvedAt;
  final bool isRecommended;
  final bool isVerifiedPurchase;

  // ============================================
  // STATISTIQUES
  // ============================================

  final int helpfulCount;
  final int notHelpfulCount;
  final int viewsCount;

  // ============================================
  // ✅ NOUVEAU — PHOTOS
  // ============================================

  /// URLs des photos attachées à l'avis
  final List<String> images;

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
    required this.userId,
    required this.userName,
    this.userEmail = '',
    this.userAvatar,
    required this.productId,
    required this.productName,
    this.productSku,
    this.productImage,
    this.status = AdminReviewStatus.pending,
    this.adminResponse,
    this.adminResponseAt,
    this.approvedAt,
    this.isRecommended = true,
    this.isVerifiedPurchase = false,
    this.helpfulCount = 0,
    this.notHelpfulCount = 0,
    this.viewsCount = 0,
    this.images = const [],
  });

  // ============================================
  // GETTERS
  // ============================================

  bool get isPending => status == AdminReviewStatus.pending;
  bool get isApproved => status == AdminReviewStatus.approved;
  bool get isRejected => status == AdminReviewStatus.rejected;
  bool get isSpam => status == AdminReviewStatus.spam;

  bool get hasAdminResponse => adminResponse != null && adminResponse!.isNotEmpty;
  bool get hasTitle => title != null && title!.isNotEmpty;
  bool get isVerified => isVerifiedPurchase;

  /// ✅ NOUVEAU
  bool get hasImages => images.isNotEmpty;
  int get imagesCount => images.length;

  double get helpfulRate {
    final totalVotes = helpfulCount + notHelpfulCount;
    if (totalVotes == 0) return 0;
    return (helpfulCount / totalVotes) * 100;
  }

  int get totalVotes => helpfulCount + notHelpfulCount;
  bool get hasVotes => totalVotes > 0;

  String get displayTitle {
    if (hasTitle) return title!;
    if (content.length <= 50) return content;
    return '${content.substring(0, 50)}...';
  }

  String get shortContent {
    if (content.length <= 120) return content;
    return '${content.substring(0, 120)}...';
  }

  String get ratingLabel {
    switch (rating) {
      case 5: return 'Excellent';
      case 4: return 'Très bon';
      case 3: return 'Moyen';
      case 2: return 'Mauvais';
      case 1: return 'Très mauvais';
      default: return 'Non noté';
    }
  }

  // ============================================
  // FORMATAGE
  // ============================================

  String get createdAtFormatted => _formatDate(createdAt);
  String get approvedAtFormatted => approvedAt != null ? _formatDate(approvedAt!) : 'Non approuvé';
  String get adminResponseAtFormatted => adminResponseAt != null ? _formatDate(adminResponseAt!) : 'Pas de réponse';
  String get helpfulRateFormatted => '${helpfulRate.toStringAsFixed(1)}%';

  String get viewsCountFormatted {
    if (viewsCount >= 1000) return '${(viewsCount / 1000).toStringAsFixed(1)}k';
    return viewsCount.toString();
  }

  String _formatDate(DateTime date) {
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // ============================================
  // JSON
  // ============================================

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
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
      'user_avatar': userAvatar,
      'product_id': productId,
      'product_name': productName,
      'product_sku': productSku,
      'product_image': productImage,
      'status': status.code,
      'admin_response': adminResponse,
      'admin_response_at': adminResponseAt?.toIso8601String(),
      'approved_at': approvedAt?.toIso8601String(),
      'is_recommended': isRecommended,
      'is_verified_purchase': isVerifiedPurchase,
      'helpful_count': helpfulCount,
      'not_helpful_count': notHelpfulCount,
      'views_count': viewsCount,
      'images': images,
    };
  }

  factory AdminReview.fromJson(Map<String, dynamic> json) {
    // Parse user
    final user = json['user'] as Map<String, dynamic>? ?? {};
    final userName = user['name'] as String? ?? 'Utilisateur';
    final userEmail = user['email'] as String? ?? '';
    final userAvatar = user['avatar'] as String?;

    // Parse product
    final product = json['product'] as Map<String, dynamic>? ?? {};
    final productName = product['name'] as String? ?? 'Produit';
    final productSku = product['sku'] as String?;
    final productImage = product['image'] as String?;

    // ✅ Parse images
    final rawImages = json['images'];
    final images = <String>[];
    if (rawImages is List) {
      for (final img in rawImages) {
        if (img is Map && img['url'] != null) {
          images.add(img['url'].toString());
        } else if (img is String) {
          images.add(img);
        }
      }
    }

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
      userId: (json['user_id'] as num?)?.toInt() ?? (user['id'] as num?)?.toInt() ?? 0,
      userName: userName,
      userEmail: userEmail,
      userAvatar: userAvatar,
      productId: (json['product_id'] as num?)?.toInt() ?? (product['id'] as num?)?.toInt() ?? 0,
      productName: productName,
      productSku: productSku,
      productImage: productImage,
      status: AdminReviewStatus.fromCode(json['status'] as String?),
      adminResponse: json['admin_response'] as String?,
      adminResponseAt: json['admin_response_at'] != null
          ? DateTime.tryParse(json['admin_response_at'] as String)
          : null,
      approvedAt: json['approved_at'] != null
          ? DateTime.tryParse(json['approved_at'] as String)
          : null,
      isRecommended: json['is_recommended'] as bool? ?? true,
      isVerifiedPurchase: json['is_verified_purchase'] as bool? ?? false,
      helpfulCount: (json['helpful_count'] as num?)?.toInt() ?? 0,
      notHelpfulCount: (json['not_helpful_count'] as num?)?.toInt() ?? 0,
      viewsCount: (json['views_count'] as num?)?.toInt() ?? 0,
      images: images,
    );
  }

  // ============================================
  // COPYWITH
  // ============================================

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
    int? userId,
    String? userName,
    String? userEmail,
    String? userAvatar,
    int? productId,
    String? productName,
    String? productSku,
    String? productImage,
    AdminReviewStatus? status,
    String? adminResponse,
    DateTime? adminResponseAt,
    DateTime? approvedAt,
    bool? isRecommended,
    bool? isVerifiedPurchase,
    int? helpfulCount,
    int? notHelpfulCount,
    int? viewsCount,
    List<String>? images,
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
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userAvatar: userAvatar ?? this.userAvatar,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productSku: productSku ?? this.productSku,
      productImage: productImage ?? this.productImage,
      status: status ?? this.status,
      adminResponse: adminResponse ?? this.adminResponse,
      adminResponseAt: adminResponseAt ?? this.adminResponseAt,
      approvedAt: approvedAt ?? this.approvedAt,
      isRecommended: isRecommended ?? this.isRecommended,
      isVerifiedPurchase: isVerifiedPurchase ?? this.isVerifiedPurchase,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      notHelpfulCount: notHelpfulCount ?? this.notHelpfulCount,
      viewsCount: viewsCount ?? this.viewsCount,
      images: images ?? this.images,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdminReview && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AdminReview(id: $id, user: $userName, product: $productName, '
        'rating: $rating/5, status: ${status.displayName}, images: ${images.length})';
  }
}