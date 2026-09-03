// ============================================
// ENTITÉ ADDRESS (DOMAINE) - VERSION PREMIUM
// ============================================
// Représente une adresse de livraison adaptée
// au contexte RDC avec point de repère et GPS.
// Design ShopPro.
// ============================================

class Address {
  final int id;
  final String label;
  final String fullName;
  final String phone;
  final String? email;
  final String province;
  final String city;
  final String commune;
  final String? quartier;
  final String? avenue;
  final String? landmark;
  final String? additionalInfo;
  final String country;
  final String type;
  final bool isDefault;
  final double? latitude;
  final double? longitude;
  final String? deliveryInstructions;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Address({
    required this.id,
    required this.label,
    required this.fullName,
    required this.phone,
    this.email,
    required this.province,
    required this.city,
    required this.commune,
    this.quartier,
    this.avenue,
    this.landmark,
    this.additionalInfo,
    this.country = 'RDC',
    this.type = 'home',
    this.isDefault = false,
    this.latitude,
    this.longitude,
    this.deliveryInstructions,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  // ============================================
  // ADRESSE COMPLÈTE
  // ============================================

  /// Adresse complète formatée
  String get fullAddress {
    final parts = <String>[];
    if (quartier != null && quartier!.isNotEmpty) parts.add(quartier!);
    if (avenue != null && avenue!.isNotEmpty) parts.add(avenue!);
    parts.add(commune);
    parts.add(city);
    parts.add(province);
    if (country.isNotEmpty) parts.add(country);
    return parts.join(', ');
  }

  /// Adresse courte (ville + commune)
  String get shortAddress {
    return '$commune, $city';
  }

  /// Affichage principal (label + ville)
  String get displayLabel {
    if (label.isNotEmpty) return label;
    return typeLabel;
  }

  // ============================================
  // TYPE
  // ============================================

  /// Label du type d'adresse
  String get typeLabel {
    switch (type) {
      case 'home':
        return 'Domicile';
      case 'work':
        return 'Travail';
      case 'shop':
        return 'Boutique';
      case 'parents':
        return 'Famille';
      case 'other':
        return 'Autre';
      default:
        return 'Domicile';
    }
  }

  /// Emoji du type d'adresse
  String get typeEmoji {
    switch (type) {
      case 'home':
        return '🏠';
      case 'work':
        return '🏢';
      case 'shop':
        return '🏪';
      case 'parents':
        return '👨‍👩‍👦';
      case 'other':
        return '📍';
      default:
        return '🏠';
    }
  }

  /// Couleur du type (hex)
  int get typeColorHex {
    switch (type) {
      case 'home':
        return 0xFF087F5B; // Emerald
      case 'work':
        return 0xFF3B82F6; // Bleu
      case 'shop':
        return 0xFFF4B942; // Gold
      case 'parents':
        return 0xFFE91E63; // Rose
      case 'other':
        return 0xFF68756F; // Gris
      default:
        return 0xFF087F5B;
    }
  }

  // ============================================
  // GPS
  // ============================================

  /// Le GPS est-il disponible ?
  bool get hasGps => latitude != null && longitude != null;

  /// Le point de repère est-il défini ?
  bool get hasLandmark => landmark != null && landmark!.isNotEmpty;

  /// Les instructions sont-elles définies ?
  bool get hasDeliveryInstructions =>
      deliveryInstructions != null && deliveryInstructions!.isNotEmpty;

  // ============================================
  // BADGES
  // ============================================

  /// Badges actifs de l'adresse
  List<String> get activeBadges {
    final badges = <String>[];
    if (isDefault) badges.add('⭐ DÉFAUT');
    if (hasGps) badges.add('🛰️ GPS');
    if (hasLandmark) badges.add('📍 REPÈRE');
    return badges;
  }

  // ============================================
  // VALIDATION
  // ============================================

  /// L'adresse a-t-elle des données valides ?
  bool get isValid {
    return id > 0 &&
        fullName.isNotEmpty &&
        phone.isNotEmpty &&
        province.isNotEmpty &&
        city.isNotEmpty &&
        commune.isNotEmpty;
  }

  /// Le téléphone est-il valide (format RDC) ?
  bool get hasValidPhone {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    return cleaned.length >= 10 && cleaned.length <= 13;
  }

  // ============================================
  // MÉTHODES
  // ============================================

  /// Copier avec modifications
  Address copyWith({
    int? id,
    String? label,
    String? fullName,
    String? phone,
    String? email,
    String? province,
    String? city,
    String? commune,
    String? quartier,
    String? avenue,
    String? landmark,
    String? additionalInfo,
    String? country,
    String? type,
    bool? isDefault,
    double? latitude,
    double? longitude,
    String? deliveryInstructions,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Address(
      id: id ?? this.id,
      label: label ?? this.label,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      province: province ?? this.province,
      city: city ?? this.city,
      commune: commune ?? this.commune,
      quartier: quartier ?? this.quartier,
      avenue: avenue ?? this.avenue,
      landmark: landmark ?? this.landmark,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      country: country ?? this.country,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'province': province,
      'city': city,
      'commune': commune,
      'quartier': quartier,
      'avenue': avenue,
      'landmark': landmark,
      'additional_info': additionalInfo,
      'country': country,
      'type': type,
      'is_default': isDefault,
      'latitude': latitude,
      'longitude': longitude,
      'delivery_instructions': deliveryInstructions,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Créer depuis JSON
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as int? ?? 0,
      label: json['label'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      province: json['province'] as String? ?? '',
      city: json['city'] as String? ?? '',
      commune: json['commune'] as String? ?? '',
      quartier: json['quartier'] as String?,
      avenue: json['avenue'] as String?,
      landmark: json['landmark'] as String?,
      additionalInfo: json['additional_info'] as String?,
      country: json['country'] as String? ?? 'RDC',
      type: json['type'] as String? ?? 'home',
      isDefault: json['is_default'] as bool? ?? false,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      deliveryInstructions: json['delivery_instructions'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
    );
  }

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'Address(id: $id, label: $displayLabel, '
        'fullName: $fullName, city: $city, commune: $commune, '
        'default: $isDefault, gps: $hasGps)';
  }
}