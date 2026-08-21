// Source de données locale des favoris
// Gère la sauvegarde et la récupération dans SharedPreferences

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/favorite.dart';
import '../models/favorite_model.dart';

class FavoriteLocalDataSource {
  static final FavoriteLocalDataSource _instance = FavoriteLocalDataSource._internal();
  factory FavoriteLocalDataSource() => _instance;
  FavoriteLocalDataSource._internal();

  static const String _favoritesKey = 'favorites_data';

  /// Sauvegarder les favoris
  Future<void> saveFavorites(List<Favorite> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = jsonEncode(
      favorites.map((f) => f.toJson()).toList(),
    );
    await prefs.setString(_favoritesKey, favoritesJson);
  }

  /// Récupérer les favoris
  Future<List<Favorite>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString(_favoritesKey);

    if (favoritesJson == null || favoritesJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> data = jsonDecode(favoritesJson);
      return data
          .whereType<Map<String, dynamic>>()
          .map((json) => FavoriteModel.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Effacer tous les favoris
  Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_favoritesKey);
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
}