// ============================================
// REPOSITORY INTERFACE : AdminUserRepository
// ============================================
// Contrat pour la gestion des utilisateurs (backoffice).
// - Liste paginée
// - Recherche et filtres
// - Détails
// - CRUD complet
// - Upload d'avatar (multipart)
// - Gestion des rôles et statuts
// - Actions en masse
// ============================================

import 'dart:io';
import '../entities/admin_user.dart';

// ============================================
// INTERFACE PRINCIPALE
// ============================================

abstract class AdminUserRepository {
  // ============================================
  // LISTE ET RECHERCHE
  // ============================================

  Future<List<AdminUser>> getUsers({
    int page = 1,
    int perPage = 20,
    String? searchQuery,
    AdminUserRole? role,
    AdminUserStatus? status,
    String? sortBy,
    String? sortDirection,
  });

  Future<List<AdminUser>> searchUsers(String query, {int limit = 20});

  Future<List<AdminUser>> getUsersByRole(
    AdminUserRole role, {
    int page = 1,
    int perPage = 20,
  });

  Future<List<AdminUser>> getUsersByStatus(
    AdminUserStatus status, {
    int page = 1,
    int perPage = 20,
  });

  Future<List<AdminUser>> getRecentUsers({int limit = 10});

  Future<List<AdminUser>> getMostActiveUsers({int limit = 10});

  Future<List<AdminUser>> getTopSpenders({int limit = 10});

  // ============================================
  // DÉTAILS
  // ============================================

  Future<AdminUser?> getUserById(int id);

  Future<AdminUser?> getUserByEmail(String email);

  // ============================================
  // STATISTIQUES
  // ============================================

  Future<int> getTotalUsersCount();

  Future<Map<String, int>> getUsersCountByRole();

  Future<Map<String, int>> getUsersCountByStatus();

  Future<List<Map<String, dynamic>>> getNewUsersByDay({int days = 30});

  // ============================================
  // CRÉATION (VERSION JSON - SANS PHOTO)
  // ============================================

  /// Crée un utilisateur (sans avatar).
  /// Utilise l'API JSON classique.
  Future<AdminUser> createUser(AdminUser user);

  /// Met à jour un utilisateur (sans avatar).
  Future<AdminUser> updateUser(AdminUser user);

  // ============================================
  // 🆕 CRÉATION SIMPLIFIÉE (AVEC PHOTO)
  // ============================================

  /// Crée un nouvel utilisateur avec profil complet
  /// et photo de profil optionnelle (multipart/form-data).
  ///
  /// [name] : Nom complet (obligatoire)
  /// [email] : Email unique (obligatoire)
  /// [password] : Mot de passe (min 6 caractères)
  /// [passwordConfirmation] : Confirmation du mot de passe
  /// [role] : 'admin' | 'seller' | 'client'
  /// [phone] : Téléphone (optionnel)
  /// [country] : Pays (optionnel)
  /// [city] : Ville (optionnel)
  /// [address] : Adresse (optionnel)
  /// [isActive] : Compte actif (défaut true)
  /// [avatarFile] : Fichier image (optionnel)
  Future<AdminUser> createUserSimple({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String role,
    String? phone,
    String? country,
    String? city,
    String? address,
    bool isActive = true,
    File? avatarFile,
  });

  /// Met à jour un utilisateur avec photo optionnelle.
  Future<AdminUser> updateUserSimple({
    required int id,
    String? name,
    String? email,
    String? password,
    String? passwordConfirmation,
    String? role,
    String? phone,
    String? country,
    String? city,
    String? address,
    bool? isActive,
    File? avatarFile,
    bool removeAvatar = false,
  });

  // ============================================
  // 🆕 UPLOAD D'AVATAR (ENDPOINTS DÉDIÉS)
  // ============================================

  /// Upload l'avatar d'un utilisateur.
  /// Retourne l'URL complète de l'avatar uploadé.
  Future<String> uploadAvatar(int id, File avatarFile);

  /// Supprime l'avatar d'un utilisateur.
  Future<bool> deleteAvatar(int id);

  // ============================================
  // SUPPRESSION
  // ============================================

  Future<bool> deleteUser(int id);

  Future<bool> restoreUser(int id);

  Future<bool> forceDeleteUser(int id);

  // ============================================
  // GESTION DES RÔLES
  // ============================================

  Future<bool> changeUserRole(int userId, AdminUserRole newRole);

  Future<bool> addRoleToUser(int userId, AdminUserRole role);

  Future<bool> removeRoleFromUser(int userId, AdminUserRole role);

  Future<List<AdminUserRole>> getUserRoles(int userId);

  // ============================================
  // GESTION DU STATUT
  // ============================================

  Future<bool> activateUser(int id);

  Future<bool> deactivateUser(int id);

  Future<bool> banUser(int id, {String? reason});

  Future<bool> suspendUser(int id,
      {Duration duration = const Duration(days: 7)});

  Future<bool> unsuspendUser(int id);

  // ============================================
  // VÉRIFICATION EMAIL
  // ============================================

  Future<bool> verifyUserEmail(int id);

  Future<bool> resendVerificationEmail(int id);

  // ============================================
  // ACTIONS EN MASSE
  // ============================================

  Future<int> bulkActivateUsers(List<int> userIds);

  Future<int> bulkDeactivateUsers(List<int> userIds);

  Future<int> bulkDeleteUsers(List<int> userIds);

  Future<int> bulkChangeRole(List<int> userIds, AdminUserRole newRole);

  // ============================================
  // PAGINATION
  // ============================================

  Future<bool> hasMoreUsers({required int page, int perPage = 20});

  Future<int> getTotalPages({int perPage = 20});
}