// ============================================
// MODÈLE ADDRESS (DATA) - VERSION PREMIUM
// ============================================
// Gère la sérialisation/désérialisation JSON
// avec parsing robuste et valeurs par défaut.
// ============================================

import '../../domain/entities/address.dart';

class AddressModel extends Address {
  const AddressModel({
    required super.id,
    required super.label,
    required super.fullName,
    required super.phone,
    super.email,
    required super.province,
    required super.city,
    required super.commune,
    super.quartier,
    super.avenue,
    super.landmark,
    super.additionalInfo,
    super.country,
    super.type,
    super.isDefault,
    super.latitude,
    super.longitude,
    super.deliveryInstructions,
    super.isActive,
    super.createdAt,
    super.updatedAt,
  });

  /// Créer depuis JSON
  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: _parseInt(json['id']),
      label: _parseString(json['label']),
      fullName: _parseString(json['full_name']),
      phone: _parseString(json['phone']),
      email: _parseNullableString(json['email']),
      province: _parseString(json['province']),
      city: _parseString(json['city']),
      commune: _parseString(json['commune']),
      quartier: _parseNullableString(json['quartier']),
      avenue: _parseNullableString(json['avenue']),
      landmark: _parseNullableString(json['landmark']),
      additionalInfo: _parseNullableString(json['additional_info']),
      country: _parseString(json['country'], defaultValue: 'RDC'),
      type: _parseString(json['type'], defaultValue: 'home'),
      isDefault: _parseBool(json['is_default']),
      latitude: _parseNullableDouble(json['latitude']),
      longitude: _parseNullableDouble(json['longitude']),
      deliveryInstructions: _parseNullableString(json['delivery_instructions']),
      isActive: _parseBool(json['is_active'], defaultValue: true),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  /// Convertir en JSON
  @override
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

  /// Copier depuis l'entité
  static AddressModel fromEntity(Address address) {
    return AddressModel(
      id: address.id,
      label: address.label,
      fullName: address.fullName,
      phone: address.phone,
      email: address.email,
      province: address.province,
      city: address.city,
      commune: address.commune,
      quartier: address.quartier,
      avenue: address.avenue,
      landmark: address.landmark,
      additionalInfo: address.additionalInfo,
      country: address.country,
      type: address.type,
      isDefault: address.isDefault,
      latitude: address.latitude,
      longitude: address.longitude,
      deliveryInstructions: address.deliveryInstructions,
      isActive: address.isActive,
      createdAt: address.createdAt,
      updatedAt: address.updatedAt,
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
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return defaultValue;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}