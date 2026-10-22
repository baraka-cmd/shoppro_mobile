// ============================================
// MODEL : SellerReviewModel
// ============================================
// Sérialisation JSON pour SellerReview + SellerReviewsStats.
//
// Responsabilités :
//   - Parser la réponse API /seller/reviews
//   - Gérer les valeurs null (parsing défensif)
//   - Convertir types (num → double/int)
//   - Fournir des fallbacks sûrs
// ============================================

import '../../domain/entities/seller_review.dart';

// ============================================
// MODEL PRINCIPAL
// ============================================

class SellerReviewModel extends SellerReview {
  const SellerReviewModel({
    required super.id,
    required super.rating,
    required super.ratingLabel,
    super.title,
    required super.content,
    required super.status,
    required super.statusLabel,
    required super.statusColor,
    super.createdAt,
    super.createdAtHuman,
    super.customer,
    super.product,
    super.images,
    super.isVerifiedPurchase,
    super.helpfulCount,
    super.notHelpfulCount,
    super.helpfulRate,
    super.helpfulRateFormatted,
    super.adminResponse,
    super.adminResponseAt,
    super.hasAdminResponse,
    super.canRespond,
    super.canApprove,
    super.canReject,
    super.canMarkSpam,
  });

  // ============================================
  // JSON → MODEL
  // ============================================

  factory SellerReviewModel.fromJson(Map<String, dynamic> json) {
    return SellerReviewModel(
      id: _parseInt(json['id']),
      rating: _parseInt(json['rating']),
      ratingLabel: _parseString(json['rating_label'], 'Non noté'),
      title: _parseNullableString(json['title']),
      content: _parseString(json['content']),
      status: _parseString(json['status'], 'pending'),
      statusLabel: _parseString(json['status_label'], 'En attente'),
      statusColor: _parseString(json['status_color'], '#F59E0B'),
      createdAt: _parseDate(json['created_at']),
      createdAtHuman: _parseNullableString(json['created_at_human']),
      customer: json['customer'] is Map
          ? SellerReviewCustomerModel.fromJson(
              Map<String, dynamic>.from(json['customer'] as Map),
            )
          : null,
      product: json['product'] is Map
          ? SellerReviewProductModel.fromJson(
              Map<String, dynamic>.from(json['product'] as Map),
            )
          : null,
      images: _parseImagesList(json['images']),
      isVerifiedPurchase: _parseBool(json['is_verified_purchase']),
      helpfulCount: _parseInt(json['helpful_count']),
      notHelpfulCount: _parseInt(json['not_helpful_count']),
      helpfulRate: _parseDouble(json['helpful_rate']),
      helpfulRateFormatted: _parseString(json['helpful_rate_formatted'], '0%'),
      adminResponse: _parseNullableString(json['admin_response']),
      adminResponseAt: _parseDate(json['admin_response_at']),
      hasAdminResponse: _parseBool(json['has_admin_response']),
      canRespond: _parseBool(json['can_respond']),
      canApprove: _parseBool(json['can_approve']),
      canReject: _parseBool(json['can_reject']),
      canMarkSpam: _parseBool(json['can_mark_spam']),
    );
  }

  // ============================================
  // MODEL → JSON
  // ============================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rating': rating,
      'rating_label': ratingLabel,
      'title': title,
      'content': content,
      'status': status,
      'status_label': statusLabel,
      'status_color': statusColor,
      'created_at': createdAt?.toIso8601String(),
      'created_at_human': createdAtHuman,
      'customer': customer != null
          ? SellerReviewCustomerModel.fromEntity(customer!).toJson()
          : null,
      'product': product != null
          ? SellerReviewProductModel.fromEntity(product!).toJson()
          : null,
      'images': images
          .map((i) => SellerReviewImageModel.fromEntity(i).toJson())
          .toList(),
      'is_verified_purchase': isVerifiedPurchase,
      'helpful_count': helpfulCount,
      'not_helpful_count': notHelpfulCount,
      'helpful_rate': helpfulRate,
      'helpful_rate_formatted': helpfulRateFormatted,
      'admin_response': adminResponse,
      'admin_response_at': adminResponseAt?.toIso8601String(),
      'has_admin_response': hasAdminResponse,
      'can_respond': canRespond,
      'can_approve': canApprove,
      'can_reject': canReject,
      'can_mark_spam': canMarkSpam,
    };
  }

  // ============================================
  // fromEntity
  // ============================================

  factory SellerReviewModel.fromEntity(SellerReview entity) {
    return SellerReviewModel(
      id: entity.id,
      rating: entity.rating,
      ratingLabel: entity.ratingLabel,
      title: entity.title,
      content: entity.content,
      status: entity.status,
      statusLabel: entity.statusLabel,
      statusColor: entity.statusColor,
      createdAt: entity.createdAt,
      createdAtHuman: entity.createdAtHuman,
      customer: entity.customer,
      product: entity.product,
      images: entity.images,
      isVerifiedPurchase: entity.isVerifiedPurchase,
      helpfulCount: entity.helpfulCount,
      notHelpfulCount: entity.notHelpfulCount,
      helpfulRate: entity.helpfulRate,
      helpfulRateFormatted: entity.helpfulRateFormatted,
      adminResponse: entity.adminResponse,
      adminResponseAt: entity.adminResponseAt,
      hasAdminResponse: entity.hasAdminResponse,
      canRespond: entity.canRespond,
      canApprove: entity.canApprove,
      canReject: entity.canReject,
      canMarkSpam: entity.canMarkSpam,
    );
  }
}

