// ============================================
// REPOSITORY IMPL : AdminUserRepositoryImpl
// ============================================
// Implémentation du repository de gestion des utilisateurs.
// - CRUD complet
// - Upload d'avatar (multipart/form-data)
// - Gestion des rôles et statuts
// - Actions en masse
// ============================================

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

// Entities
import '../../domain/entities/admin_user.dart';

// Repositories interfaces
import '../../domain/repositories/admin_user_repository.dart';

// Models
import '../models/admin_user_model.dart';

// Sources
import '../sources/admin_user_api.dart';

class AdminUserRepositoryImpl implements AdminUserRepository {
  // ============================================
  // DÉPENDANCES
  // ============================================

  final AdminUserApi _api;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  AdminUserRepositoryImpl({AdminUserApi? api}) : _api = api ?? AdminUserApi();

  // ============================================
  // LISTE ET RECHERCHE
  // ============================================

  @override
  Future<List<AdminUser>> getUsers({
    int page = 1,
    int perPage = 20,
    String? searchQuery,
    AdminUserRole? role,
    AdminUserStatus? status,
    String? sortBy,
    String? sortDirection,
  }) async {
    try {
      final response = await _api.getUsers(
        page: page,
        perPage: perPage,
        searchQuery: searchQuery,
        role: role?.code,
        status: status?.code,
        sortBy: sortBy,
        sortDirection: sortDirection,
      );

      final data = response['data'];
      if (data is List) {
        return data
            .map((e) => AdminUserModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getUsers: $e');
      rethrow;
    }
  }

  @override
  Future<List<AdminUser>> searchUsers(String query, {int limit = 20}) async {
    try {
      final response = await _api.searchUsers(query, limit: limit);
      final data = response['data'];
      if (data is List) {
        return data
            .map((e) => AdminUserModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur searchUsers: $e');
      rethrow;
    }
  }

  @override
  Future<List<AdminUser>> getUsersByRole(
    AdminUserRole role, {
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _api.getUsersByRole(role.code, page: page, perPage: perPage);
      final data = response['data'];
      if (data is List) {
        return data
            .map((e) => AdminUserModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getUsersByRole: $e');
      rethrow;
    }
  }

  @override
  Future<List<AdminUser>> getUsersByStatus(
    AdminUserStatus status, {
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _api.getUsersByStatus(status.code, page: page, perPage: perPage);
      final data = response['data'];
      if (data is List) {
        return data
            .map((e) => AdminUserModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getUsersByStatus: $e');
      rethrow;
    }
  }

  @override
  Future<List<AdminUser>> getRecentUsers({int limit = 10}) async {
    try {
      final response = await _api.getRecentUsers(limit: limit);
      final data = response['data'];
      if (data is List) {
        return data
            .map((e) => AdminUserModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getRecentUsers: $e');
      rethrow;
    }
  }

  @override
  Future<List<AdminUser>> getMostActiveUsers({int limit = 10}) async {
    return getUsers(
      sortBy: 'total_orders',
      sortDirection: 'desc',
      perPage: limit,
    );
  }

  @override
  Future<List<AdminUser>> getTopSpenders({int limit = 10}) async {
    return getUsers(
      sortBy: 'total_spent',
      sortDirection: 'desc',
      perPage: limit,
    );
  }

  // ============================================
  // DÉTAILS
  // ============================================

  @override
  Future<AdminUser?> getUserById(int id) async {
    try {
      final response = await _api.getUserById(id);
      final data = response['data'];
      if (data is Map) {
        return AdminUserModel.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      debugPrint('Erreur getUserById: $e');
      rethrow;
    }
  }

  @override
  Future<AdminUser?> getUserByEmail(String email) async {
    try {
      final response = await _api.getUserByEmail(email);
      final data = response['data'];
      if (data is Map) {
        return AdminUserModel.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      debugPrint('Erreur getUserByEmail: $e');
      rethrow;
    }
  }

  // ============================================
  // STATISTIQUES
  // ============================================

  @override
  Future<int> getTotalUsersCount() async {
    try {
      final response = await _api.getTotalUsersCount();
      final data = response['data'];
      if (data is Map) {
        return (data['count'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Erreur getTotalUsersCount: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, int>> getUsersCountByRole() async {
    try {
      final response = await _api.getUsersCountByRole();
      final data = response['data'];
      if (data is Map) {
        return Map<String, int>.from(
          data.map((key, value) => MapEntry(key.toString(), (value as num).toInt())),
        );
      }
      return {};
    } catch (e) {
      debugPrint('Erreur getUsersCountByRole: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, int>> getUsersCountByStatus() async {
    try {
      final response = await _api.getUsersCountByStatus();
      final data = response['data'];
      if (data is Map) {
        return Map<String, int>.from(
          data.map((key, value) => MapEntry(key.toString(), (value as num).toInt())),
        );
      }
      return {};
    } catch (e) {
      debugPrint('Erreur getUsersCountByStatus: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getNewUsersByDay({int days = 30}) async {
    try {
      final users = await getUsers(
        perPage: 100,
        sortBy: 'created_at',
        sortDirection: 'desc',
      );

      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: days));
      final byDay = <String, int>{};

      for (final user in users) {
        if (user.createdAt.isAfter(startDate)) {
          final dayKey = user.createdAt.toIso8601String().split('T').first;
          byDay[dayKey] = (byDay[dayKey] ?? 0) + 1;
        }
      }

      return byDay.entries
          .map((e) => {'date': e.key, 'count': e.value})
          .toList()
        ..sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));
    } catch (e) {
      debugPrint('Erreur getNewUsersByDay: $e');
      rethrow;
    }
  }

  // ============================================
  // 🆕 CRÉATION AVEC AVATAR (FormData)
  // ============================================

  @override
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
  }) async {
    try {
      // Construire le FormData
      final formData = FormData();

      formData.fields.addAll([
        MapEntry('name', name),
        MapEntry('email', email),
        MapEntry('password', password),
        MapEntry('password_confirmation', passwordConfirmation),
        MapEntry('role', role),
        MapEntry('is_active', isActive ? '1' : '0'),
      ]);

      if (phone != null && phone.isNotEmpty) {
        formData.fields.add(MapEntry('phone', phone));
      }
      if (country != null && country.isNotEmpty) {
        formData.fields.add(MapEntry('country', country));
      }
      if (city != null && city.isNotEmpty) {
        formData.fields.add(MapEntry('city', city));
      }
      if (address != null && address.isNotEmpty) {
        formData.fields.add(MapEntry('address', address));
      }

      // Ajouter l'avatar si présent
      if (avatarFile != null) {
        final fileName = avatarFile.path.split(Platform.pathSeparator).last;
        formData.files.add(
          MapEntry(
            'avatar',
            await MultipartFile.fromFile(
              avatarFile.path,
              filename: fileName,
            ),
          ),
        );
      }

      final response = await _api.createUserMultipart(formData);
      final data = response['data'];
      return AdminUserModel.fromJson(Map<String, dynamic>.from(data as Map));
    } catch (e) {
      debugPrint('Erreur createUserSimple: $e');
      rethrow;
    }
  }

  // ============================================
  // 🆕 MODIFICATION AVEC AVATAR (FormData)
  // ============================================

  @override
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
  }) async {
    try {
      final formData = FormData();

      // ⚠️ Spoof PUT avec POST (Laravel n'accepte pas PUT + multipart facilement)
      formData.fields.add(MapEntry('_method', 'PUT'));

      if (name != null) formData.fields.add(MapEntry('name', name));
      if (email != null) formData.fields.add(MapEntry('email', email));
      if (password != null && password.isNotEmpty) {
        formData.fields.add(MapEntry('password', password));
        formData.fields.add(MapEntry(
          'password_confirmation',
          passwordConfirmation ?? password,
        ));
      }
      if (role != null) formData.fields.add(MapEntry('role', role));
      if (phone != null) formData.fields.add(MapEntry('phone', phone));
      if (country != null) formData.fields.add(MapEntry('country', country));
      if (city != null) formData.fields.add(MapEntry('city', city));
      if (address != null) formData.fields.add(MapEntry('address', address));
      if (isActive != null) {
        formData.fields.add(MapEntry('is_active', isActive ? '1' : '0'));
      }
      if (removeAvatar) {
        formData.fields.add(const MapEntry('remove_avatar', '1'));
      }

      // Ajouter l'avatar si présent
      if (avatarFile != null) {
        final fileName = avatarFile.path.split(Platform.pathSeparator).last;
        formData.files.add(
          MapEntry(
            'avatar',
            await MultipartFile.fromFile(
              avatarFile.path,
              filename: fileName,
            ),
          ),
        );
      }

      final response = await _api.updateUserMultipart(id, formData);
      final data = response['data'];
      return AdminUserModel.fromJson(Map<String, dynamic>.from(data as Map));
    } catch (e) {
      debugPrint('Erreur updateUserSimple: $e');
      rethrow;
    }
  }

  // ============================================
  // CRUD (VERSION JSON — sans avatar)
  // ============================================

  @override
  Future<AdminUser> createUser(AdminUser user) async {
    try {
      final model = AdminUserModel.fromEntity(user);
      final response = await _api.createUser(model.toJson());
      final data = response['data'];
      return AdminUserModel.fromJson(Map<String, dynamic>.from(data as Map));
    } catch (e) {
      debugPrint('Erreur createUser: $e');
      rethrow;
    }
  }

  @override
  Future<AdminUser> updateUser(AdminUser user) async {
    try {
      final model = AdminUserModel.fromEntity(user);
      final response = await _api.updateUser(user.id, model.toJson());
      final data = response['data'];
      return AdminUserModel.fromJson(Map<String, dynamic>.from(data as Map));
    } catch (e) {
      debugPrint('Erreur updateUser: $e');
      rethrow;
    }
  }

  @override
  Future<bool> deleteUser(int id) async {
    try {
      final response = await _api.deleteUser(id);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur deleteUser: $e');
      rethrow;
    }
  }

  @override
  Future<bool> restoreUser(int id) async {
    try {
      final response = await _api.restoreUser(id);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur restoreUser: $e');
      rethrow;
    }
  }

  @override
  Future<bool> forceDeleteUser(int id) async {
    try {
      final response = await _api.forceDeleteUser(id);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur forceDeleteUser: $e');
      rethrow;
    }
  }

  // ============================================
  // GESTION DES RÔLES
  // ============================================

  @override
  Future<bool> changeUserRole(int userId, AdminUserRole newRole) async {
    try {
      final response = await _api.changeUserRole(userId, newRole.code);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur changeUserRole: $e');
      rethrow;
    }
  }

  @override
  Future<bool> addRoleToUser(int userId, AdminUserRole role) async {
    try {
      final response = await _api.addRoleToUser(userId, role.code);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur addRoleToUser: $e');
      rethrow;
    }
  }

  @override
  Future<bool> removeRoleFromUser(int userId, AdminUserRole role) async {
    try {
      final response = await _api.removeRoleFromUser(userId, role.code);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur removeRoleFromUser: $e');
      rethrow;
    }
  }

  @override
  Future<List<AdminUserRole>> getUserRoles(int userId) async {
    try {
      final user = await getUserById(userId);
      return user?.roles ?? const [];
    } catch (e) {
      debugPrint('Erreur getUserRoles: $e');
      rethrow;
    }
  }

  // ============================================
  // GESTION DU STATUT
  // ============================================

  @override
  Future<bool> activateUser(int id) async {
    try {
      final response = await _api.activateUser(id);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur activateUser: $e');
      rethrow;
    }
  }

  @override
  Future<bool> deactivateUser(int id) async {
    try {
      final response = await _api.deactivateUser(id);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur deactivateUser: $e');
      rethrow;
    }
  }

  @override
  Future<bool> banUser(int id, {String? reason}) async {
    try {
      final response = await _api.banUser(id, reason: reason);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur banUser: $e');
      rethrow;
    }
  }

  @override
  Future<bool> suspendUser(int id, {Duration duration = const Duration(days: 7)}) async {
    try {
      final response = await _api.suspendUser(id, days: duration.inDays);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur suspendUser: $e');
      rethrow;
    }
  }

  @override
  Future<bool> unsuspendUser(int id) async {
    try {
      final response = await _api.unsuspendUser(id);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur unsuspendUser: $e');
      rethrow;
    }
  }

  // ============================================
  // 🆕 AVATAR (endpoints dédiés)
  // ============================================

  @override
  Future<String> uploadAvatar(int id, File avatarFile) async {
    try {
      final formData = FormData();
      final fileName = avatarFile.path.split(Platform.pathSeparator).last;

      formData.files.add(
        MapEntry(
          'avatar',
          await MultipartFile.fromFile(avatarFile.path, filename: fileName),
        ),
      );

      final response = await _api.uploadAvatar(id, formData);
      return response['data']['avatar'] as String? ?? '';
    } catch (e) {
      debugPrint('Erreur uploadAvatar: $e');
      rethrow;
    }
  }

  @override
  Future<bool> deleteAvatar(int id) async {
    try {
      final response = await _api.deleteAvatar(id);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur deleteAvatar: $e');
      rethrow;
    }
  }

  // ============================================
  // VÉRIFICATION EMAIL
  // ============================================

  @override
  Future<bool> verifyUserEmail(int id) async {
    try {
      final response = await _api.updateUser(id, {
        'email_verified_at': DateTime.now().toIso8601String(),
      });
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur verifyUserEmail: $e');
      rethrow;
    }
  }

  @override
  Future<bool> resendVerificationEmail(int id) async {
    try {
      final response = await _api.activateUser(id);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur resendVerificationEmail: $e');
      rethrow;
    }
  }

  // ============================================
  // ACTIONS EN MASSE
  // ============================================

  @override
  Future<int> bulkActivateUsers(List<int> userIds) async {
    var count = 0;
    for (final id in userIds) {
      if (await activateUser(id)) count++;
    }
    return count;
  }

  @override
  Future<int> bulkDeactivateUsers(List<int> userIds) async {
    var count = 0;
    for (final id in userIds) {
      if (await deactivateUser(id)) count++;
    }
    return count;
  }

  @override
  Future<int> bulkDeleteUsers(List<int> userIds) async {
    var count = 0;
    for (final id in userIds) {
      if (await deleteUser(id)) count++;
    }
    return count;
  }

  @override
  Future<int> bulkChangeRole(List<int> userIds, AdminUserRole newRole) async {
    var count = 0;
    for (final id in userIds) {
      if (await changeUserRole(id, newRole)) count++;
    }
    return count;
  }

  // ============================================
  // PAGINATION
  // ============================================

  @override
  Future<bool> hasMoreUsers({required int page, int perPage = 20}) async {
    final users = await getUsers(page: page + 1, perPage: perPage);
    return users.isNotEmpty;
  }

  @override
  Future<int> getTotalPages({int perPage = 20}) async {
    final total = await getTotalUsersCount();
    return (total / perPage).ceil();
  }
}