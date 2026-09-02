// ============================================
// REPOSITORY INTERFACE : AdminUserRepository
// ============================================
// Interface définissant le contrat pour la gestion des utilisateurs
// depuis le backoffice administrateur.
//
// Cette interface est dans la couche DOMAIN (métier) et ne dépend
// d'aucune implémentation concrète. Elle sera implémentée dans
// la couche DATA par AdminUserRepositoryImpl.
//
// Opérations couvertes :
// - Liste paginée des utilisateurs
// - Recherche et filtrage
// - Détails d'un utilisateur
// - Création, modification, suppression
// - Gestion des rôles
// - Gestion du statut (bannir, suspendre, activer)
// ============================================

// ============================================
// IMPORTS
// ============================================

// Entities (même feature admin)
import '../entities/admin_user.dart';

// ============================================
// INTERFACE PRINCIPALE
// ============================================

/// Contrat pour le repository de gestion des utilisateurs.
///
/// Cette interface définit toutes les opérations CRUD
/// et de gestion des utilisateurs pour l'administration.
abstract class AdminUserRepository {
  // ============================================
  // LISTE ET RECHERCHE
  // ============================================

  /// Récupère la liste paginée des utilisateurs.
  ///
  /// Paramètres :
  /// - [page] : Numéro de page (commence à 1)
  /// - [perPage] : Nombre d'éléments par page (défaut : 20)
  /// - [searchQuery] : Recherche par nom ou email
  /// - [role] : Filtrer par rôle
  /// - [status] : Filtrer par statut
  /// - [sortBy] : Champ de tri (name, email, created_at, total_orders)
  /// - [sortDirection] : Direction du tri (asc, desc)
  ///
  /// Retourne une liste de [AdminUser].
  ///
  /// Lance une [Exception] en cas d'erreur réseau ou serveur.
  Future<List<AdminUser>> getUsers({
    int page = 1,
    int perPage = 20,
    String? searchQuery,
    AdminUserRole? role,
    AdminUserStatus? status,
    String? sortBy,
    String? sortDirection,
  });

  /// Recherche des utilisateurs par nom ou email.
  ///
  /// Paramètres :
  /// - [query] : Texte de recherche
  /// - [limit] : Nombre maximum de résultats (défaut : 20)
  ///
  /// Retourne une liste de [AdminUser] correspondant.
  Future<List<AdminUser>> searchUsers(String query, {int limit = 20});

  /// Récupère les utilisateurs par rôle.
  ///
  /// Paramètres :
  /// - [role] : Rôle à filtrer
  /// - [page] : Numéro de page
  /// - [perPage] : Nombre d'éléments par page
  Future<List<AdminUser>> getUsersByRole(
    AdminUserRole role, {
    int page = 1,
    int perPage = 20,
  });

  /// Récupère les utilisateurs par statut.
  ///
  /// Paramètres :
  /// - [status] : Statut à filtrer
  /// - [page] : Numéro de page
  /// - [perPage] : Nombre d'éléments par page
  Future<List<AdminUser>> getUsersByStatus(
    AdminUserStatus status, {
    int page = 1,
    int perPage = 20,
  });

  /// Récupère les utilisateurs récemment inscrits.
  ///
  /// Paramètres :
  /// - [limit] : Nombre maximum (défaut : 10)
  Future<List<AdminUser>> getRecentUsers({int limit = 10});

  /// Récupère les utilisateurs les plus actifs (plus de commandes).
  ///
  /// Paramètres :
  /// - [limit] : Nombre maximum (défaut : 10)
  Future<List<AdminUser>> getMostActiveUsers({int limit = 10});

  /// Récupère les utilisateurs qui ont le plus dépensé.
  ///
  /// Paramètres :
  /// - [limit] : Nombre maximum (défaut : 10)
  Future<List<AdminUser>> getTopSpenders({int limit = 10});

  // ============================================
  // DÉTAILS
  // ============================================

