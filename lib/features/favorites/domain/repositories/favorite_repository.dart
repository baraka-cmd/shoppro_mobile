// Interface du repository des favoris
// Définit le contrat que le repository doit respecter

import '../entities/favorite.dart';

abstract class FavoriteRepository {
  /// Récupérer tous les favoris
  Future<List<Favorite>> getFavorites();

  /// Ajouter un favori
  Future<List<Favorite>> addFavorite(Favorite favorite);

  /// Supprimer un favori
  Future<List<Favorite>> removeFavorite(int favoriteId);

  /// Supprimer par productId
  Future<List<Favorite>> removeByProductId(int productId);

  /// Toggle favori (ajouter si absent, supprimer si présent)
  Future<bool> toggleFavorite(Favorite favorite);

  /// Vérifier si un produit est en favori
  Future<bool> isFavorite(int productId);

  /// Récupérer le nombre de favoris
  Future<int> getFavoritesCount();

  /// Activer/désactiver l'alerte de prix
  Future<List<Favorite>> togglePriceAlert(int favoriteId, double? threshold);

  /// Mettre à jour la collection
  Future<List<Favorite>> updateCollection(int favoriteId, String collectionName);

  /// Vider tous les favoris
  Future<void> clearFavorites();

  /// Sauvegarder les favoris localement
  Future<void> saveFavorites(List<Favorite> favorites);

  /// Synchroniser avec le backend
  Future<List<Favorite>> syncWithBackend();

  /// Récupérer les favoris par collection
  Future<List<Favorite>> getFavoritesByCollection(String collectionName);

  /// Récupérer les collections disponibles
  Future<List<String>> getCollections();
}