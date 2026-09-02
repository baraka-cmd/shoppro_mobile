// ============================================
// REPOSITORY INTERFACE : AdminPromotionRepository
// ============================================
// Interface définissant le contrat pour la gestion des promotions
// depuis le backoffice administrateur.
//
// Cette interface est dans la couche DOMAIN (métier) et ne dépend
// d'aucune implémentation concrète. Elle sera implémentée dans
// la couche DATA par AdminPromotionRepositoryImpl.
//
// Opérations couvertes :
// - Liste paginée des promotions
// - Recherche et filtrage
// - CRUD complet
// - Activation/désactivation
// - Statistiques d'utilisation
// - Vérification de validité
// ============================================

// ============================================
// IMPORTS
// ============================================

// Entities (même feature admin)
import '../entities/admin_promotion.dart';

// ============================================
// INTERFACE PRINCIPALE
// ============================================

/// Contrat pour le repository de gestion des promotions.
///
/// Cette interface définit toutes les opérations CRUD
/// et de gestion des promotions pour l'administration.
abstract class AdminPromotionRepository {
  // ============================================
  // LISTE ET RECHERCHE
  // ============================================

  /// Récupère la liste paginée des promotions.
  ///
  /// Paramètres :
  /// - [page] : Numéro de page (commence à 1)
  /// - [perPage] : Nombre d'éléments par page (défaut : 20)
  /// - [type] : Filtrer par type de promotion
  /// - [status] : Filtrer par statut
  /// - [sortBy] : Champ de tri (name, start_date, end_date, usage_count)
  /// - [sortDirection] : Direction du tri (asc, desc)
  ///
  /// Retourne une liste de [AdminPromotion].
  Future<List<AdminPromotion>> getPromotions({
    int page = 1,
    int perPage = 20,
    AdminPromotionType? type,
    AdminPromotionStatus? status,
    String? sortBy,
    String? sortDirection,
  });

  /// Recherche des promotions par nom ou description.
  ///
  /// Paramètres :
  /// - [query] : Texte de recherche
  /// - [limit] : Nombre maximum de résultats (défaut : 20)
  Future<List<AdminPromotion>> searchPromotions(String query, {int limit = 20});

  /// Récupère les promotions actives.
  ///
  /// Paramètres :
  /// - [page] : Numéro de page
  /// - [perPage] : Nombre d'éléments par page
  Future<List<AdminPromotion>> getActivePromotions({
    int page = 1,
    int perPage = 20,
  });

  /// Récupère les promotions à venir.
  Future<List<AdminPromotion>> getUpcomingPromotions({
    int page = 1,
    int perPage = 20,
  });

  /// Récupère les promotions expirées.
  Future<List<AdminPromotion>> getExpiredPromotions({
    int page = 1,
    int perPage = 20,
  });

  /// Récupère les promotions en vedette.
  Future<List<AdminPromotion>> getFeaturedPromotions({int limit = 10});

  /// Récupère les promotions expirant bientôt (moins de 3 jours).
  Future<List<AdminPromotion>> getExpiringSoonPromotions();

  // ============================================
  // DÉTAILS
  // ============================================

  /// Récupère les détails d'une promotion par son ID.
  ///
  /// Paramètres :
  /// - [id] : Identifiant de la promotion
  ///
  /// Retourne un [AdminPromotion] ou null si introuvable.
  Future<AdminPromotion?> getPromotionById(int id);

  /// Récupère les détails d'une promotion par son slug.
  ///
  /// Paramètres :
  /// - [slug] : Slug unique de la promotion
  Future<AdminPromotion?> getPromotionBySlug(String slug);

  // ============================================
  // CRUD
  // ============================================

  /// Crée une nouvelle promotion.
  ///
  /// Paramètres :
  /// - [promotion] : La promotion à créer (sans ID)
  ///
  /// Retourne la promotion créée avec son ID.
  ///
  /// Lance une [Exception] si le slug existe déjà.
  Future<AdminPromotion> createPromotion(AdminPromotion promotion);

  /// Met à jour une promotion existante.
  ///
  /// Paramètres :
  /// - [promotion] : La promotion avec les modifications
  ///
  /// Retourne la promotion mise à jour.
  Future<AdminPromotion> updatePromotion(AdminPromotion promotion);

  /// Supprime une promotion (soft delete).
  ///
  /// Paramètres :
  /// - [id] : Identifiant de la promotion
  Future<bool> deletePromotion(int id);

  /// Restaure une promotion supprimée.
  ///
  /// Paramètres :
  /// - [id] : Identifiant de la promotion
  Future<bool> restorePromotion(int id);

  /// Supprime définitivement une promotion.
  ///
  /// Paramètres :
  /// - [id] : Identifiant de la promotion
  Future<bool> forceDeletePromotion(int id);

  // ============================================
  // GESTION DU STATUT
  // ============================================

  /// Active une promotion.
  ///
  /// Paramètres :
  /// - [id] : Identifiant de la promotion
  Future<bool> activatePromotion(int id);

