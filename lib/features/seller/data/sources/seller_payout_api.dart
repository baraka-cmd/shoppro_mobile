// ============================================
// API SOURCE : SellerPayoutApi
// ============================================
// Gère les appels HTTP pour les payouts vendeur.
//
// Responsabilités :
//   - Récupérer le solde (balance)
//   - Lister les payouts paginés
//   - Détail d'un payout
//   - Demander un versement (request)
//   - Annuler un payout pending (cancel)
//
// Sécurité :
//   - Token injecté automatiquement par ApiClient (Dio interceptor)
//   - Gestion des codes HTTP : 200, 201, 401, 403, 404, 409, 422, 500
//   - Scope strict côté backend : seller_id = auth()->id()
// ============================================

// Flutter
import 'package:flutter/foundation.dart';

// Dio
import 'package:dio/dio.dart';

// Core
import '../../../../core/network/api_client.dart';

// Model
import '../models/seller_payout_model.dart';

// ============================================
// EXCEPTIONS PERSONNALISÉES
// ============================================

class SellerPayoutForbiddenException implements Exception {
  final String message;
  final String? code;

  SellerPayoutForbiddenException(this.message, {this.code});

  @override
  String toString() => message;
}

class SellerPayoutUnauthorizedException implements Exception {
  final String message;

  SellerPayoutUnauthorizedException(this.message);

  @override
  String toString() => message;
}

class SellerPayoutNotFoundException implements Exception {
  final String message;

  SellerPayoutNotFoundException(this.message);

  @override
  String toString() => message;
}

class SellerPayoutConflictException implements Exception {
  final String message;

  SellerPayoutConflictException(this.message);

  @override
  String toString() => message;
}

class SellerPayoutValidationException implements Exception {
  final String message;
  final Map<String, List<String>> errors;

  SellerPayoutValidationException(this.message, {this.errors = const {}});

  @override
  String toString() => message;

  String? getFirstError(String field) {
    final fieldErrors = errors[field];
    return fieldErrors != null && fieldErrors.isNotEmpty
        ? fieldErrors.first
        : null;
  }
}

class SellerPayoutServerException implements Exception {
  final String message;

  SellerPayoutServerException(this.message);

  @override
  String toString() => message;
}

class SellerPayoutNetworkException implements Exception {
  final String message;

  SellerPayoutNetworkException(this.message);

  @override
  String toString() => message;
}

// ============================================
// RÉSULTATS PAGINÉS
// ============================================

class SellerPayoutsResult {
  final List<SellerPayoutModel> payouts;
  final SellerPayoutStatsModel stats;
  final int total;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final bool hasMore;

