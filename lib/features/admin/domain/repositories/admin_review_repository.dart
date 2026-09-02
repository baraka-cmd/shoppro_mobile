// ============================================
// REPOSITORY INTERFACE : AdminReviewRepository
// ============================================
// Interface définissant le contrat pour la gestion des avis clients
// depuis le backoffice administrateur.
//
// Cette interface est dans la couche DOMAIN (métier) et ne dépend
// d'aucune implémentation concrète. Elle sera implémentée dans
// la couche DATA par AdminReviewRepositoryImpl.
//
// Opérations couvertes :
// - Liste paginée des avis
// - Modération (approuver, rejeter, marquer comme spam)
// - Réponse aux avis
// - Statistiques des avis
// - Actions en masse
// ============================================

// ============================================
// IMPORTS
// ============================================

// Entities (même feature admin)
import '../entities/admin_review.dart';

// ============================================
// INTERFACE PRINCIPALE
// ============================================

/// Contrat pour le repository de gestion des avis.
///
/// Cette interface définit toutes les opérations de modération
/// et de gestion des avis clients pour l'administration.
abstract class AdminReviewRepository {
  // ============================================
  // LISTE ET RECHERCHE
  // ============================================

  /// Récupère la liste paginée des avis.
  ///
  /// Paramètres :
  /// - [page] : Numéro de page (commence à 1)
  /// - [perPage] : Nombre d'éléments par page (défaut : 20)
  /// - [status] : Filtrer par statut de modération
  /// - [rating] : Filtrer par note (1-5)
  /// - [productId] : Filtrer par produit
  /// - [userId] : Filtrer par utilisateur
  /// - [sortBy] : Champ de tri (created_at, rating, helpful_count)
  /// - [sortDirection] : Direction du tri (asc, desc)
  ///
  /// Retourne une liste de [AdminReview].
  Future<List<AdminReview>> getReviews({
    int page = 1,
    int perPage = 20,
    AdminReviewStatus? status,
    int? rating,
    int? productId,
    int? userId,
    String? sortBy,
    String? sortDirection,
  });

  /// Recherche des avis par contenu ou titre.
  ///
  /// Paramètres :
  /// - [query] : Texte de recherche
  /// - [limit] : Nombre maximum de résultats (défaut : 20)
  Future<List<AdminReview>> searchReviews(String query, {int limit = 20});

  /// Récupère les avis en attente de modération.
  ///
  /// Paramètres :
  /// - [page] : Numéro de page
  /// - [perPage] : Nombre d'éléments par page
  Future<List<AdminReview>> getPendingReviews({
    int page = 1,
    int perPage = 20,
  });

  /// Récupère les avis approuvés.
  Future<List<AdminReview>> getApprovedReviews({
    int page = 1,
    int perPage = 20,
  });

  /// Récupère les avis rejetés.
  Future<List<AdminReview>> getRejectedReviews({
    int page = 1,
    int perPage = 20,
  });

  /// Récupère les avis marqués comme spam.
  Future<List<AdminReview>> getSpamReviews({
    int page = 1,
    int perPage = 20,
  });

  /// Récupère les avis d'un produit spécifique.
  ///
  /// Paramètres :
  /// - [productId] : Identifiant du produit
  /// - [page] : Numéro de page
  /// - [perPage] : Nombre d'éléments par page
  Future<List<AdminReview>> getReviewsByProduct(
    int productId, {
    int page = 1,
    int perPage = 20,
  });

  /// Récupère les avis d'un utilisateur spécifique.
  ///
  /// Paramètres :
  /// - [userId] : Identifiant de l'utilisateur
  Future<List<AdminReview>> getReviewsByUser(int userId);

  /// Récupère les avis avec une note spécifique.
  ///
  /// Paramètres :
  /// - [rating] : Note (1-5)
  Future<List<AdminReview>> getReviewsByRating(int rating);

  // ============================================
  // DÉTAILS
  // ============================================

  /// Récupère les détails d'un avis par son ID.
  ///
  /// Paramètres :
  /// - [id] : Identifiant de l'avis
  ///
  /// Retourne un [AdminReview] ou null si introuvable.
  Future<AdminReview?> getReviewById(int id);

  // ============================================
  // MODÉRATION
  // ============================================

  /// Approuve un avis.
  ///
  /// Paramètres :
  /// - [id] : Identifiant de l'avis
  ///
  /// Retourne true si l'approbation a réussi.
  Future<bool> approveReview(int id);

  /// Rejette un avis.
  ///
  /// Paramètres :
  /// - [id] : Identifiant de l'avis
  /// - [reason] : Raison du rejet (optionnel)
  Future<bool> rejectReview(int id, {String? reason});

  /// Marque un avis comme spam.
  ///
  /// Paramètres :
  /// - [id] : Identifiant de l'avis
  Future<bool> markReviewAsSpam(int id);

  /// Remet un avis en attente de modération.
  ///
  /// Paramètres :
  /// - [id] : Identifiant de l'avis
  Future<bool> resetReviewStatus(int id);

