// ============================================
// API SOURCE : SellerStockApi
// ============================================
// Gère les appels HTTP pour les stocks vendeur.
//
// Responsabilités :
//   - Liste paginée avec filtres (statut, entrepôt, recherche)
//   - Détail d'un stock + mouvements récents
//   - Ajustement manuel (avec raison et note)
//   - Historique paginé des mouvements
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
import '../models/seller_stock_model.dart';

// ============================================
// EXCEPTIONS PERSONNALISÉES
// ============================================

class SellerStockForbiddenException implements Exception {
  final String message;
  final String? code;

  SellerStockForbiddenException(this.message, {this.code});

  @override
  String toString() => message;
}

class SellerStockUnauthorizedException implements Exception {
  final String message;

  SellerStockUnauthorizedException(this.message);

  @override
  String toString() => message;
}

class SellerStockNotFoundException implements Exception {
  final String message;

  SellerStockNotFoundException(this.message);

  @override
  String toString() => message;
}

class SellerStockConflictException implements Exception {
  final String message;

  SellerStockConflictException(this.message);

  @override
  String toString() => message;
}

class SellerStockValidationException implements Exception {
  final String message;
  final Map<String, List<String>> errors;

  SellerStockValidationException(this.message, {this.errors = const {}});

  @override
  String toString() => message;

  String? getFirstError(String field) {
    final fieldErrors = errors[field];
    return fieldErrors != null && fieldErrors.isNotEmpty
        ? fieldErrors.first
        : null;
  }
}

class SellerStockServerException implements Exception {
  final String message;

  SellerStockServerException(this.message);

  @override
  String toString() => message;
}

class SellerStockNetworkException implements Exception {
  final String message;

  SellerStockNetworkException(this.message);

  @override
  String toString() => message;
}

// ============================================
// RÉSULTATS PAGINÉS
// ============================================

class SellerStocksResult {
  final List<SellerStockModel> stocks;
  final SellerStockStatsModel stats;
  final int total;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final bool hasMore;

  SellerStocksResult({
    required this.stocks,
    required this.stats,
    required this.total,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.hasMore,
  });
}

class SellerStockMovementsResult {
  final List<SellerStockMovementModel> movements;
  final int total;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final bool hasMore;

  SellerStockMovementsResult({
    required this.movements,
    required this.total,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.hasMore,
  });
}

class SellerStockDetailResult {
  final SellerStockModel stock;
  final List<SellerStockMovementModel> recentMovements;

  SellerStockDetailResult({
    required this.stock,
    required this.recentMovements,
  });
}

class SellerStockAdjustResult {
  final SellerStockModel stock;
  final int oldQuantity;
  final int newQuantity;
  final int difference;
  final String reason;

  SellerStockAdjustResult({
    required this.stock,
    required this.oldQuantity,
    required this.newQuantity,
    required this.difference,
    required this.reason,
  });
}

// ============================================
// API CLIENT
// ============================================

class SellerStockApi {
  final Dio _dio;