  SellerPayoutsResult({
    required this.payouts,
    required this.stats,
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

class SellerPayoutApi {
  final Dio _dio;

  SellerPayoutApi({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  // ============================================
  // BALANCE — SOLDE
  // ============================================

  /// GET /seller/payouts/balance
  ///
  /// Retourne le solde du vendeur + stats + payout en cours.
  Future<SellerBalanceModel> getBalance() async {
    try {
      final response = await _dio.get('/seller/payouts/balance');
      return _parseBalanceResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerPayoutApi.getBalance: $e');
      throw SellerPayoutServerException(
        'Impossible de récupérer le solde.',
      );
    }
  }

  // ============================================
  // INDEX — LISTE
  // ============================================

  /// GET /seller/payouts
  ///
  /// Liste paginée des payouts du vendeur.
  ///
  /// [status] : all | pending | processing | completed | failed | cancelled
  Future<SellerPayoutsResult> getPayouts({
    int page = 1,
    int perPage = 20,
    String status = 'all',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };

      if (status != 'all' && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await _dio.get(
        '/seller/payouts',
        queryParameters: queryParams,
      );

      return _parsePayoutsResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerPayoutApi.getPayouts: $e');
      throw SellerPayoutServerException(
        'Impossible de récupérer les versements.',
      );
    }
  }

  // ============================================
  // SHOW — DÉTAIL
  // ============================================

  /// GET /seller/payouts/{id}
  Future<SellerPayoutModel> getPayoutById(int id) async {
    try {
      final response = await _dio.get('/seller/payouts/$id');
      return _parseSinglePayoutResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerPayoutApi.getPayoutById: $e');
      throw SellerPayoutServerException(
        'Impossible de récupérer le versement.',
      );
    }
  }

  // ============================================
  // REQUEST — DEMANDER UN VERSEMENT
  // ============================================

  /// POST /seller/payouts/request
  ///
  /// Crée une demande de versement.
  ///
  /// [amount]  : montant demandé (>= min_payout_amount)
  /// [method]  : mobile_money | bank_transfer | paypal
  /// [account] : compte destinataire (optionnel si déjà configuré)
  /// [note]    : note optionnelle
  Future<SellerPayoutModel> requestPayout({
    required double amount,
    required String method,
    String? account,
    String? note,
  }) async {
    try {
      final body = <String, dynamic>{
        'amount': amount,
        'method': method,
      };

      if (account != null && account.isNotEmpty) {
        body['account'] = account;
      }

      if (note != null && note.isNotEmpty) {
        body['note'] = note;
      }

      final response = await _dio.post(
        '/seller/payouts/request',
        data: body,
      );

      return _parseSinglePayoutResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerPayoutApi.requestPayout: $e');
      throw SellerPayoutServerException(
        'Impossible de créer la demande de versement.',
      );
    }
  }

  // ============================================
  // CANCEL — ANNULER
  // ============================================

  /// POST /seller/payouts/{id}/cancel
  ///
  /// Annule un payout en statut 'pending'.
  Future<SellerPayoutModel> cancelPayout(int id) async {
    try {
      final response = await _dio.post('/seller/payouts/$id/cancel');
      return _parseSinglePayoutResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerPayoutApi.cancelPayout: $e');
      throw SellerPayoutServerException(
        'Impossible d\'annuler le versement.',
      );
    }
  }

  // ============================================
  // PARSING
  // ============================================

  SellerBalanceModel _parseBalanceResponse(Response response) {
    final body = response.data;

    if (body is! Map) {
      throw SellerPayoutServerException('Format de réponse invalide.');
    }

    if (body['success'] != true) {
      throw SellerPayoutServerException(
        body['message']?.toString() ?? 'Erreur inconnue.',
      );
    }

    final data = body['data'];

    if (data is! Map) {
      throw SellerPayoutServerException('Données de solde manquantes.');
    }

    return SellerBalanceModel.fromJson(Map<String, dynamic>.from(data));
  }

  SellerPayoutsResult _parsePayoutsResponse(Response response) {
    final body = response.data;

    if (body is! Map) {
      throw SellerPayoutServerException('Format de réponse invalide.');
    }

    if (body['success'] != true) {
      throw SellerPayoutServerException(
        body['message']?.toString() ?? 'Erreur inconnue.',
      );
    }

    final data = body['data'];
    final pagination = body['pagination'];
    final stats = body['stats'];

    if (data is! List) {
      throw SellerPayoutServerException('Données manquantes.');
    }

    final payouts = <SellerPayoutModel>[];
    for (final item in data) {
      if (item is Map) {
        payouts.add(
          SellerPayoutModel.fromJson(Map<String, dynamic>.from(item)),
        );
      }
    }

    final pag = pagination is Map ? pagination : {};
    final statsData = stats is Map
        ? SellerPayoutStatsModel.fromJson(Map<String, dynamic>.from(stats))
        : const SellerPayoutStatsModel();

    return SellerPayoutsResult(
      payouts: payouts,
      stats: statsData,
      total: _toInt(pag['total']),
      currentPage: _toInt(pag['current_page'], defaultValue: 1),
      lastPage: _toInt(pag['last_page'], defaultValue: 1),
      perPage: _toInt(pag['per_page'], defaultValue: 20),
      hasMore: pag['has_more'] == true,
    );
  }

  SellerPayoutModel _parseSinglePayoutResponse(Response response) {
    final body = response.data;

    if (body is! Map) {
      throw SellerPayoutServerException('Format de réponse invalide.');
    }

    if (body['success'] != true) {
      throw SellerPayoutServerException(
        body['message']?.toString() ?? 'Erreur inconnue.',
      );
    }

    final data = body['data'];

    if (data is! Map) {
      throw SellerPayoutServerException('Données du versement manquantes.');
    }

    return SellerPayoutModel.fromJson(Map<String, dynamic>.from(data));
  }

  // ============================================
  // GESTION DES ERREURS
  // ============================================

  Exception _handleError(DioException e) {
    debugPrint('❌ SellerPayoutApi DioException: '
        '${e.type} - ${e.response?.statusCode} - ${e.message}');

    // Erreur réseau
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError) {
      return SellerPayoutNetworkException(
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
        return SellerPayoutUnauthorizedException(
          message.isNotEmpty
              ? message
              : 'Session expirée. Veuillez vous reconnecter.',
        );

      case 403:
        String? code;
        if (body is Map && body['code'] != null) {
          code = body['code'].toString();
        }
        return SellerPayoutForbiddenException(message, code: code);

      case 404:
        return SellerPayoutNotFoundException(
          message.isNotEmpty ? message : 'Versement introuvable.',
        );

      case 409:
        return SellerPayoutConflictException(message);

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
        return SellerPayoutValidationException(message, errors: errors);

      case 500:
      case 502:
      case 503:
        return SellerPayoutServerException(
          message.isNotEmpty
              ? message
              : 'Le serveur rencontre un problème. Réessayez plus tard.',
        );

      default:
        return SellerPayoutServerException(message);
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