// ============================================
// REPOSITORY IMPL : SellerDashboardRepositoryImpl
// ============================================
// Implémentation du repository du dashboard vendeur.
//
// Stratégie API-first + cache local :
//   1. Tente d'appeler l'API
//   2. Si succès → sauvegarde en cache + retourne les données
//   3. Si échec réseau → retourne le cache (fallback offline)
//   4. Si pas de cache → propage l'erreur
//
// Le cache est géré via SharedPreferences (léger, rapide).
// ============================================

// Flutter
import 'package:flutter/foundation.dart';

// Dart
import 'dart:convert';

// SharedPreferences
import 'package:shared_preferences/shared_preferences.dart';

// Domain
import '../../domain/entities/seller_dashboard.dart';
import '../../domain/repositories/seller_dashboard_repository.dart';

// Data
import '../models/seller_dashboard_model.dart';
import '../sources/seller_dashboard_api.dart';

class SellerDashboardRepositoryImpl implements SellerDashboardRepository {
  // ============================================
  // DÉPENDANCES
  // ============================================

  final SellerDashboardApi _api;

  SellerDashboardRepositoryImpl({SellerDashboardApi? api})
      : _api = api ?? SellerDashboardApi();

  // ============================================
  // CLÉS DE CACHE
  // ============================================

  static const String _cacheKeyDashboard = 'seller_dashboard_cache_v1';
  static const String _cacheKeyTimestamp = 'seller_dashboard_timestamp_v1';

  /// Durée de validité du cache : 5 minutes (aligné avec le backend).
  static const Duration _cacheValidity = Duration(minutes: 5);

  // ============================================
// LECTURE
// ============================================

@override
Future<SellerDashboard> getDashboard() async {
  try {
    // 1. Appel API
    final model = await _api.getDashboard();

    // 👇 DIAGNOSTIC : On affiche ce que l'API nous a renvoyé
    debugPrint('==========================================');
    debugPrint('🔍 DIAGNOSTIC DASHBOARD (depuis l\'API)');
    debugPrint('Commandes récentes : ${model.recentOrders.length}');
    debugPrint('Top produits : ${model.topProducts.length}');
    debugPrint('Alertes : ${model.alerts.length}');
    debugPrint('Revenus : ${model.revenue.totalFormatted}');
    debugPrint('==========================================');

    // 2. Sauvegarde en cache
    await _saveDashboardToCache(model);

    return model;
    
  } on SellerDashboardNetworkException catch (e) {
    debugPrint('⚠️ API offline, tentative de fallback cache: $e');

    // 3. Fallback : essayer le cache
    final cached = await _loadDashboardFromCache();

    if (cached != null) {
      debugPrint('✅ Fallback cache utilisé');
      
      // 👇 DIAGNOSTIC : On affiche ce que le CACHE nous a renvoyé
      debugPrint('==========================================');
      debugPrint('🔍 DIAGNOSTIC DASHBOARD (depuis le CACHE)');
      debugPrint('Commandes récentes : ${cached.recentOrders.length}');
      debugPrint('Top produits : ${cached.topProducts.length}');
      debugPrint('Alertes : ${cached.alerts.length}');
      debugPrint('==========================================');

      return cached;
    }

    // 4. Pas de cache → propager l'erreur
    rethrow;
  } catch (e) {
    debugPrint('❌ Erreur getDashboard: $e');
    rethrow;
  }
}
  @override
  Future<Map<String, dynamic>> getSalesChart({int period = 30}) async {
    try {
      return await _api.getSalesChart(period: period);
    } catch (e) {
      debugPrint('❌ Erreur getSalesChart: $e');
      rethrow;
    }
  }

  @override
  Future<List<DashboardOrderSummary>> getRecentOrders({int limit = 10}) async {
    try {
      final rawList = await _api.getRecentOrders(limit: limit);

      return rawList
          .map((json) => DashboardOrderSummaryModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('❌ Erreur getRecentOrders: $e');
      rethrow;
    }
  }

  @override
  Future<List<DashboardTopProduct>> getTopProducts({int limit = 5}) async {
    try {
      final rawList = await _api.getTopProducts(limit: limit);

      return rawList
          .map((json) => DashboardTopProductModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('❌ Erreur getTopProducts: $e');
      rethrow;
    }
  }

  @override
  Future<List<DashboardAlert>> getAlerts() async {
    try {
      final rawList = await _api.getAlerts();

      return rawList
          .map((json) => DashboardAlertModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('❌ Erreur getAlerts: $e');
      rethrow;
    }
  }

  // ============================================
  // REFRESH
  // ============================================

  @override
  Future<SellerDashboard> refreshDashboard() async {
    // Effacer le cache d'abord
    await clearCache();

    // Puis recharger
    return getDashboard();
  }

  // ============================================
  // GESTION DU CACHE
  // ============================================

  /// Sauvegarde le dashboard en cache.
  Future<void> _saveDashboardToCache(SellerDashboardModel model) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = model.toJson();
      final jsonString = jsonEncode(json);

      await prefs.setString(_cacheKeyDashboard, jsonString);
      await prefs.setInt(
        _cacheKeyTimestamp,
        DateTime.now().millisecondsSinceEpoch,
      );

      debugPrint('💾 Dashboard sauvegardé en cache');
    } catch (e) {
      debugPrint('⚠️ Impossible de sauvegarder le cache: $e');
    }
  }

  /// Charge le dashboard depuis le cache.
  ///
  /// Retourne `null` si :
  ///   - Pas de cache
  ///   - Cache trop ancien (> 5 min)
  ///   - JSON corrompu
  Future<SellerDashboardModel?> _loadDashboardFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final jsonString = prefs.getString(_cacheKeyDashboard);
      final timestamp = prefs.getInt(_cacheKeyTimestamp);

      if (jsonString == null || timestamp == null) {
        debugPrint('ℹ️ Pas de cache disponible');
        return null;
      }

      // Vérifier la fraîcheur
      final cacheDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final age = DateTime.now().difference(cacheDate);

      if (age > _cacheValidity) {
        debugPrint('⚠️ Cache expiré (âge: ${age.inMinutes} min)');
        return null;
      }

      // Parser le JSON
      final json = jsonDecode(jsonString);

      if (json is! Map<String, dynamic>) {
        debugPrint('❌ Cache corrompu (JSON invalide)');
        return null;
      }

      final model = SellerDashboardModel.fromJson(json);

      debugPrint('✅ Cache chargé (âge: ${age.inSeconds} s)');
      return model;
    } catch (e) {
      debugPrint('❌ Erreur chargement cache: $e');
      return null;
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKeyDashboard);
      await prefs.remove(_cacheKeyTimestamp);
      debugPrint('🗑️ Cache dashboard effacé');
    } catch (e) {
      debugPrint('⚠️ Erreur clearCache: $e');
    }
  }

  // ============================================
  // HELPERS
  // ============================================

  /// Vérifie si le cache existe et est encore valide.
  Future<bool> hasValidCache() async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = prefs.getString(_cacheKeyDashboard);
    final timestamp = prefs.getInt(_cacheKeyTimestamp);

    if (jsonString == null || timestamp == null) return false;

    final cacheDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final age = DateTime.now().difference(cacheDate);

    return age <= _cacheValidity;
  }

  /// Récupère l'âge du cache en secondes (null si pas de cache).
  Future<int?> getCacheAgeSeconds() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_cacheKeyTimestamp);

    if (timestamp == null) return null;

    final cacheDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateTime.now().difference(cacheDate).inSeconds;
  }
}