  // ============================================
  // RÉPONSE ADMIN
  // ============================================

  /// Répond à un avis.
  ///
  /// Paramètres :
  /// - [reviewId] : Identifiant de l'avis
  /// - [response] : Contenu de la réponse
  ///
  /// Retourne true si la réponse a été enregistrée.
  Future<bool> respondToReview(int reviewId, String response);

  /// Modifie la réponse admin existante.
  ///
  /// Paramètres :
  /// - [reviewId] : Identifiant de l'avis
  /// - [response] : Nouvelle réponse
  Future<bool> updateAdminResponse(int reviewId, String response);

  /// Supprime la réponse admin.
  ///
  /// Paramètres :
  /// - [reviewId] : Identifiant de l'avis
  Future<bool> deleteAdminResponse(int reviewId);

  // ============================================
  // RECOMMANDATION
  // ============================================

  /// Marque un avis comme recommandé.
  ///
  /// Paramètres :
  /// - [id] : Identifiant de l'avis
  Future<bool> markAsRecommended(int id);

  /// Retire la recommandation d'un avis.
  ///
  /// Paramètres :
  /// - [id] : Identifiant de l'avis
  Future<bool> unmarkAsRecommended(int id);

  // ============================================
  // STATISTIQUES
  // ============================================

  /// Récupère le nombre total d'avis.
  Future<int> getTotalReviewsCount();

  /// Récupère le nombre d'avis par statut.
  ///
  /// Retourne une map :
  /// ```dart
  /// {
  ///   'pending': 5,
  ///   'approved': 50,
  ///   'rejected': 3,
  ///   'spam': 2,
  /// }
  /// ```
  Future<Map<String, int>> getReviewsCountByStatus();

  /// Récupère le nombre d'avis par note.
  ///
  /// Retourne une map :
  /// ```dart
  /// {
  ///   '5': 30,
  ///   '4': 15,
  ///   '3': 8,
  ///   '2': 3,
  ///   '1': 2,
  /// }
  /// ```
  Future<Map<int, int>> getReviewsCountByRating();

  /// Récupère la note moyenne globale.
  Future<double> getAverageRating();

  /// Récupère les avis les plus utiles.
  ///
  /// Paramètres :
  /// - [limit] : Nombre maximum (défaut : 10)
  Future<List<AdminReview>> getMostHelpfulReviews({int limit = 10});

  /// Récupère les avis les plus consultés.
  ///
  /// Paramètres :
  /// - [limit] : Nombre maximum (défaut : 10)
  Future<List<AdminReview>> getMostViewedReviews({int limit = 10});

  /// Récupère les avis récents.
  ///
  /// Paramètres :
  /// - [limit] : Nombre maximum (défaut : 10)
  Future<List<AdminReview>> getRecentReviews({int limit = 10});

  // ============================================
  // SUPPRESSION
  // ============================================

  /// Supprime un avis (soft delete).
  ///
  /// Paramètres :
  /// - [id] : Identifiant de l'avis
  Future<bool> deleteReview(int id);

  /// Restaure un avis supprimé.
  ///
  /// Paramètres :
  /// - [id] : Identifiant de l'avis
  Future<bool> restoreReview(int id);

  /// Supprime définitivement un avis.
  ///
  /// Paramètres :
  /// - [id] : Identifiant de l'avis
  Future<bool> forceDeleteReview(int id);

  // ============================================
  // ACTIONS EN MASSE
  // ============================================

  /// Approuve plusieurs avis en même temps.
  ///
  /// Paramètres :
  /// - [reviewIds] : Liste des identifiants
  ///
  /// Retourne le nombre d'avis approuvés.
  Future<int> bulkApproveReviews(List<int> reviewIds);

  /// Rejette plusieurs avis en même temps.
  ///
  /// Paramètres :
  /// - [reviewIds] : Liste des identifiants
  ///
  /// Retourne le nombre d'avis rejetés.
  Future<int> bulkRejectReviews(List<int> reviewIds);

  /// Supprime plusieurs avis en même temps.
  ///
  /// Paramètres :
  /// - [reviewIds] : Liste des identifiants
  ///
  /// Retourne le nombre d'avis supprimés.
  Future<int> bulkDeleteReviews(List<int> reviewIds);

  /// Marque plusieurs avis comme spam.
  ///
  /// Paramètres :
  /// - [reviewIds] : Liste des identifiants
  ///
  /// Retourne le nombre d'avis marqués.
  Future<int> bulkMarkAsSpam(List<int> reviewIds);

  // ============================================
  // PAGINATION
  // ============================================

  /// Vérifie s'il y a plus de pages à charger.
  ///
  /// Paramètres :
  /// - [page] : Page actuelle
  /// - [perPage] : Nombre d'éléments par page
  Future<bool> hasMoreReviews({required int page, int perPage = 20});

  /// Récupère le nombre total de pages.
  ///
  /// Paramètres :
  /// - [perPage] : Nombre d'éléments par page
  Future<int> getTotalPages({int perPage = 20});
}