// Entité Address (Domaine)
// Représente une adresse de livraison

class Address {
  final int id;
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

  const Address({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    this.state,
    this.postalCode,
    this.country = 'Cameroun',
    this.type = 'home',
    this.isDefault = false,
    this.latitude,
    this.longitude,
    this.deliveryInstructions,
    this.isActive = true,
  });

  /// Adresse complète formatée
  String get fullAddress {
    final parts = <String>[];
    parts.add(addressLine1);
    if (addressLine2 != null && addressLine2!.isNotEmpty) {
      parts.add(addressLine2!);
    }
    parts.add(city);
    if (state != null && state!.isNotEmpty) {
      parts.add(state!);
    }
    parts.add(country);
    return parts.join(', ');
  }

  /// Label du type d'adresse
  String get typeLabel {
    switch (type) {
      case 'home':
        return 'Domicile';
      case 'work':
        return 'Travail';
      case 'other':
        return 'Autre';
      default:
        return 'Domicile';
    }
  }

  /// Icône du type d'adresse
  String get typeIcon {
    switch (type) {
      case 'home':
        return '🏠';
      case 'work':
        return '🏢';
      case 'other':
        return '📍';
      default:
        return '🏠';
    }
  }

  /// Couleur du type (int pour usage Color)
  int get typeColor {
    switch (type) {
      case 'home':
        return 0xFF27AE60;
      case 'work':
        return 0xFF3498DB;
      case 'other':
        return 0xFF7F8C8D;
      default:
        return 0xFF27AE60;
    }
  }

  /// Copier avec modifications
  Address copyWith({
    int? id,
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
  }) {
    return Address(
      id: id ?? this.id,
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
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
    };
  }

  /// Créer depuis JSON
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as int? ?? 0,
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      addressLine1: json['address_line1'] as String? ?? '',
      addressLine2: json['address_line2'] as String?,
      city: json['city'] as String? ?? '',
      state: json['state'] as String?,
      postalCode: json['postal_code'] as String?,
      country: json['country'] as String? ?? 'Cameroun',
      type: json['type'] as String? ?? 'home',
      isDefault: json['is_default'] as bool? ?? false,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      deliveryInstructions: json['delivery_instructions'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}