  /// Récupère les détails d'un utilisateur par son ID.
  ///
  /// Paramètres :
  /// - [id] : Identifiant de l'utilisateur
  ///
  /// Retourne un [AdminUser] complet ou null si introuvable.
  Future<AdminUser?> getUserById(int id);

  /// Récupère les détails d'un utilisateur par son email.
  ///
  /// Paramètres :
  /// - [email] : Adresse email de l'utilisateur
  ///
  /// Retourne un [AdminUser] complet ou null si introuvable.
  Future<AdminUser?> getUserByEmail(String email);

  // ============================================
  // STATISTIQUES
  // ============================================

  /// Récupère le nombre total d'utilisateurs.
  Future<int> getTotalUsersCount();

  /// Récupère le nombre d'utilisateurs par rôle.
  ///
  /// Retourne une map avec le format :
  /// ```dart
  /// {
  ///   'admin': 2,
  ///   'seller': 5,
  ///   'client': 150,
  /// }
  /// ```
  Future<Map<String, int>> getUsersCountByRole();

  /// Récupère le nombre d'utilisateurs par statut.
  ///
  /// Retourne une map avec le format :
  /// ```dart
  /// {
  ///   'active': 140,
  ///   'inactive': 10,
  ///   'banned': 3,
  ///   'suspended': 4,
  /// }
  /// ```
  Future<Map<String, int>> getUsersCountByStatus();

  /// Récupère le nombre de nouveaux utilisateurs par jour.
  ///
  /// Paramètres :
  /// - [days] : Nombre de jours (défaut : 30)
  ///
  /// Retourne une liste de maps avec le format :
  /// ```dart
  /// [
  ///   {'date': '2026-08-01', 'count': 5},
  ///   ...
  /// ]
  /// ```
  Future<List<Map<String, dynamic>>> getNewUsersByDay({int days = 30});

  // ============================================
  // CRUD
  // ============================================

  /// Crée un nouvel utilisateur.
  ///
  /// Paramètres :
  /// - [user] : L'utilisateur à créer (sans ID)
  ///
  /// Retourne l'utilisateur créé avec son ID.
  ///
  /// Lance une [Exception] si l'email existe déjà.
  Future<AdminUser> createUser(AdminUser user);

  /// Met à jour un utilisateur existant.
  ///
  /// Paramètres :
  /// - [user] : L'utilisateur avec les modifications
  ///
  /// Retourne l'utilisateur mis à jour.
  ///
  /// Lance une [Exception] si l'utilisateur n'existe pas.
  Future<AdminUser> updateUser(AdminUser user);

  /// Supprime un utilisateur (soft delete).
  ///
  /// Paramètres :
  /// - [id] : Identifiant de l'utilisateur
  ///
  /// Retourne true si la suppression a réussi.
  Future<bool> deleteUser(int id);

  /// Restaure un utilisateur supprimé.
  ///
  /// Paramètres :
  /// - [id] : Identifiant de l'utilisateur
  ///
  /// Retourne true si la restauration a réussi.
  Future<bool> restoreUser(int id);

  /// Supprime définitivement un utilisateur.
  ///
  /// Paramètres :
  /// - [id] : Identifiant de l'utilisateur
  ///
  /// Retourne true si la suppression définitive a réussi.
  Future<bool> forceDeleteUser(int id);

  // ============================================
  // GESTION DES RÔLES
  // ============================================

  /// Change le rôle d'un utilisateur.
  ///
  /// Paramètres :
  /// - [userId] : Identifiant de l'utilisateur
  /// - [newRole] : Nouveau rôle
  ///
  /// Retourne true si le changement a réussi.
  Future<bool> changeUserRole(int userId, AdminUserRole newRole);

  /// Ajoute un rôle à un utilisateur (sans retirer les autres).
  ///
  /// Paramètres :
  /// - [userId] : Identifiant de l'utilisateur
  /// - [role] : Rôle à ajouter
  Future<bool> addRoleToUser(int userId, AdminUserRole role);

