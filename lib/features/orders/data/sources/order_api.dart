// ============================================
// API DES COMMANDES - COUCHE RÉSEAU
// ============================================
// Toutes les requêtes HTTP vers le backend Laravel.
// Gère : création, lecture, annulation, retour,
// facture, timeline.
//
// ⚠️ La création envoie les items directement dans
//    le body (le serveur ne dépend plus de son panier).
// ============================================

import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/order_model.dart';

class OrderApi {
  final Dio _dio = ApiClient().dio;

  // ============================================
  // LECTURE
  // ============================================

  /// Récupérer la liste des commandes du client
  Future<List<OrderModel>> getOrders({
    int page = 1,
    int perPage = 20,
    String? status,
  }) async {
    try {
      final params = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };
      if (status != null) params['status'] = status;

      final response = await _dio.get(
        '/orders',
        queryParameters: params,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map((json) => OrderModel.fromJson(json))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer une commande par ID serveur
  Future<OrderModel> getOrderById(int id) async {
    try {
      final response = await _dio.get('/orders/$id');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return OrderModel.fromJson(response.data['data']);
      }
      throw Exception('Commande introuvable');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer les détails d'une commande (avec items)
  Future<OrderModel> getOrderDetails(int id) async {
    try {
      final response = await _dio.get('/orders/$id');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return OrderModel.fromJson(response.data['data']);
      }
      throw Exception('Commande introuvable');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // CRÉATION
  // ============================================

  /// Créer une nouvelle commande côté serveur.
  ///
  /// [shippingAddressId] : ID de l'adresse de livraison (obligatoire)
  /// [billingAddressId]  : ID de l'adresse de facturation (optionnel)
  /// [shippingMethod]    : 'standard' | 'express' | 'pickup'
  /// [paymentMethod]     : 'cash_on_delivery' | 'mobile_money' | 'card'
  /// [couponCode]        : code promo (optionnel)
  /// [customerNote]      : note du client (optionnel)
  /// [items]             : liste des articles à commander (obligatoire)
  Future<OrderModel> createOrder({
    required int shippingAddressId,
    int? billingAddressId,
    String? shippingMethod,
    String? paymentMethod,
    String? couponCode,
    String? customerNote,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final body = <String, dynamic>{
        'shipping_address_id': shippingAddressId,
        'items': items,
      };

      if (billingAddressId != null) {
        body['billing_address_id'] = billingAddressId;
      }
      if (shippingMethod != null) body['shipping_method'] = shippingMethod;
      if (paymentMethod != null) body['payment_method'] = paymentMethod;
      if (couponCode != null && couponCode.isNotEmpty) {
        body['coupon_code'] = couponCode;
      }
      if (customerNote != null && customerNote.isNotEmpty) {
        body['customer_note'] = customerNote;
      }

      final response = await _dio.post('/orders', data: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['success'] == true) {
          return OrderModel.fromJson(response.data['data']);
        }
      }
      throw Exception('Échec de la création de la commande');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // ACTIONS
  // ============================================

  /// Annuler une commande
  Future<OrderModel> cancelOrder(int id, String reason) async {
    try {
      final response = await _dio.post(
        '/orders/$id/cancel',
        data: {'reason': reason},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return OrderModel.fromJson(response.data['data']);
      }
      throw Exception('Échec de l\'annulation');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer le suivi d'une commande
  Future<Map<String, dynamic>> trackOrder(int id) async {
    try {
      final response = await _dio.get('/orders/$id/track');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }
      throw Exception('Échec du suivi');
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
          return Exception('Commande introuvable.');
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