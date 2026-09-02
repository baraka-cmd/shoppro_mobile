// Modèle Address (Data)
// Gère la sérialisation/désérialisation JSON de l'adresse

import '../../domain/entities/address.dart';

class AddressModel extends Address {
  const AddressModel({
    required super.id,
    required super.fullName,
    required super.phone,
    super.email,
    required super.addressLine1,
    super.addressLine2,
    required super.city,
    super.state,
    super.postalCode,
    super.country,
    super.type,
    super.isDefault,
    super.latitude,
    super.longitude,
    super.deliveryInstructions,
    super.isActive,
  });

  /// Créer depuis JSON
  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
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
      latitude: _parseNullableDouble(json['latitude']),
      longitude: _parseNullableDouble(json['longitude']),
      deliveryInstructions: json['delivery_instructions'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  /// Convertir en JSON
  @override
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

  /// Parser un double nullable
  static double? _parseNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value);
    return null;
  }
}