  /// Désactive une promotion.
  ///
  /// Paramètres :
  /// - [id] : Identifiant de la promotion
  Future<bool> deactivatePromotion(int id);

  /// Met en pause une promotion.
  ///
  /// Paramètres :
  /// - [id] : Identifiant de la promotion
  Future<bool> pausePromotion(int id);

  /// Reprend une promotion en pause.
  ///
  /// Paramètres :
  /// - [id] : Identifiant de la promotion
  Future<bool> resumePromotion(int id);

  /// Annule une promotion.
  ///
  /// Paramètres :
  /// - [id] : Identifiant de la promotion
  /// - [reason] : Raison de l'annulation (optionnel)
  Future<bool> cancelPromotion(int id, {String? reason});

  /// Met en vedette une promotion.
  ///
  /// Paramètres :
  /// - [id] : Identifiant de la promotion
  /// - [isFeatured] : true pour mettre en vedette
  Future<bool> setFeaturedPromotion(int id, {required bool isFeatured});

  // ============================================
  // VALIDITÉ
  // ============================================

  /// Vérifie si une promotion est valide actuellement.
  ///
  /// Paramètres :
  /// - [id] : Identifiant de la promotion
  ///
  /// Retourne true si la promotion est active et dans sa période.
  Future<bool> isPromotionValid(int id);

  /// Vérifie si le code d'une promotion est disponible.
  ///
  /// Paramètres :
  /// - [slug] : Slug à vérifier
  ///
  /// Retourne true si le slug est disponible.
  Future<bool> isSlugAvailable(String slug);

  /// Vérifie si la limite d'utilisation est atteinte.
  ///
  /// Paramètres :
  /// - [id] : Identifiant de la promotion
  Future<bool> isUsageLimitReached(int id);

  // ============================================
  // STATISTIQUES
  // ============================================

  /// Récupère le nombre total de promotions.
  Future<int> getTotalPromotionsCount();

  /// Récupère le nombre de promotions par statut.
  ///
  /// Retourne une map avec le format :
  /// ```dart
  /// {
  ///   'active': 5,
  ///   'upcoming': 3,
  ///   'expired': 10,
  ///   'paused': 2,
  ///   'cancelled': 1,
  /// }
  /// ```
  Future<Map<String, int>> getPromotionsCountByStatus();

  /// Récupère le nombre de promotions par type.
  ///
  /// Retourne une map avec le format :
  /// ```dart
  /// {
  ///   'discount': 8,
  ///   'flash_sale': 3,
  ///   'bogo': 2,
  ///   ...
  /// }
  /// ```
  Future<Map<String, int>> getPromotionsCountByType();

  /// Récupère les statistiques d'une promotion.
  ///
  /// Paramètres :
  /// - [id] : Identifiant de la promotion
  ///
  /// Retourne une map avec le format :
  /// ```dart
  /// {
  ///   'usage_count': 50,
  ///   'total_revenue': 1500000,
  ///   'orders_count': 30,
  ///   'total_savings': 250000,
  ///   'conversion_rate': 3.5,
  /// }
  /// ```
  Future<Map<String, dynamic>> getPromotionStats(int id);

  /// Récupère les promotions les plus utilisées.
  ///
  /// Paramètres :
  /// - [limit] : Nombre maximum (défaut : 10)
  Future<List<AdminPromotion>> getMostUsedPromotions({int limit = 10});

  /// Récupère les promotions avec le meilleur revenu.
  ///
  /// Paramètres :
  /// - [limit] : Nombre maximum (défaut : 10)
  Future<List<AdminPromotion>> getTopRevenuePromotions({int limit = 10});

  // ============================================
  // ACTIONS EN MASSE
  // ============================================

  /// Active plusieurs promotions en même temps.
  ///
  /// Paramètres :
  /// - [promotionIds] : Liste des identifiants
  ///
  /// Retourne le nombre de promotions activées.
  Future<int> bulkActivatePromotions(List<int> promotionIds);

  /// Désactive plusieurs promotions en même temps.
  ///
  /// Paramètres :
  /// - [promotionIds] : Liste des identifiants
  ///
  /// Retourne le nombre de promotions désactivées.
  Future<int> bulkDeactivatePromotions(List<int> promotionIds);

  /// Supprime plusieurs promotions en même temps.
  ///
  /// Paramètres :
  /// - [promotionIds] : Liste des identifiants
  ///
  /// Retourne le nombre de promotions supprimées.
  Future<int> bulkDeletePromotions(List<int> promotionIds);

  // ============================================
  // PAGINATION
  // ============================================

  /// Vérifie s'il y a plus de pages à charger.
  ///
  /// Paramètres :
  /// - [page] : Page actuelle
  /// - [perPage] : Nombre d'éléments par page
  Future<bool> hasMorePromotions({required int page, int perPage = 20});

  /// Récupère le nombre total de pages.
  ///
  /// Paramètres :
  /// - [perPage] : Nombre d'éléments par page
  Future<int> getTotalPages({int perPage = 20});
}