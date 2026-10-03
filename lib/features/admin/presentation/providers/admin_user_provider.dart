// ============================================
// PROVIDER : AdminUserProvider (COMPLET)
// ============================================
// Provider de gestion des utilisateurs.
// - Liste paginée + recherche + filtres
// - Détail d'un utilisateur (loadUserDetail)
// - CRUD complet
// - Upload d'avatar
// - Gestion des rôles et statuts
// - Actions en masse
// ============================================

import 'dart:io';
import 'package:flutter/material.dart';

import '../../domain/entities/admin_user.dart';
import '../../domain/repositories/admin_user_repository.dart';
import '../../data/repositories/admin_user_repository_impl.dart';
import '../../data/models/admin_user_model.dart';

// ============================================
// ENUM D'ÉTAT
// ============================================

enum AdminUserStatus2 {
  initial,
  loading,
  loaded,
  loadingMore,
  loadingDetail,
  updating,
  creating,
  error,
}

// ============================================
// PROVIDER
// ============================================

class AdminUserProvider extends ChangeNotifier {
  final AdminUserRepository _repository;

  AdminUserProvider({AdminUserRepository? repository})
      : _repository = repository ?? AdminUserRepositoryImpl();

  // ============================================
  // ÉTAT
  // ============================================

  AdminUserStatus2 _status = AdminUserStatus2.initial;
  List<AdminUser> _users = [];
  String? _errorMessage;
  int _currentPage = 1;
  int _perPage = 20;
  bool _hasMore = true;
  int _totalUsers = 0;

  // Détail
  AdminUser? _currentUser;
  Map<String, dynamic>? _currentUserJson;

  // Filtres
  String? _searchQuery;
  AdminUserRole? _filterRole;
  AdminUserStatus? _filterStatus;
  String _sortBy = 'created_at';
  String _sortDirection = 'desc';

  // Sélection
  final Set<int> _selectedUserIds = {};

  // ============================================
  // GETTERS
  // ============================================

  AdminUserStatus2 get status => _status;
  List<AdminUser> get users => List.unmodifiable(_users);
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get perPage => _perPage;
  bool get hasMore => _hasMore;
  int get totalUsers => _totalUsers;
  bool get isLoading => _status == AdminUserStatus2.loading;
  bool get isLoaded => _status == AdminUserStatus2.loaded;
  bool get isLoadingMore => _status == AdminUserStatus2.loadingMore;
  bool get isLoadingDetail => _status == AdminUserStatus2.loadingDetail;
  bool get isCreating => _status == AdminUserStatus2.creating;
  bool get isUpdating => _status == AdminUserStatus2.updating;
  bool get hasError => _status == AdminUserStatus2.error;

  int get usersCount => _users.length;
  bool get isEmpty => _users.isEmpty;
  bool get hasSelection => _selectedUserIds.isNotEmpty;
  int get selectedCount => _selectedUserIds.length;
  List<int> get selectedUserIds => List.unmodifiable(_selectedUserIds);

  String? get searchQuery => _searchQuery;
  AdminUserRole? get filterRole => _filterRole;
  AdminUserStatus? get filterStatus => _filterStatus;

  AdminUser? get currentUser => _currentUser;
  Map<String, dynamic>? get currentUserJson => _currentUserJson;
  bool get hasCurrentUser => _currentUser != null;

  // ============================================
  // CHARGEMENT
  // ============================================

  Future<void> loadUsers() async {
    _status = AdminUserStatus2.loading;
    _errorMessage = null;
    _currentPage = 1;
    notifyListeners();

    try {
      final users = await _repository.getUsers(
        page: _currentPage,
        perPage: _perPage,
        searchQuery: _searchQuery,
        role: _filterRole,
        status: _filterStatus,
        sortBy: _sortBy,
        sortDirection: _sortDirection,
      );

      _users = users.map(_normalizeUser).toList();
      _hasMore = users.length >= _perPage;
      _status = AdminUserStatus2.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminUserStatus2.error;
      debugPrint('Erreur loadUsers: $e');
    }

    notifyListeners();
  }

  Future<void> loadMoreUsers() async {
    if (_status == AdminUserStatus2.loadingMore || !_hasMore) return;

    _status = AdminUserStatus2.loadingMore;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final users = await _repository.getUsers(
        page: nextPage,
        perPage: _perPage,
        searchQuery: _searchQuery,
        role: _filterRole,
        status: _filterStatus,
        sortBy: _sortBy,
        sortDirection: _sortDirection,
      );

      if (users.isEmpty) {
        _hasMore = false;
      } else {
        _users = [..._users, ...users.map(_normalizeUser)];
        _currentPage = nextPage;
        _hasMore = users.length >= _perPage;
      }

      _status = AdminUserStatus2.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminUserStatus2.error;
      debugPrint('Erreur loadMoreUsers: $e');
    }