  SellerStockApi({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  // ============================================
  // INDEX — LISTE
  // ============================================

  /// GET /seller/stocks
  ///
  /// Liste paginée des stocks du vendeur.
  ///
  /// [status]      : all | in_stock | low_stock | out_of_stock
  /// [search]      : recherche par nom ou SKU produit
  /// [warehouseId] : filtrer par entrepôt
  /// [sortBy]      : updated_at | quantity | available_quantity | min_quantity
  Future<SellerStocksResult> getStocks({
    int page = 1,
    int perPage = 20,
    String? status,
    String? search,
    int? warehouseId,
    String sortBy = 'updated_at',
    String sortDir = 'desc',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
        'sort_by': sortBy,
        'sort_dir': sortDir,
      };

      if (status != null && status != 'all') {
        queryParams['status'] = status;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (warehouseId != null) {
        queryParams['warehouse_id'] = warehouseId;
      }

      final response = await _dio.get(
        '/seller/stocks',
        queryParameters: queryParams,
      );

      return _parseStocksListResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerStockApi.getStocks: $e');
      throw SellerStockServerException(
        'Impossible de récupérer les stocks.',
      );
    }
  }

  // ============================================
  // SHOW — DÉTAIL
  // ============================================

  /// GET /seller/stocks/{id}
  Future<SellerStockDetailResult> getStockById(int id) async {
    try {
      final response = await _dio.get('/seller/stocks/$id');
      return _parseStockDetailResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerStockApi.getStockById: $e');
      throw SellerStockServerException(
        'Impossible de récupérer le stock.',
      );
    }
  }

  // ============================================
  // ADJUST — AJUSTEMENT
  // ============================================

  /// POST /seller/stocks/{id}/adjust
  ///
  /// Ajuste la quantité absolue d'un stock.
  ///
  /// [quantity] : nouvelle quantité (>= 0)
  /// [reason]   : inventory | damage | return | correction | other
  /// [note]     : optionnel
  Future<SellerStockAdjustResult> adjustStock(
    int id, {
    required int quantity,
    required String reason,
    String? note,
  }) async {
    try {
      final body = <String, dynamic>{
        'quantity': quantity,
        'reason': reason,
      };

      if (note != null && note.isNotEmpty) {
        body['note'] = note;
      }

      final response = await _dio.post(
        '/seller/stocks/$id/adjust',
        data: body,
      );

      return _parseAdjustResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerStockApi.adjustStock: $e');
      throw SellerStockServerException(
        'Impossible d\'ajuster le stock.',
      );
    }
  }

  // ============================================
  // MOVEMENTS — HISTORIQUE
  // ============================================

  /// GET /seller/stocks/movements
  ///
  /// Historique paginé des mouvements.
  Future<SellerStockMovementsResult> getMovements({
    int page = 1,
    int perPage = 20,
    int? productId,
    String? type,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };

      if (productId != null) {
        queryParams['product_id'] = productId;
      }
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }
      if (dateFrom != null && dateFrom.isNotEmpty) {
        queryParams['date_from'] = dateFrom;
      }
      if (dateTo != null && dateTo.isNotEmpty) {
        queryParams['date_to'] = dateTo;
      }

      final response = await _dio.get(
        '/seller/stocks/movements',
        queryParameters: queryParams,
      );

      return _parseMovementsListResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerStockApi.getMovements: $e');
      throw SellerStockServerException(
        'Impossible de récupérer les mouvements.',
      );
    }
  }

  // ============================================
  // PARSING
  // ============================================

