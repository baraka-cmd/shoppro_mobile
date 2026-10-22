// ============================================
// API SOURCE : SellerStatsApi
// ============================================
// Gère les appels HTTP pour les statistiques vendeur.
//
// Responsabilités :
//   - Récupérer les stats de ventes (sales)
//   - Récupérer les top produits (products)
//   - Récupérer les top clients (customers)
//   - Télécharger un export CSV (avec ouverture native)
//
// Sécurité :
//   - Token injecté automatiquement par ApiClient (Dio interceptor)
//   - Export CSV streamé côté serveur (pas de surcharge mémoire)
//   - Gestion des codes HTTP : 200, 401, 403, 404, 422, 500
// ============================================

// Flutter
import 'package:flutter/foundation.dart';

// Dio
import 'package:dio/dio.dart';

// Path provider + share
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';

// Dart
import 'dart:io';

// Core
import '../../../../core/network/api_client.dart';

// Model
import '../models/seller_stats_model.dart';


// ============================================
// EXCEPTIONS PERSONNALISÉES
// ============================================

class SellerStatsForbiddenException implements Exception {
  final String message;
  final String? code;

  SellerStatsForbiddenException(this.message, {this.code});

  @override
  String toString() => message;
}

class SellerStatsUnauthorizedException implements Exception {
  final String message;

  SellerStatsUnauthorizedException(this.message);

  @override
  String toString() => message;
}

class SellerStatsNotFoundException implements Exception {
  final String message;

  SellerStatsNotFoundException(this.message);

  @override
  String toString() => message;
}

class SellerStatsServerException implements Exception {
  final String message;

  SellerStatsServerException(this.message);

  @override
  String toString() => message;
}

class SellerStatsNetworkException implements Exception {
  final String message;

  SellerStatsNetworkException(this.message);

  @override
  String toString() => message;
}

class SellerStatsExportException implements Exception {
  final String message;

  SellerStatsExportException(this.message);

  @override
  String toString() => message;
}

// ============================================
// RÉSULTAT D'EXPORT
// ============================================

class SellerStatsExportResult {
  final String filePath;
  final String fileName;
  final int fileSizeBytes;

  SellerStatsExportResult({
    required this.filePath,
    required this.fileName,
    required this.fileSizeBytes,
  });

  /// Taille formatée (ex: "45.2 Ko").
  String get formattedSize {
    if (fileSizeBytes < 1024) {
      return '$fileSizeBytes octets';
    }
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} Ko';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(2)} Mo';
  }
}

// ============================================
// API CLIENT
// ============================================

class SellerStatsApi {
  final Dio _dio;

