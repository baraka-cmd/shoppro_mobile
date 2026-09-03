// ============================================
// SOURCE DE DONNÉES LOCALE DES FAVORIS - PREMIUM
// ============================================
// Gère la sauvegarde et la récupération dans
// SharedPreferences avec snapshot et gestion d'erreurs.
// ============================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/favorite.dart';
import '../models/favorite_model.dart';

class FavoriteLocalDataSource {
  static final FavoriteLocalDataSource _instance = FavoriteLocalDataSource._internal();
  factory FavoriteLocalDataSource() => _instance;
  FavoriteLocalDataSource._internal();

  static const String _favoritesKey = 'favorites_data';
  static const String _favoritesSnapshotKey = 'favorites_snapshot_data';

  // ============================================
  // FAVORIS PRINCIPAUX
  // ============================================

  /// Sauvegarder les favoris
  Future<void> saveFavorites(List<Favorite> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = jsonEncode(
        favorites.map((f) => f.toJson()).toList(),
      );
      await prefs.setString(_favoritesKey, favoritesJson);
    } catch (e) {
      debugPrint('❌ Erreur saveFavorites: $e');
    }
  }

  /// Récupérer les favoris
  Future<List<Favorite>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString(_favoritesKey);

      if (favoritesJson == null || favoritesJson.isEmpty) {
        return [];
      }

      final List<dynamic> data = jsonDecode(favoritesJson);
      return data
          .whereType<Map<String, dynamic>>()
          .map((json) => FavoriteModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('❌ Erreur getFavorites: $e');
      return [];
    }
  }

  /// Effacer tous les favoris
  Future<void> clearFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_favoritesKey);
    } catch (e) {
      debugPrint('❌ Erreur clearFavorites: $e');
    }
  }

  /// Récupérer le nombre de favoris
  Future<int> getFavoritesCount() async {
    final favorites = await getFavorites();
    return favorites.length;
  }

  /// Vérifier si un produit est en favori
  Future<bool> isFavorite(int productId) async {
    final favorites = await getFavorites();
    return favorites.any((f) => f.productId == productId);
  }

  // ============================================
  // SNAPSHOT (ANNULATION)
  // ============================================

  /// Sauvegarder le snapshot des favoris
  Future<void> saveFavoritesSnapshot() async {
    try {
      final favorites = await getFavorites();
      final prefs = await SharedPreferences.getInstance();
      final snapshotJson = jsonEncode(
        favorites.map((f) => f.toJson()).toList(),
      );
      await prefs.setString(_favoritesSnapshotKey, snapshotJson);
    } catch (e) {
      debugPrint('❌ Erreur saveFavoritesSnapshot: $e');
    }
  }

  /// Restaurer le snapshot des favoris
  Future<List<Favorite>?> restoreFavoritesSnapshot() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final snapshotJson = prefs.getString(_favoritesSnapshotKey);

      if (snapshotJson == null || snapshotJson.isEmpty) {
        return null;
      }

      final List<dynamic> data = jsonDecode(snapshotJson);
      final favorites = data
          .whereType<Map<String, dynamic>>()
          .map((json) => FavoriteModel.fromJson(json))
          .toList();

      await saveFavorites(favorites);
      await clearFavoritesSnapshot();
      return favorites;
    } catch (e) {
      debugPrint('❌ Erreur restoreFavoritesSnapshot: $e');
      return null;
    }
  }

  /// Effacer le snapshot
  Future<void> clearFavoritesSnapshot() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_favoritesSnapshotKey);
    } catch (e) {
      debugPrint('❌ Erreur clearFavoritesSnapshot: $e');
    }
  }

  // ============================================
  // UTILITAIRES
  // ============================================

  /// Effacer toutes les données des favoris
  Future<void> clearAll() async {
    await clearFavorites();
    await clearFavoritesSnapshot();
  }

  /// Vérifier si un snapshot existe
  Future<bool> hasSnapshot() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_favoritesSnapshotKey);
    } catch (e) {
      return false;
    }
  }
}