  SellerStocksResult _parseStocksListResponse(Response response) {
    final body = response.data;

    if (body is! Map) {
      throw SellerStockServerException('Format de réponse invalide.');
    }

    if (body['success'] != true) {
      throw SellerStockServerException(
        body['message']?.toString() ?? 'Erreur inconnue.',
      );
    }

    final data = body['data'];
    final pagination = body['pagination'];
    final stats = body['stats'];

    if (data is! List) {
      throw SellerStockServerException('Données manquantes.');
    }

    final stocks = <SellerStockModel>[];
    for (final item in data) {
      if (item is Map) {
        stocks.add(SellerStockModel.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    final pag = pagination is Map ? pagination : {};
    final statsData = stats is Map
        ? SellerStockStatsModel.fromJson(Map<String, dynamic>.from(stats))
        : const SellerStockStatsModel();

    return SellerStocksResult(
      stocks: stocks,
      stats: statsData,
      total: _toInt(pag['total']),
      currentPage: _toInt(pag['current_page'], defaultValue: 1),
      lastPage: _toInt(pag['last_page'], defaultValue: 1),
      perPage: _toInt(pag['per_page'], defaultValue: 20),
      hasMore: pag['has_more'] == true,
    );
  }

  SellerStockDetailResult _parseStockDetailResponse(Response response) {
    final body = response.data;

    if (body is! Map) {
      throw SellerStockServerException('Format de réponse invalide.');
    }

    if (body['success'] != true) {
      throw SellerStockServerException(
        body['message']?.toString() ?? 'Erreur inconnue.',
      );
    }

    final data = body['data'];
    final movementsData = body['recent_movements'];

    if (data is! Map) {
      throw SellerStockServerException('Données du stock manquantes.');
    }

    final stock = SellerStockModel.fromJson(Map<String, dynamic>.from(data));

    final movements = <SellerStockMovementModel>[];
    if (movementsData is List) {
      for (final item in movementsData) {
        if (item is Map) {
          movements.add(
            SellerStockMovementModel.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return SellerStockDetailResult(
      stock: stock,
      recentMovements: movements,
    );
  }

  SellerStockAdjustResult _parseAdjustResponse(Response response) {
    final body = response.data;

    if (body is! Map) {
      throw SellerStockServerException('Format de réponse invalide.');
    }

    if (body['success'] != true) {
      throw SellerStockServerException(
        body['message']?.toString() ?? 'Erreur inconnue.',
      );
    }

    final data = body['data'];
    final adjustment = body['adjustment'];

    if (data is! Map) {
      throw SellerStockServerException('Données du stock manquantes.');
    }

    final stock = SellerStockModel.fromJson(Map<String, dynamic>.from(data));
    final adj = adjustment is Map ? adjustment : {};

    return SellerStockAdjustResult(
      stock: stock,
      oldQuantity: _toInt(adj['old_quantity']),
      newQuantity: _toInt(adj['new_quantity']),
      difference: _toInt(adj['difference']),
      reason: adj['reason']?.toString() ?? '',
    );
  }

  SellerStockMovementsResult _parseMovementsListResponse(Response response) {
    final body = response.data;

    if (body is! Map) {
      throw SellerStockServerException('Format de réponse invalide.');
    }

    if (body['success'] != true) {
      throw SellerStockServerException(
        body['message']?.toString() ?? 'Erreur inconnue.',
      );
    }

    final data = body['data'];
    final pagination = body['pagination'];

    if (data is! List) {
      throw SellerStockServerException('Données manquantes.');
    }

    final movements = <SellerStockMovementModel>[];
    for (final item in data) {
      if (item is Map) {
        movements.add(
          SellerStockMovementModel.fromJson(Map<String, dynamic>.from(item)),
        );
      }
    }

    final pag = pagination is Map ? pagination : {};

    return SellerStockMovementsResult(
      movements: movements,
      total: _toInt(pag['total']),
      currentPage: _toInt(pag['current_page'], defaultValue: 1),
      lastPage: _toInt(pag['last_page'], defaultValue: 1),
      perPage: _toInt(pag['per_page'], defaultValue: 20),
      hasMore: pag['has_more'] == true,
    );
  }

  // ============================================
  // GESTION DES ERREURS
  // ============================================

  Exception _handleError(DioException e) {
    debugPrint('❌ SellerStockApi DioException: '
        '${e.type} - ${e.response?.statusCode} - ${e.message}');

    // Erreur réseau
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError) {
      return SellerStockNetworkException(
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
        return SellerStockUnauthorizedException(
          message.isNotEmpty
              ? message
              : 'Session expirée. Veuillez vous reconnecter.',
        );

      case 403:
        String? code;
        if (body is Map && body['code'] != null) {
          code = body['code'].toString();
        }
        return SellerStockForbiddenException(message, code: code);

      case 404:
        return SellerStockNotFoundException(
          message.isNotEmpty ? message : 'Stock introuvable.',
        );

      case 409:
        return SellerStockConflictException(message);

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
        return SellerStockValidationException(message, errors: errors);

      case 500:
      case 502:
      case 503:
        return SellerStockServerException(
          message.isNotEmpty
              ? message
              : 'Le serveur rencontre un problème. Réessayez plus tard.',
        );

      default:
        return SellerStockServerException(message);
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