  SellerStatsApi({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  // ============================================
  // SALES — STATISTIQUES DE VENTES
  // ============================================

  /// GET /seller/stats/sales?period=30
  ///
  /// Retourne les KPIs de ventes + timeline.
  ///
  /// [period] : 7 | 30 | 90 | 0 (0 = tout)
  Future<SellerSalesStatsModel> getSales({int period = 30}) async {
    try {
      final response = await _dio.get(
        '/seller/stats/sales',
        queryParameters: {'period': period},
      );

      return _parseSalesResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerStatsApi.getSales: $e');
      throw SellerStatsServerException(
        'Impossible de récupérer les statistiques de ventes.',
      );
    }
  }

  // ============================================
  // PRODUCTS — TOP PRODUITS
  // ============================================

  /// GET /seller/stats/products?period=30&limit=5
  Future<SellerProductStatsModel> getProducts({
    int period = 30,
    int limit = 5,
  }) async {
    try {
      final response = await _dio.get(
        '/seller/stats/products',
        queryParameters: {
          'period': period,
          'limit': limit,
        },
      );

      return _parseProductsResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerStatsApi.getProducts: $e');
      throw SellerStatsServerException(
        'Impossible de récupérer les statistiques produits.',
      );
    }
  }

  // ============================================
  // CUSTOMERS — TOP CLIENTS
  // ============================================

  /// GET /seller/stats/customers?period=30&limit=5
  Future<SellerCustomerStatsModel> getCustomers({
    int period = 30,
    int limit = 5,
  }) async {
    try {
      final response = await _dio.get(
        '/seller/stats/customers',
        queryParameters: {
          'period': period,
          'limit': limit,
        },
      );

      return _parseCustomersResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerStatsApi.getCustomers: $e');
      throw SellerStatsServerException(
        'Impossible de récupérer les statistiques clients.',
      );
    }
  }

  // ============================================
  // EXPORT — CSV
  // ============================================

  /// GET /seller/stats/export?type=orders&period=30
  ///
  /// Télécharge le fichier CSV dans le dossier temporaire de l'app,
  /// puis propose 2 actions :
  ///   - Ouvrir le fichier avec l'app native (Excel, Sheets...)
  ///   - Partager le fichier (email, WhatsApp...)
  ///
  /// [type]   : 'orders' ou 'products'
  /// [period] : 7 | 30 | 90 | 0
  /// [openAfterDownload] : si true, ouvre le fichier après téléchargement
  Future<SellerStatsExportResult> exportCsv({
    required String type,
    int period = 30,
    bool openAfterDownload = false,
  }) async {
    try {
      // Dossier temporaire de l'app
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'shoppro-$type-${DateTime.now().millisecondsSinceEpoch}.csv';
      final filePath = '${tempDir.path}/$fileName';

      // Télécharger le fichier
      await _dio.download(
        '/seller/stats/export',
        filePath,
        queryParameters: {
          'type': type,
          'period': period,
        },
        options: Options(
          responseType: ResponseType.stream,
        ),
      );

      final file = File(filePath);

      if (!await file.exists()) {
        throw SellerStatsExportException('Le fichier n\'a pas été téléchargé.');
      }

      final fileSize = await file.length();

      final result = SellerStatsExportResult(
        filePath: filePath,
        fileName: fileName,
        fileSizeBytes: fileSize,
      );

      // Ouvrir le fichier si demandé
      if (openAfterDownload) {
        await openCsv(filePath);
      }

      return result;
    } on DioException catch (e) {
      throw _handleError(e);
    } on SellerStatsExportException catch (e) {
      rethrow;
    } catch (e) {
      debugPrint('❌ SellerStatsApi.exportCsv: $e');
      throw SellerStatsExportException(
        'Impossible d\'exporter le fichier CSV.',
      );
    }
  }

  /// Ouvre un fichier CSV avec l'app native du téléphone.
  Future<void> openCsv(String filePath) async {
    try {
      final result = await OpenFilex.open(filePath);

      if (result.type != ResultType.done) {
        debugPrint('⚠️ Impossible d\'ouvrir le fichier: ${result.message}');
      }
    } catch (e) {
      debugPrint('❌ Erreur openCsv: $e');
    }
  }

  /// Partage un fichier CSV via la share sheet native.
  Future<void> shareCsv(String filePath, {String? subject}) async {
    try {
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: subject ?? 'Export ShopPro',
      );
    } catch (e) {
      debugPrint('❌ Erreur shareCsv: $e');
    }
  }

  // ============================================
  // PARSING
  // ============================================

  SellerSalesStatsModel _parseSalesResponse(Response response) {
    final body = response.data;

    if (body is! Map) {
      throw SellerStatsServerException('Format de réponse invalide.');
    }

    if (body['success'] != true) {
      throw SellerStatsServerException(
        body['message']?.toString() ?? 'Erreur inconnue.',
      );
    }

    final data = body['data'];

    if (data is! Map) {
      throw SellerStatsServerException('Données de ventes manquantes.');
    }

    return SellerSalesStatsModel.fromJson(Map<String, dynamic>.from(data));
  }

  SellerProductStatsModel _parseProductsResponse(Response response) {
    final body = response.data;

    if (body is! Map) {
      throw SellerStatsServerException('Format de réponse invalide.');
    }

    if (body['success'] != true) {
      throw SellerStatsServerException(
        body['message']?.toString() ?? 'Erreur inconnue.',
      );
    }

    final data = body['data'];

    if (data is! Map) {
      throw SellerStatsServerException('Données produits manquantes.');
    }

    return SellerProductStatsModel.fromJson(Map<String, dynamic>.from(data));
  }

  SellerCustomerStatsModel _parseCustomersResponse(Response response) {
    final body = response.data;

    if (body is! Map) {
      throw SellerStatsServerException('Format de réponse invalide.');
    }

    if (body['success'] != true) {
      throw SellerStatsServerException(
        body['message']?.toString() ?? 'Erreur inconnue.',
      );
    }

    final data = body['data'];

    if (data is! Map) {
      throw SellerStatsServerException('Données clients manquantes.');
    }

    return SellerCustomerStatsModel.fromJson(Map<String, dynamic>.from(data));
  }

  // ============================================
  // GESTION DES ERREURS
  // ============================================

  Exception _handleError(DioException e) {
    debugPrint('❌ SellerStatsApi DioException: '
        '${e.type} - ${e.response?.statusCode} - ${e.message}');

    // Erreur réseau
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError) {
      return SellerStatsNetworkException(
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
        return SellerStatsUnauthorizedException(
          message.isNotEmpty
              ? message
              : 'Session expirée. Veuillez vous reconnecter.',
        );

      case 403:
        String? code;
        if (body is Map && body['code'] != null) {
          code = body['code'].toString();
        }
        return SellerStatsForbiddenException(message, code: code);

      case 404:
        return SellerStatsNotFoundException(
          message.isNotEmpty ? message : 'Ressource introuvable.',
        );

      case 500:
      case 502:
      case 503:
        return SellerStatsServerException(
          message.isNotEmpty
              ? message
              : 'Le serveur rencontre un problème. Réessayez plus tard.',
        );

      default:
        return SellerStatsServerException(message);
    }
  }
}