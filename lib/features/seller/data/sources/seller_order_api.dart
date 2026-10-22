// ============================================
// API SOURCE : SellerOrderApi
// ============================================
// Gère les appels HTTP pour les commandes vendeur.
//
// Responsabilités :
//   - Liste paginée avec filtres (statut, recherche, dates)
//   - Détail d'une commande
//   - Actions : accept, prepare, ship, cancel
//
// Sécurité :
//   - Token injecté automatiquement par ApiClient (Dio interceptor)
//   - Gestion des codes HTTP : 200, 401, 403, 404, 409, 422, 500
//   - Messages d'erreur en français
// ============================================

// Flutter
import 'package:flutter/foundation.dart';

// Dio
import 'package:dio/dio.dart';

// Core
import '../../../../core/network/api_client.dart';

// Model
import '../models/seller_order_model.dart';

// ============================================
// EXCEPTIONS PERSONNALISÉES
// ============================================

class SellerOrderForbiddenException implements Exception {
  final String message;
  final String? code;

  SellerOrderForbiddenException(this.message, {this.code});

  @override
  String toString() => message;
}

class SellerOrderUnauthorizedException implements Exception {
  final String message;

  SellerOrderUnauthorizedException(this.message);

  @override
  String toString() => message;
}

class SellerOrderNotFoundException implements Exception {
  final String message;

  SellerOrderNotFoundException(this.message);

  @override
  String toString() => message;
}

class SellerOrderConflictException implements Exception {
  final String message;

  SellerOrderConflictException(this.message);

  @override
  String toString() => message;
}

class SellerOrderValidationException implements Exception {
  final String message;
  final Map<String, List<String>> errors;

  SellerOrderValidationException(this.message, {this.errors = const {}});

  @override
  String toString() => message;

  String? getFirstError(String field) {
    final fieldErrors = errors[field];
    return fieldErrors != null && fieldErrors.isNotEmpty
        ? fieldErrors.first
        : null;
  }
}

class SellerOrderServerException implements Exception {
  final String message;

  SellerOrderServerException(this.message);

  @override
  String toString() => message;
}

class SellerOrderNetworkException implements Exception {
  final String message;

  SellerOrderNetworkException(this.message);

  @override
  String toString() => message;
}

// ============================================
// RÉSULTAT PAGINÉ
// ============================================

class SellerOrdersResult {
  final List<SellerOrderModel> orders;
  final int total;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final bool hasMore;

  SellerOrdersResult({
    required this.orders,
    required this.total,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.hasMore,
  });
}

// ============================================
// API CLIENT
// ============================================

class SellerOrderApi {
  final Dio _dio;

