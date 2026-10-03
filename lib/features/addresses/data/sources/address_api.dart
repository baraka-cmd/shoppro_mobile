// ============================================
// API DES ADRESSES - COUCHE RÉSEAU
// ============================================
// Toutes les requêtes HTTP vers le backend Laravel.
// Gère : liste, détails, création, modification,
// suppression, adresse par défaut.
// ============================================

import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/address.dart';

class AddressApi {
  final Dio _dio = ApiClient().dio;

  // ============================================
  // LECTURE
  // ============================================

  /// Récupérer la liste des adresses de l'utilisateur connecté
  Future<List<Address>> getAddresses({
    String? type,
    bool? defaultOnly,
  }) async {
    try {
      final params = <String, dynamic>{};

      if (type != null && type.isNotEmpty) {
        params['type'] = type;
      }
      if (defaultOnly == true) {
        params['default'] = '1';
      }

      final response = await _dio.get(
        '/addresses',
        queryParameters: params.isEmpty ? null : params,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map((json) => Address.fromJson(json))
              .toList();
        }
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer une adresse par ID
  Future<Address> getAddressById(int id) async {
    try {
      final response = await _dio.get('/addresses/$id');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return Address.fromJson(data);
        }
      }

      throw Exception('Adresse introuvable');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // CRÉATION
  // ============================================

  /// Créer une nouvelle adresse côté serveur
  Future<Address> createAddress({
    required String fullName,
    required String phone,
    String? email,
    required String addressLine1,
    String? addressLine2,
    required String city,
    String? state,
    String? postalCode,
    String? country,
    String type = 'home',
    bool isDefault = false,
    double? latitude,
    double? longitude,
    String? deliveryInstructions,
  }) async {
    try {
      final body = <String, dynamic>{
        'full_name': fullName,
        'phone': phone,
        'address_line1': addressLine1,
        'city': city,
        'type': type,
        'is_default': isDefault,
      };

      if (email != null && email.isNotEmpty) {
        body['email'] = email;
      }
      if (addressLine2 != null && addressLine2.isNotEmpty) {
        body['address_line2'] = addressLine2;
      }
      if (state != null && state.isNotEmpty) {
        body['state'] = state;
      }
      if (postalCode != null && postalCode.isNotEmpty) {
        body['postal_code'] = postalCode;
      }
      if (country != null && country.isNotEmpty) {
        body['country'] = country;
      }
      if (latitude != null) {
        body['latitude'] = latitude;
      }
      if (longitude != null) {
        body['longitude'] = longitude;
      }
      if (deliveryInstructions != null &&
          deliveryInstructions.isNotEmpty) {
        body['delivery_instructions'] = deliveryInstructions;
      }

      final response = await _dio.post('/addresses', data: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['success'] == true) {
          final data = response.data['data'];
          if (data is Map<String, dynamic>) {
            return Address.fromJson(data);
          }
        }
      }

      throw Exception('Échec de la création de l\'adresse');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // MODIFICATION
  // ============================================

  /// Mettre à jour une adresse côté serveur
  Future<Address> updateAddress({
    required int id,
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
  }) async {
    try {
      final body = <String, dynamic>{};

      if (fullName != null) body['full_name'] = fullName;
      if (phone != null) body['phone'] = phone;
      if (email != null) body['email'] = email;
      if (addressLine1 != null) body['address_line1'] = addressLine1;
      if (addressLine2 != null) body['address_line2'] = addressLine2;
      if (city != null) body['city'] = city;
      if (state != null) body['state'] = state;
      if (postalCode != null) body['postal_code'] = postalCode;
      if (country != null) body['country'] = country;
      if (type != null) body['type'] = type;
      if (isDefault != null) body['is_default'] = isDefault;
      if (latitude != null) body['latitude'] = latitude;
      if (longitude != null) body['longitude'] = longitude;
      if (deliveryInstructions != null) {
        body['delivery_instructions'] = deliveryInstructions;
      }

      final response = await _dio.put('/addresses/$id', data: body);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return Address.fromJson(data);
        }
      }

      throw Exception('Échec de la mise à jour de l\'adresse');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // ADRESSE PAR DÉFAUT
  // ============================================

  /// Définir une adresse comme par défaut
  Future<Address> setDefaultAddress(int id) async {
    try {
      final response = await _dio.post('/addresses/$id/set-default');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return Address.fromJson(data);
        }
      }

      throw Exception('Échec de la mise à jour de l\'adresse par défaut');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // SUPPRESSION
  // ============================================

  /// Supprimer une adresse (soft delete côté serveur)
  Future<void> deleteAddress(int id) async {
    try {
      final response = await _dio.delete('/addresses/$id');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return;
      }

      throw Exception('Échec de la suppression de l\'adresse');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // GESTION DES ERREURS
  // ============================================

  Exception _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return Exception(
            'Connexion lente. Vérifiez votre réseau et réessayez.');

      case DioExceptionType.connectionError:
        return Exception('Impossible de se connecter au serveur.');

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;

        if (data is Map<String, dynamic>) {
          // Erreurs de validation Laravel
          if (data['errors'] is Map) {
            final errors = data['errors'] as Map;
            if (errors.isNotEmpty) {
              final firstError = errors.values.first;
              if (firstError is List && firstError.isNotEmpty) {
                return Exception(firstError.first.toString());
              }
              return Exception(firstError.toString());
            }
          }
          if (data['message'] != null &&
              data['message'].toString().isNotEmpty) {
            return Exception(data['message'].toString());
          }
          if (data['error'] != null && data['error'].toString().isNotEmpty) {
            return Exception(data['error'].toString());
          }
        }

        if (statusCode == 401) {
          return Exception('Session expirée. Veuillez vous reconnecter.');
        }
        if (statusCode == 403) {
          return Exception('Accès refusé.');
        }
        if (statusCode == 404) {
          return Exception('Adresse introuvable.');
        }
        if (statusCode == 422) {
          return Exception('Données invalides.');
        }
        if (statusCode == 500) {
          return Exception('Erreur serveur. Réessayez plus tard.');
        }

        return Exception('Erreur ${statusCode ?? 'inconnue'}.');

      case DioExceptionType.cancel:
        return Exception('Requête annulée.');

      default:
        return Exception('Une erreur est survenue. Veuillez réessayer.');
    }
  }
}