// ============================================
// MODEL : SellerReviewCustomerModel
// ============================================

class SellerReviewCustomerModel extends SellerReviewCustomer {
  const SellerReviewCustomerModel({
    required super.name,
    required super.initials,
  });

  factory SellerReviewCustomerModel.fromJson(Map<String, dynamic> json) {
    return SellerReviewCustomerModel(
      name: _parseString(json['name'], 'Client'),
      initials: _parseString(json['initials'], '?'),
    );
  }

  factory SellerReviewCustomerModel.fromEntity(SellerReviewCustomer e) {
    return SellerReviewCustomerModel(
      name: e.name,
      initials: e.initials,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'initials': initials,
    };
  }
}

// ============================================
// MODEL : SellerReviewProductModel
// ============================================

class SellerReviewProductModel extends SellerReviewProduct {
  const SellerReviewProductModel({
    required super.id,
    required super.name,
    super.imageUrl,
    super.sku,
  });

  factory SellerReviewProductModel.fromJson(Map<String, dynamic> json) {
    return SellerReviewProductModel(
      id: _parseInt(json['id']),
      name: _parseString(json['name'], 'Produit'),
      imageUrl: _parseNullableString(json['image_url']),
      sku: _parseNullableString(json['sku']),
    );
  }

  factory SellerReviewProductModel.fromEntity(SellerReviewProduct e) {
    return SellerReviewProductModel(
      id: e.id,
      name: e.name,
      imageUrl: e.imageUrl,
      sku: e.sku,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'sku': sku,
    };
  }
}

// ============================================
// MODEL : SellerReviewImageModel
// ============================================

class SellerReviewImageModel extends SellerReviewImage {
  const SellerReviewImageModel({
    required super.id,
    required super.url,
    super.thumbnail,
    super.altText,
  });

  factory SellerReviewImageModel.fromJson(Map<String, dynamic> json) {
    return SellerReviewImageModel(
      id: _parseInt(json['id']),
      url: _parseString(json['url']),
      thumbnail: _parseNullableString(json['thumbnail']),
      altText: _parseNullableString(json['alt_text']),
    );
  }

  factory SellerReviewImageModel.fromEntity(SellerReviewImage e) {
    return SellerReviewImageModel(
      id: e.id,
      url: e.url,
      thumbnail: e.thumbnail,
      altText: e.altText,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'thumbnail': thumbnail,
      'alt_text': altText,
    };
  }
}

// ============================================
// MODEL : SellerReviewsStatsModel
// ============================================

class SellerReviewsStatsModel extends SellerReviewsStats {
  const SellerReviewsStatsModel({
    super.total,
    super.pending,
    super.approved,
    super.rejected,
    super.spam,
    super.withPhotos,
    super.verified,
    super.averageRating,
    super.toModerate,
  });

  factory SellerReviewsStatsModel.fromJson(Map<String, dynamic> json) {
    return SellerReviewsStatsModel(
      total: _parseInt(json['total']),
      pending: _parseInt(json['pending']),
      approved: _parseInt(json['approved']),
      rejected: _parseInt(json['rejected']),
      spam: _parseInt(json['spam']),
      withPhotos: _parseInt(json['with_photos']),
      verified: _parseInt(json['verified']),
      averageRating: _parseDouble(json['average_rating']),
      toModerate: _parseInt(json['to_moderate']),
    );
  }

  factory SellerReviewsStatsModel.fromEntity(SellerReviewsStats e) {
    return SellerReviewsStatsModel(
      total: e.total,
      pending: e.pending,
      approved: e.approved,
      rejected: e.rejected,
      spam: e.spam,
      withPhotos: e.withPhotos,
      verified: e.verified,
      averageRating: e.averageRating,
      toModerate: e.toModerate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'pending': pending,
      'approved': approved,
      'rejected': rejected,
      'spam': spam,
      'with_photos': withPhotos,
      'verified': verified,
      'average_rating': averageRating,
      'to_moderate': toModerate,
    };
  }
}

// ============================================
// HELPERS DE PARSING
// ============================================

int _parseInt(dynamic value, {int defaultValue = 0}) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? defaultValue;
  return defaultValue;
}

double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
  if (value == null) return defaultValue;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? defaultValue;
  return defaultValue;
}

String _parseString(dynamic value, [String defaultValue = '']) {
  if (value == null) return defaultValue;
  return value.toString();
}

String? _parseNullableString(dynamic value) {
  if (value == null) return null;
  final str = value.toString();
  return str.isEmpty ? null : str;
}

bool _parseBool(dynamic value, {bool defaultValue = false}) {
  if (value == null) return defaultValue;
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) {
    final lower = value.toLowerCase();
    return lower == 'true' || lower == '1' || lower == 'yes';
  }
  return defaultValue;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

List<SellerReviewImage> _parseImagesList(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((e) => SellerReviewImageModel.fromJson(Map<String, dynamic>.from(e)))
      .toList();
}