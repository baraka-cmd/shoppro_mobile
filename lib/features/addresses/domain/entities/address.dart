// ============================================
// ENTITÉ ADDRESS (DOMAINE) - VERSION PREMIUM
// ============================================
// Représente une adresse de livraison adaptée
// au contexte RDC avec point de repère et GPS.
// Design ShopPro.
// ============================================

class Address {
  final int id;
  final int? userId;

  // ============================================
  // CHAMPS API (Laravel user_addresses)
  // ============================================
  final String fullName;
  final String phone;
  final String? email;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String? state;
  final String? postalCode;
  final String country;
  final String type;
  final bool isDefault;
  final double? latitude;
  final double? longitude;
  final String? deliveryInstructions;
  final bool isActive;

  // ============================================
  // CHAMPS ÉTENDUS (côté Flutter uniquement)
  // ============================================
  final String label;
  final String? commune;
  final String? quartier;
  final String? landmark;
  final String? additionalInfo;

  // ============================================
  // HORODATAGE
  // ============================================
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Address({
    required this.id,
    this.userId,
    required this.fullName,
    required this.phone,
    this.email,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    this.state,
    this.postalCode,
    this.country = 'RDC',
    this.type = 'home',
    this.isDefault = false,
    this.latitude,
    this.longitude,
    this.deliveryInstructions,
    this.isActive = true,
    this.label = '',
    this.commune,
    this.quartier,
    this.landmark,
    this.additionalInfo,
    this.createdAt,
    this.updatedAt,
  });

  // ============================================
  // ADRESSE COMPLÈTE
  // ============================================

  String get fullAddress {
    final parts = <String>[];
    if (addressLine1.isNotEmpty) parts.add(addressLine1);
    if (addressLine2 != null && addressLine2!.isNotEmpty) {
      parts.add(addressLine2!);
    }
    if (commune != null && commune!.isNotEmpty) parts.add(commune!);
    if (city.isNotEmpty) parts.add(city);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (country.isNotEmpty) parts.add(country);
    return parts.join(', ');
  }

  String get shortAddress {
    if (commune != null && commune!.isNotEmpty) {
      return '$commune, $city';
    }
    return city;
  }

  String get displayLabel {
    if (label.isNotEmpty) return label;
    return typeLabel;
  }

  // ============================================
  // TYPE
  // ============================================

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

  int get typeColorHex {
    switch (type) {
      case 'home':
        return 0xFF087F5B;
      case 'work':
        return 0xFF3B82F6;
      case 'shop':
        return 0xFFF4B942;
      case 'parents':
        return 0xFFE91E63;
      case 'other':
        return 0xFF68756F;
      default:
        return 0xFF087F5B;
    }
  }

  // ============================================
  // GPS / POINT DE REPÈRE
  // ============================================

  bool get hasGps => latitude != null && longitude != null;
  bool get hasLandmark => landmark != null && landmark!.isNotEmpty;
  bool get hasDeliveryInstructions =>
      deliveryInstructions != null && deliveryInstructions!.isNotEmpty;

  // ============================================
  // BADGES
  // ============================================

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

  bool get isValid {
    return id > 0 &&
        fullName.isNotEmpty &&
        phone.isNotEmpty &&
        addressLine1.isNotEmpty &&
        city.isNotEmpty;
  }

  bool get hasValidPhone {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    return cleaned.length >= 10 && cleaned.length <= 15;
  }

  // ============================================
  // MÉTHODES
  // ============================================

  Address copyWith({
    int? id,
    int? userId,
    String? fullName,
    String? phone,
    String? email,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    String? type,
    bool? isDefault,
    double? latitude,
    double? longitude,
    String? deliveryInstructions,
    bool? isActive,
    String? label,
    String? commune,
    String? quartier,
    String? landmark,
    String? additionalInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Address(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      deliveryInstructions:
          deliveryInstructions ?? this.deliveryInstructions,
      isActive: isActive ?? this.isActive,
      label: label ?? this.label,
      commune: commune ?? this.commune,
      quartier: quartier ?? this.quartier,
      landmark: landmark ?? this.landmark,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      'type': type,
      'is_default': isDefault,
      'latitude': latitude,
      'longitude': longitude,
      'delivery_instructions': deliveryInstructions,
      'is_active': isActive,
      'label': label,
      'commune': commune,
      'quartier': quartier,
      'landmark': landmark,
      'additional_info': additionalInfo,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: _parseInt(json['id']),
      userId: _parseNullableInt(json['user_id']),
      fullName: _parseString(json['full_name']),
      phone: _parseString(json['phone']),
      email: _parseNullableString(json['email']),
      addressLine1: _parseString(json['address_line1']),
      addressLine2: _parseNullableString(json['address_line2']),
      city: _parseString(json['city']),
      state: _parseNullableString(json['state']),
      postalCode: _parseNullableString(json['postal_code']),
      country: _parseString(json['country'], defaultValue: 'RDC'),
      type: _parseString(json['type'], defaultValue: 'home'),
      isDefault: _parseBool(json['is_default']),
      latitude: _parseNullableDouble(json['latitude']),
      longitude: _parseNullableDouble(json['longitude']),
      deliveryInstructions:
          _parseNullableString(json['delivery_instructions']),
      isActive: _parseBool(json['is_active'], defaultValue: true),
      label: _parseString(json['label']),
      commune: _parseNullableString(json['commune']),
      quartier: _parseNullableString(json['quartier']),
      landmark: _parseNullableString(json['landmark']),
      additionalInfo: _parseNullableString(json['additional_info']),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  // ============================================
  // HELPERS DE PARSING
  // ============================================

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _parseNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value);
    return null;
  }

  static String _parseString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    final string = value.toString().trim();
    return string.isEmpty ? defaultValue : string;
  }

  static String? _parseNullableString(dynamic value) {
    if (value == null) return null;
    final string = value.toString().trim();
    return string.isEmpty ? null : string;
  }

  static bool _parseBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return defaultValue;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  @override
  String toString() {
    return 'Address(id: $id, label: $displayLabel, '
        'fullName: $fullName, city: $city, '
        'default: $isDefault, gps: $hasGps)';
  }
}