  SellerOrderApi({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  // ============================================
  // INDEX — LISTE
  // ============================================

  /// GET /seller/orders
  ///
  /// Liste paginée des commandes du vendeur.
  ///
  /// [sellerStatus] : to_accept | accepted | preparing | ready_to_ship |
  ///                  shipped | delivered | cancelled | rejected | all
  /// [status]       : pending | confirmed | processing | shipped | delivered | cancelled
  /// [search]       : recherche par numéro de commande
  /// [dateFrom]     : Y-m-d
  /// [dateTo]       : Y-m-d
  Future<SellerOrdersResult> getOrders({
    int page = 1,
    int perPage = 15,
    String? sellerStatus,
    String? status,
    String? search,
    String? dateFrom,
    String? dateTo,
    String sortBy = 'created_at',
    String sortDir = 'desc',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
        'sort_by': sortBy,
        'sort_dir': sortDir,
      };

      if (sellerStatus != null && sellerStatus != 'all') {
        queryParams['seller_status'] = sellerStatus;
      }
      if (status != null && status != 'all') {
        queryParams['status'] = status;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (dateFrom != null && dateFrom.isNotEmpty) {
        queryParams['date_from'] = dateFrom;
      }
      if (dateTo != null && dateTo.isNotEmpty) {
        queryParams['date_to'] = dateTo;
      }

      final response = await _dio.get(
        '/seller/orders',
        queryParameters: queryParams,
      );

      return _parseOrdersListResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerOrderApi.getOrders: $e');
      throw SellerOrderServerException(
        'Impossible de récupérer les commandes.',
      );
    }
  }

  // ============================================
  // SHOW — DÉTAIL
  // ============================================

  /// GET /seller/orders/{id}
  Future<SellerOrderModel> getOrderById(int id) async {
    try {
      final response = await _dio.get('/seller/orders/$id');
      return _parseSingleOrderResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerOrderApi.getOrderById: $e');
      throw SellerOrderServerException(
        'Impossible de récupérer la commande.',
      );
    }
  }

  // ============================================
  // ACCEPT — ACCEPTER LES ITEMS
  // ============================================

  /// POST /seller/orders/{id}/accept
  ///
  /// Accepte tous les items `to_accept` du vendeur.
  Future<SellerOrderModel> acceptOrder(int id) async {
    try {
      final response = await _dio.post('/seller/orders/$id/accept');
      return _parseSingleOrderResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerOrderApi.acceptOrder: $e');
      throw SellerOrderServerException(
        'Impossible d\'accepter la commande.',
      );
    }
  }

  // ============================================
  // PREPARE — PASSER EN PRÉPARATION
  // ============================================

  /// POST /seller/orders/{id}/prepare
  Future<SellerOrderModel> prepareOrder(int id) async {
    try {
      final response = await _dio.post('/seller/orders/$id/prepare');
      return _parseSingleOrderResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerOrderApi.prepareOrder: $e');
      throw SellerOrderServerException(
        'Impossible de passer en préparation.',
      );
    }
  }

  // ============================================
  // SHIP — EXPÉDIER
  // ============================================

  /// POST /seller/orders/{id}/ship
  ///
  /// Expédie les items `preparing` ou `ready_to_ship`.
  ///
  /// [trackingNumber] : obligatoire
  /// [carrier]        : obligatoire (whitelist backend)
  /// [trackingUrl]    : optionnel (auto-généré si carrier connu)
  /// [shippedAt]      : optionnel (format Y-m-d H:i:s)
  /// [sellerNote]     : optionnel
  Future<SellerOrderModel> shipOrder(
    int id, {
    required String trackingNumber,
    required String carrier,
    String? trackingUrl,
    String? shippedAt,
    String? sellerNote,
  }) async {
    try {
      final body = <String, dynamic>{
        'tracking_number': trackingNumber,
        'carrier': carrier,
      };

      if (trackingUrl != null && trackingUrl.isNotEmpty) {
        body['tracking_url'] = trackingUrl;
      }
      if (shippedAt != null && shippedAt.isNotEmpty) {
        body['shipped_at'] = shippedAt;
      }
      if (sellerNote != null && sellerNote.isNotEmpty) {
        body['seller_note'] = sellerNote;
      }

      final response = await _dio.post(
        '/seller/orders/$id/ship',
        data: body,
      );

      return _parseSingleOrderResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerOrderApi.shipOrder: $e');
      throw SellerOrderServerException(
        'Impossible d\'expédier la commande.',
      );
    }
  }

  // ============================================
  // CANCEL — ANNULER
  // ============================================

  /// POST /seller/orders/{id}/cancel
  ///
  /// Annule les items annulables du vendeur.
  ///
  /// [reason]        : obligatoire (whitelist backend)
  /// [reasonDetails] : optionnel (obligatoire si reason = 'other')
  /// [restock]       : bool (défaut true)
  /// [itemIds]       : optionnel (si null → tous les items annulables)
  Future<SellerOrderModel> cancelOrder(
    int id, {
    required String reason,
    String? reasonDetails,
    bool restock = true,
    List<int>? itemIds,
  }) async {
    try {
      final body = <String, dynamic>{
        'reason': reason,
        'restock': restock,
      };

      if (reasonDetails != null && reasonDetails.isNotEmpty) {
        body['reason_details'] = reasonDetails;
      }
      if (itemIds != null && itemIds.isNotEmpty) {
        body['item_ids'] = itemIds;
      }

      final response = await _dio.post(
        '/seller/orders/$id/cancel',
        data: body,
      );

      return _parseSingleOrderResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerOrderApi.cancelOrder: $e');
      throw SellerOrderServerException(
        'Impossible d\'annuler la commande.',
      );
    }
  }

  // ============================================
  // PARSING
  // ============================================

  SellerOrdersResult _parseOrdersListResponse(Response response) {
    final body = response.data;

    if (body is! Map) {
      throw SellerOrderServerException('Format de réponse invalide.');
    }

    if (body['success'] != true) {
      throw SellerOrderServerException(
        body['message']?.toString() ?? 'Erreur inconnue.',
      );
    }

    final data = body['data'];
    final pagination = body['pagination'];

    if (data is! List) {
      throw SellerOrderServerException('Données manquantes.');
    }

    final orders = <SellerOrderModel>[];
    for (final item in data) {
      if (item is Map) {
        final map = Map<String, dynamic>.from(item);
        // Ignorer les "fausses" commandes (id null = pas d'items du vendeur)
        if (map['id'] != null) {
          orders.add(SellerOrderModel.fromJson(map));
        }
      }
    }

    final pag = pagination is Map ? pagination : {};

    return SellerOrdersResult(
      orders: orders,
      total: _toInt(pag['total']),
      currentPage: _toInt(pag['current_page'], defaultValue: 1),
      lastPage: _toInt(pag['last_page'], defaultValue: 1),
      perPage: _toInt(pag['per_page'], defaultValue: 15),
      hasMore: pag['has_more'] == true,
    );
  }

  SellerOrderModel _parseSingleOrderResponse(Response response) {
    final body = response.data;

    if (body is! Map) {
      throw SellerOrderServerException('Format de réponse invalide.');
    }

    if (body['success'] != true) {
      throw SellerOrderServerException(
        body['message']?.toString() ?? 'Erreur inconnue.',
      );
    }

    final data = body['data'];

    if (data is! Map) {
      throw SellerOrderServerException('Données de la commande manquantes.');
    }

    return SellerOrderModel.fromJson(Map<String, dynamic>.from(data));
  }

  // ============================================
  // GESTION DES ERREURS
  // ============================================

  Exception _handleError(DioException e) {
    debugPrint('❌ SellerOrderApi DioException: '
        '${e.type} - ${e.response?.statusCode} - ${e.message}');

    // Erreur réseau
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError) {
      return SellerOrderNetworkException(
        'Connexion impossible. Vérifiez votre réseau.',
      );
    }

    final statusCode = e.response?.statusCode;
    final body = e.response?.data;

    String message = 'Une erreur est survenue.';
    if (body is Map && body['message'] != null) {
      message = body['message'].toString();
    }

    switch (statusCode) {
      case 401:
        return SellerOrderUnauthorizedException(
          message.isNotEmpty
              ? message
              : 'Session expirée. Veuillez vous reconnecter.',
        );

      case 403:
        String? code;
        if (body is Map && body['code'] != null) {
          code = body['code'].toString();
        }
        return SellerOrderForbiddenException(message, code: code);

      case 404:
        return SellerOrderNotFoundException(
          message.isNotEmpty ? message : 'Commande introuvable.',
        );

      case 409:
        return SellerOrderConflictException(message);

      case 422:
        Map<String, List<String>> errors = {};
        if (body is Map && body['errors'] is Map) {
          final rawErrors = body['errors'] as Map;
          errors = rawErrors.map((key, value) {
            if (value is List) {
              return MapEntry(
                key.toString(),
                value.map((e) => e.toString()).toList(),
              );
            }
            return MapEntry(key.toString(), [value.toString()]);
          });
        }
        return SellerOrderValidationException(message, errors: errors);

      case 500:
      case 502:
      case 503:
        return SellerOrderServerException(
          message.isNotEmpty
              ? message
              : 'Le serveur rencontre un problème. Réessayez plus tard.',
        );

      default:
        return SellerOrderServerException(message);
    }
  }

  int _toInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }
}