    notifyListeners();
  }

  Future<void> refreshUsers() async {
    try {
      final users = await _repository.getUsers(
        page: 1,
        perPage: _perPage,
        searchQuery: _searchQuery,
        role: _filterRole,
        status: _filterStatus,
        sortBy: _sortBy,
        sortDirection: _sortDirection,
      );

      _users = users.map(_normalizeUser).toList();
      _currentPage = 1;
      _hasMore = users.length >= _perPage;
      _status = AdminUserStatus2.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Erreur refreshUsers: $e');
    }

    notifyListeners();
  }

  // ============================================
  // DÉTAIL
  // ============================================

  Future<void> loadUserDetail(int userId) async {
    _status = AdminUserStatus2.loadingDetail;
    _errorMessage = null;
    _currentUser = null;
    _currentUserJson = null;
    notifyListeners();

    try {
      final user = await _repository.getUserById(userId);

      if (user == null) {
        _errorMessage = 'Utilisateur introuvable.';
        _status = AdminUserStatus2.error;
        notifyListeners();
        return;
      }

      _currentUser = _normalizeUser(user);
      _status = AdminUserStatus2.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminUserStatus2.error;
      debugPrint('Erreur loadUserDetail: $e');
    }

    notifyListeners();
  }

  AdminUser? getUserById(int userId) {
    if (_currentUser?.id == userId) return _currentUser;
    for (final u in _users) {
      if (u.id == userId) return u;
    }
    return null;
  }

  void clearCurrentUser() {
    _currentUser = null;
    _currentUserJson = null;
    notifyListeners();
  }

  // ============================================
  // CRÉATION SIMPLIFIÉE (avec avatar)
  // ============================================

  Future<AdminUser?> createUserSimple({
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
    _status = AdminUserStatus2.creating;
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await _repository.createUserSimple(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        role: role,
        phone: phone,
        country: country,
        city: city,
        address: address,
        isActive: isActive,
        avatarFile: avatarFile,
      );

      _users.insert(0, _normalizeUser(created));
      _status = AdminUserStatus2.loaded;
      notifyListeners();
      return created;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _status = AdminUserStatus2.error;
      debugPrint('Erreur createUserSimple: $e');
      notifyListeners();
      return null;
    }
  }

  // ============================================
  // RECHERCHE ET FILTRES
  // ============================================

  Future<void> search(String query) async {
    _searchQuery = query.trim().isEmpty ? null : query.trim();
    await loadUsers();
  }

  Future<void> filterByRole(AdminUserRole? role) async {
    _filterRole = role;
    await loadUsers();
  }

  Future<void> filterByStatus(AdminUserStatus? status) async {
    _filterStatus = status;
    await loadUsers();
  }

  Future<void> sort(String sortBy, {String direction = 'asc'}) async {
    _sortBy = sortBy;
    _sortDirection = direction;
    await loadUsers();
  }

  Future<void> clearFilters() async {
    _searchQuery = null;
    _filterRole = null;
    _filterStatus = null;
    _sortBy = 'created_at';
    _sortDirection = 'desc';
    await loadUsers();
  }

  // ============================================
  // CRUD
  // ============================================

  Future<bool> createUser(AdminUser user) async {
    _status = AdminUserStatus2.updating;
    notifyListeners();

    try {
      final created = await _repository.createUser(user);
      _users.insert(0, _normalizeUser(created));
      _status = AdminUserStatus2.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminUserStatus2.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUser(AdminUser user) async {
    _status = AdminUserStatus2.updating;
    notifyListeners();

    try {
      final updated = await _repository.updateUser(user);
      final index = _users.indexWhere((u) => u.id == updated.id);
      if (index != -1) {
        _users[index] = _normalizeUser(updated);
      }
      if (_currentUser?.id == updated.id) {
        _currentUser = _normalizeUser(updated);
      }
      _status = AdminUserStatus2.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminUserStatus2.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(int id) async {
    try {
      final success = await _repository.deleteUser(id);
      if (success) {
        _users.removeWhere((u) => u.id == id);
        _selectedUserIds.remove(id);
        if (_currentUser?.id == id) {
          _currentUser = null;
        }
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // GESTION DES RÔLES
  // ============================================

  Future<bool> changeUserRole(int userId, AdminUserRole newRole) async {
    _status = AdminUserStatus2.updating;
    notifyListeners();

    try {
      final success = await _repository.changeUserRole(userId, newRole);
      if (success) {
        // Recharger le détail si on est dessus
        if (_currentUser?.id == userId) {
          await loadUserDetail(userId);
        } else {
          final index = _users.indexWhere((u) => u.id == userId);
          if (index != -1) {
            _users[index] = _users[index].copyWith(roles: [newRole]);
          }
        }
        _status = AdminUserStatus2.loaded;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminUserStatus2.error;
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // GESTION DES STATUTS
  // ============================================

  Future<bool> activateUser(int id) async {
    _status = AdminUserStatus2.updating;
    notifyListeners();

    try {
      final success = await _repository.activateUser(id);
      if (success) {
        await _reloadUserOrList(id, AdminUserStatus.active);
      }
      _status = AdminUserStatus2.loaded;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminUserStatus2.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deactivateUser(int id) async {
    _status = AdminUserStatus2.updating;
    notifyListeners();

    try {
      final success = await _repository.deactivateUser(id);
      if (success) {
        await _reloadUserOrList(id, AdminUserStatus.inactive);
      }
      _status = AdminUserStatus2.loaded;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminUserStatus2.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> banUser(int id, {String? reason}) async {
    _status = AdminUserStatus2.updating;
    notifyListeners();

    try {
      final success = await _repository.banUser(id, reason: reason);
      if (success) {
        await _reloadUserOrList(id, AdminUserStatus.banned);
      }
      _status = AdminUserStatus2.loaded;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminUserStatus2.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> suspendUser(
    int id, {
    Duration duration = const Duration(days: 7),
  }) async {
    _status = AdminUserStatus2.updating;
    notifyListeners();

    try {
      final success = await _repository.suspendUser(id, duration: duration);
      if (success) {
        await _reloadUserOrList(id, AdminUserStatus.suspended);
      }
      _status = AdminUserStatus2.loaded;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminUserStatus2.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> unsuspendUser(int id) async {
  _status = AdminUserStatus2.updating;
  notifyListeners();

  try {
    final success = await _repository.unsuspendUser(id);
    if (success) {
      await _reloadUserOrList(id, AdminUserStatus.active);
    }
    _status = AdminUserStatus2.loaded;
    notifyListeners();
    return success;
  } catch (e) {
    _errorMessage = e.toString();
    _status = AdminUserStatus2.error;   // ✅ CORRIGÉ
    notifyListeners();
    return false;
  }
}
  // ============================================
  // SÉLECTION
  // ============================================

  void toggleSelection(int userId) {
    if (_selectedUserIds.contains(userId)) {
      _selectedUserIds.remove(userId);
    } else {
      _selectedUserIds.add(userId);
    }
    notifyListeners();
  }

  void selectAll() {
    _selectedUserIds.clear();
    _selectedUserIds.addAll(_users.map((u) => u.id));
    notifyListeners();
  }

  void clearSelection() {
    _selectedUserIds.clear();
    notifyListeners();
  }

  bool isSelected(int userId) => _selectedUserIds.contains(userId);

  // ============================================
  // HELPERS PRIVÉS
  // ============================================

  /// Normalise un utilisateur (conversion AdminUserModel → AdminUser).
  AdminUser _normalizeUser(AdminUser user) {
    if (user is AdminUserModel) {
      return AdminUser(
        id: user.id,
        name: user.name,
        email: user.email,
        avatar: user.avatar,
        emailVerifiedAt: user.emailVerifiedAt,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
        firstName: user.firstName,
        lastName: user.lastName,
        phone: user.phone,
        birthDate: user.birthDate,
        gender: user.gender,
        country: user.country,
        city: user.city,
        address: user.address,
        language: user.language,
        currency: user.currency,
        roles: user.roles,
        permissions: user.permissions,
        status: user.status,
        isActive: user.isActive,
        isVerified: user.isVerified,
        totalOrders: user.totalOrders,
        totalSpent: user.totalSpent,
        favoritesCount: user.favoritesCount,
        reviewsCount: user.reviewsCount,
        lastLoginAt: user.lastLoginAt,
        lastActivityAt: user.lastActivityAt,
        newsletterSubscribed: user.newsletterSubscribed,
        smsNotifications: user.smsNotifications,
        pushNotifications: user.pushNotifications,
      );
    }
    return user;
  }

  /// Recharge l'utilisateur courant OU met à jour la liste locale.
  Future<void> _reloadUserOrList(int id, AdminUserStatus status) async {
    if (_currentUser?.id == id) {
      await loadUserDetail(id);
    } else {
      _updateUserStatus(id, status);
    }
  }

  void _updateUserStatus(int userId, AdminUserStatus status) {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _users[index] = _users[index].copyWith(status: status);
      notifyListeners();
    }
  }

  // ============================================
  // RÉINITIALISATION
  // ============================================

  void reset() {
    _status = AdminUserStatus2.initial;
    _users = [];
    _errorMessage = null;
    _currentPage = 1;
    _hasMore = true;
    _totalUsers = 0;
    _searchQuery = null;
    _filterRole = null;
    _filterStatus = null;
    _selectedUserIds.clear();
    _currentUser = null;
    _currentUserJson = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  String toString() {
    return 'AdminUserProvider(status: $_status, users: ${_users.length}, '
        'page: $_currentPage, hasMore: $_hasMore, '
        'selected: ${_selectedUserIds.length}, '
        'current: ${_currentUser?.id ?? 'none'})';
  }
}