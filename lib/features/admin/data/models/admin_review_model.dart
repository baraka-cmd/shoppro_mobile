// ============================================
// MODEL : AdminReviewModel
// ============================================
// Modèle de sérialisation pour les avis clients administrés.
// Cette classe est dans la couche DATA et gère la conversion
// JSON ↔ Entité (AdminReview).
//
// Responsabilités :
// - Conversion JSON → AdminReview (fromJson)
// - Conversion AdminReview → JSON (toJson)
// - Conversion AdminReview → AdminReviewModel (fromEntity)
// - Conversion AdminReviewModel → AdminReview (toEntity)
// ============================================

// ============================================
// IMPORTS
// ============================================

// Flutter
import 'package:flutter/material.dart';

// Entities (même feature admin)
import '../../domain/entities/admin_review.dart';

// ============================================
// CLASSE PRINCIPALE
// ============================================

/// Modèle de données pour [AdminReview].
///
/// Cette classe étend [AdminReview] et ajoute les méthodes
/// de sérialisation JSON nécessaires pour l'API.
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
    required super.averageRating,
    required super.userId,
    required super.userName,
    super.userAvatar,
    required super.productId,
    required super.productName,
    super.productImage,
    super.orderId,
    super.orderNumber,
    super.isVerifiedPurchase,
    super.status,
    super.adminResponse,
    super.adminResponseAt,
    super.approvedAt,
    super.isRecommended,
    super.helpfulCount,
    super.notHelpfulCount,
    super.viewsCount,
    super.imagesCount,
  });

  // ============================================
  // CONVERSION : ENTITÉ → MODÈLE
  // ============================================

  /// Crée un modèle à partir d'une entité.
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
      averageRating: entity.averageRating,
      userId: entity.userId,
      userName: entity.userName,
      userAvatar: entity.userAvatar,
      productId: entity.productId,
      productName: entity.productName,
      productImage: entity.productImage,
      orderId: entity.orderId,
      orderNumber: entity.orderNumber,
      isVerifiedPurchase: entity.isVerifiedPurchase,
      status: entity.status,
      adminResponse: entity.adminResponse,
      adminResponseAt: entity.adminResponseAt,
      approvedAt: entity.approvedAt,
      isRecommended: entity.isRecommended,
      helpfulCount: entity.helpfulCount,
      notHelpfulCount: entity.notHelpfulCount,
      viewsCount: entity.viewsCount,
      imagesCount: entity.imagesCount,
    );
  }

  // ============================================
  // CONVERSION : JSON → MODÈLE
  // ============================================

  /// Crée un modèle à partir d'une Map JSON.
  ///
  /// Gère toutes les conversions de types sécurisées.
  factory AdminReviewModel.fromJson(Map<String, dynamic> json) {
    // Parse des informations utilisateur
    final user = json['user'] as Map<String, dynamic>? ?? {};
    final userName = user['name'] as String? ?? json['user_name'] as String? ?? 'Utilisateur';
    final userAvatar = user['avatar'] as String? ?? json['user_avatar'] as String?;

    // Parse des informations produit
    final product = json['product'] as Map<String, dynamic>? ?? {};
    final productName = product['name'] as String? ?? json['product_name'] as String? ?? 'Produit';
    final productImage = product['image'] as String? ?? json['product_image'] as String?;

    // Parse des informations commande
    final order = json['order'] as Map<String, dynamic>? ?? {};
    final orderNumber = order['order_number'] as String? ?? json['order_number'] as String?;

    return AdminReviewModel(
      // Informations de base
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
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0,

      // Auteur
      userId: (json['user_id'] as num?)?.toInt() ?? (user['id'] as num?)?.toInt() ?? 0,
      userName: userName,
      userAvatar: userAvatar,

      // Produit
      productId: (json['product_id'] as num?)?.toInt() ?? (product['id'] as num?)?.toInt() ?? 0,
      productName: productName,
      productImage: productImage,

      // Commande
      orderId: (json['order_id'] as num?)?.toInt(),
      orderNumber: orderNumber,
      isVerifiedPurchase: json['is_verified_purchase'] as bool? ?? 
        ((json['order_id'] as num?)?.toInt() != null),

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

      // Statistiques
      helpfulCount: (json['helpful_count'] as num?)?.toInt() ?? 0,
      notHelpfulCount: (json['not_helpful_count'] as num?)?.toInt() ?? 0,
      viewsCount: (json['views_count'] as num?)?.toInt() ?? 0,
      imagesCount: (json['images_count'] as num?)?.toInt() ?? 0,
    );
  }

  // ============================================
  // CONVERSION : MODÈLE → JSON
  // ============================================

  /// Convertit le modèle en Map JSON.
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

  // ============================================
  // CONVERSION : MODÈLE → ENTITÉ
  // ============================================

  /// Convertit le modèle en entité pure.
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
      averageRating: averageRating,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      productId: productId,
      productName: productName,
      productImage: productImage,
      orderId: orderId,
      orderNumber: orderNumber,
      isVerifiedPurchase: isVerifiedPurchase,
      status: status,
      adminResponse: adminResponse,
      adminResponseAt: adminResponseAt,
      approvedAt: approvedAt,
      isRecommended: isRecommended,
      helpfulCount: helpfulCount,
      notHelpfulCount: notHelpfulCount,
      viewsCount: viewsCount,
      imagesCount: imagesCount,
    );
  }

  // ============================================
  // HELPERS DE VALIDATION
  // ============================================

  /// Vérifie si la note est valide (1-5).
  bool get hasValidRating => rating >= 1 && rating <= 5;

  /// Vérifie si le contenu est valide.
  bool get hasValidContent => content.trim().isNotEmpty;

  /// Vérifie si l'avis est complet et valide.
  bool get isValid => hasValidRating && hasValidContent;

  /// Vérifie si l'avis peut être approuvé.
  bool get canBeApproved => isValid && isPending;

  /// Vérifie si l'avis peut être rejeté.
  bool get canBeRejected => isPending || isApproved;

  /// Vérifie si l'avis peut être marqué comme spam.
  bool get canBeMarkedAsSpam => !isSpam;

  /// Vérifie si l'avis peut recevoir une réponse admin.
  bool get canBeResponded => isApproved || isPending;

  // ============================================
  // COPYWITH
  // ============================================

  /// Crée une copie avec des champs modifiés.
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
        'helpful: $helpfulCount/$totalVotes, valid: $isValid)';
  }
}