  /// Retire un rôle à un utilisateur.
  ///
  /// Paramètres :
  /// - [userId] : Identifiant de l'utilisateur
  /// - [role] : Rôle à retirer
  Future<bool> removeRoleFromUser(int userId, AdminUserRole role);

  /// Récupère les rôles d'un utilisateur.
  ///
  /// Paramètres :
  /// - [userId] : Identifiant de l'utilisateur
  ///
  /// Retourne la liste des rôles.
  Future<List<AdminUserRole>> getUserRoles(int userId);

  // ============================================
  // GESTION DU STATUT
  // ============================================

  /// Active un utilisateur.
  ///
  /// Paramètres :
  /// - [id] : Identifiant de l'utilisateur
  Future<bool> activateUser(int id);

  /// Désactive un utilisateur.
  ///
  /// Paramètres :
  /// - [id] : Identifiant de l'utilisateur
  Future<bool> deactivateUser(int id);

  /// Bannit un utilisateur.
  ///
  /// Paramètres :
  /// - [id] : Identifiant de l'utilisateur
  /// - [reason] : Raison du bannissement (optionnel)
  Future<bool> banUser(int id, {String? reason});

  /// Suspend un utilisateur.
  ///
  /// Paramètres :
  /// - [id] : Identifiant de l'utilisateur
  /// - [duration] : Durée de suspension (ex: 7 jours)
  Future<bool> suspendUser(int id, {Duration duration = const Duration(days: 7)});

  /// Lève la suspension d'un utilisateur.
  ///
  /// Paramètres :
  /// - [id] : Identifiant de l'utilisateur
  Future<bool> unsuspendUser(int id);

  // ============================================
  // VÉRIFICATION EMAIL
  // ============================================

  /// Vérifie manuellement l'email d'un utilisateur.
  ///
  /// Paramètres :
  /// - [id] : Identifiant de l'utilisateur
  Future<bool> verifyUserEmail(int id);

  /// Renvoie le lien de vérification d'email.
  ///
  /// Paramètres :
  /// - [id] : Identifiant de l'utilisateur
  Future<bool> resendVerificationEmail(int id);

  // ============================================
  // ACTIONS EN MASSE
  // ============================================

  /// Active plusieurs utilisateurs en même temps.
  ///
  /// Paramètres :
  /// - [userIds] : Liste des identifiants
  ///
  /// Retourne le nombre d'utilisateurs activés.
  Future<int> bulkActivateUsers(List<int> userIds);

  /// Désactive plusieurs utilisateurs en même temps.
  ///
  /// Paramètres :
  /// - [userIds] : Liste des identifiants
  ///
  /// Retourne le nombre d'utilisateurs désactivés.
  Future<int> bulkDeactivateUsers(List<int> userIds);

  /// Supprime plusieurs utilisateurs en même temps.
  ///
  /// Paramètres :
  /// - [userIds] : Liste des identifiants
  ///
  /// Retourne le nombre d'utilisateurs supprimés.
  Future<int> bulkDeleteUsers(List<int> userIds);

  /// Change le rôle de plusieurs utilisateurs.
  ///
  /// Paramètres :
  /// - [userIds] : Liste des identifiants
  /// - [newRole] : Nouveau rôle
  ///
  /// Retourne le nombre d'utilisateurs modifiés.
  Future<int> bulkChangeRole(List<int> userIds, AdminUserRole newRole);

  // ============================================
  // PAGINATION
  // ============================================

  /// Vérifie s'il y a plus de pages à charger.
  ///
  /// Paramètres :
  /// - [page] : Page actuelle
  /// - [perPage] : Nombre d'éléments par page
  Future<bool> hasMoreUsers({required int page, int perPage = 20});

  /// Récupère le nombre total de pages.
  ///
  /// Paramètres :
  /// - [perPage] : Nombre d'éléments par page
  Future<int> getTotalPages({int perPage = 20});
}