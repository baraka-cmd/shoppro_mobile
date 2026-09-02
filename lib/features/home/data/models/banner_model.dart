// Modèle Banner (Data)
// Gère la sérialisation/désérialisation JSON de la bannière

class BannerModel {
  final int id;
  final String title;
  final String? subtitle;
  final String? description;
  final String? imageUrl;
  final String? imageMobileUrl;
  final String? thumbnailUrl;
  final String targetType;
  final String? targetId;
  final String? externalUrl;
  final String position;
  final int sortOrder;
  final bool isActive;
  final bool isAnimated;
  final DateTime? startDate;
  final DateTime? endDate;

  const BannerModel({
    required this.id,
    required this.title,
    this.subtitle,
    this.description,
    this.imageUrl,
    this.imageMobileUrl,
    this.thumbnailUrl,
    this.targetType = 'none',
    this.targetId,
    this.externalUrl,
    this.position = 'home_top',
    this.sortOrder = 0,
    this.isActive = true,
    this.isAnimated = false,
    this.startDate,
    this.endDate,
  });

  /// Créer depuis JSON
  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      description: json['description'] as String?,
      imageUrl: json['image'] as String?,
      imageMobileUrl: json['image_mobile'] as String?,
      thumbnailUrl: json['thumbnail'] as String?,
      targetType: json['target_type'] as String? ?? 'none',
      targetId: json['target_id'] as String?,
      externalUrl: json['external_url'] as String?,
      position: json['position'] as String? ?? 'home_top',
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      isAnimated: json['is_animated'] as bool? ?? false,
      startDate: DateTime.tryParse(json['start_date'] as String? ?? ''),
      endDate: DateTime.tryParse(json['end_date'] as String? ?? ''),
    );
  }

  /// Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'image': imageUrl,
      'image_mobile': imageMobileUrl,
      'thumbnail': thumbnailUrl,
      'target_type': targetType,
      'target_id': targetId,
      'external_url': externalUrl,
      'position': position,
      'sort_order': sortOrder,
      'is_active': isActive,
      'is_animated': isAnimated,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
    };
  }

  /// La bannière est-elle valide (dates) ?
  bool get isValid {
    final now = DateTime.now();

    if (startDate != null && now.isBefore(startDate!)) {
      return false;
    }

    if (endDate != null && now.isAfter(endDate!)) {
      return false;
    }

    return isActive;
  }
}