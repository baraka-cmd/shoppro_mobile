// ============================================
// MODEL : AdminReviewModel (ALIGNÉ sur l'entité actuelle)
// ============================================
// Modèle de sérialisation pour les avis clients administrés.
// Cette classe étend [AdminReview] et ajoute les méthodes
// de sérialisation JSON nécessaires pour l'API.
// ============================================

// Flutter
import 'package:flutter/material.dart';

// Entities (même feature admin)
import '../../domain/entities/admin_review.dart';

// ============================================
// CLASSE PRINCIPALE
// ============================================

class AdminReviewModel extends AdminReview {
  // ============================================
  // CONSTRUCTEUR
  // ============================================

  const AdminReviewModel({
    required super.id,
    super.title,
    required super.content,
    required super.createdAt,
    required super.updatedAt,
    required super.rating,
    super.qualityRating,
    super.priceRating,
    super.shippingRating,
    required super.userId,
    required super.userName,
    super.userEmail,
    super.userAvatar,
    required super.productId,
    required super.productName,
    super.productSku,
    super.productImage,
    super.status,
    super.adminResponse,
    super.adminResponseAt,
    super.approvedAt,
    super.isRecommended,
    super.isVerifiedPurchase,
    super.helpfulCount,
    super.notHelpfulCount,
    super.viewsCount,
    super.images,
  });

  // ============================================
  // CONVERSION : ENTITÉ → MODÈLE
  // ============================================

  factory AdminReviewModel.fromEntity(AdminReview entity) {
    return AdminReviewModel(
      id: entity.id,
      title: entity.title,
      content: entity.content,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      rating: entity.rating,
      qualityRating: entity.qualityRating,
      priceRating: entity.priceRating,
      shippingRating: entity.shippingRating,
      userId: entity.userId,
      userName: entity.userName,
      userEmail: entity.userEmail,
      userAvatar: entity.userAvatar,
      productId: entity.productId,
      productName: entity.productName,
      productSku: entity.productSku,
      productImage: entity.productImage,
      status: entity.status,
      adminResponse: entity.adminResponse,
      adminResponseAt: entity.adminResponseAt,
      approvedAt: entity.approvedAt,
      isRecommended: entity.isRecommended,
      isVerifiedPurchase: entity.isVerifiedPurchase,
      helpfulCount: entity.helpfulCount,
      notHelpfulCount: entity.notHelpfulCount,
      viewsCount: entity.viewsCount,
      images: entity.images,
    );
  }

  // ============================================
  // CONVERSION : JSON → MODÈLE
  // ============================================

  factory AdminReviewModel.fromJson(Map<String, dynamic> json) {
    // Parse user
    final user = json['user'] as Map<String, dynamic>? ?? {};
    final userName = user['name'] as String? ?? json['user_name'] as String? ?? 'Utilisateur';
    final userEmail = user['email'] as String? ?? json['user_email'] as String? ?? '';
    final userAvatar = user['avatar'] as String? ?? json['user_avatar'] as String?;

    // Parse product
    final product = json['product'] as Map<String, dynamic>? ?? {};
    final productName = product['name'] as String? ?? json['product_name'] as String? ?? 'Produit';
    final productSku = product['sku'] as String? ?? json['product_sku'] as String?;
    final productImage = product['image'] as String? ?? json['product_image'] as String?;

    // ✅ Parse images (robuste aux 3 formats : List<String>, List<Map>, null)
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

    return AdminReviewModel(
      // Base
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String?,
      content: json['content'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),

      // Notes
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      qualityRating: (json['quality_rating'] as num?)?.toInt(),
      priceRating: (json['price_rating'] as num?)?.toInt(),
      shippingRating: (json['shipping_rating'] as num?)?.toInt(),

      // Auteur
      userId: (json['user_id'] as num?)?.toInt() ?? (user['id'] as num?)?.toInt() ?? 0,
      userName: userName,
      userEmail: userEmail,
      userAvatar: userAvatar,

      // Produit
      productId: (json['product_id'] as num?)?.toInt() ?? (product['id'] as num?)?.toInt() ?? 0,
      productName: productName,
      productSku: productSku,
      productImage: productImage,

      // Modération
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

      // Statistiques
      helpfulCount: (json['helpful_count'] as num?)?.toInt() ?? 0,
      notHelpfulCount: (json['not_helpful_count'] as num?)?.toInt() ?? 0,
      viewsCount: (json['views_count'] as num?)?.toInt() ?? 0,

      // ✅ Images
      images: images,
    );
  }

  // ============================================
  // CONVERSION : MODÈLE → JSON
  // ============================================

  @override
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

  // ============================================
  // CONVERSION : MODÈLE → ENTITÉ
  // ============================================

  AdminReview toEntity() {
    return AdminReview(
      id: id,
      title: title,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
      rating: rating,
      qualityRating: qualityRating,
      priceRating: priceRating,
      shippingRating: shippingRating,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      userAvatar: userAvatar,
      productId: productId,
      productName: productName,
      productSku: productSku,
      productImage: productImage,
      status: status,
      adminResponse: adminResponse,
      adminResponseAt: adminResponseAt,
      approvedAt: approvedAt,
      isRecommended: isRecommended,
      isVerifiedPurchase: isVerifiedPurchase,
      helpfulCount: helpfulCount,
      notHelpfulCount: notHelpfulCount,
      viewsCount: viewsCount,
      images: images,
    );
  }

  // ============================================
  // HELPERS DE VALIDATION
  // ============================================

  bool get hasValidRating => rating >= 1 && rating <= 5;
  bool get hasValidContent => content.trim().isNotEmpty;
  bool get isValid => hasValidRating && hasValidContent;
  bool get canBeApproved => isValid && isPending;
  bool get canBeRejected => isPending || isApproved;
  bool get canBeMarkedAsSpam => !isSpam;
  bool get canBeResponded => isApproved || isPending;

  // ============================================
  // COPYWITH
  // ============================================

  @override
  AdminReviewModel copyWith({
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
    return AdminReviewModel(
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

  // ============================================
  // ÉGALITÉ ET HASHCODE
  // ============================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdminReviewModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'AdminReviewModel(id: $id, user: $userName, product: $productName, '
        'rating: $rating/5, status: ${status.displayName}, '
        'helpful: $helpfulCount/$totalVotes, images: ${images.length})';
  }
}