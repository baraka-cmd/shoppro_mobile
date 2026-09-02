// ============================================
// PROVIDER : AdminUserProvider
// ============================================
// Provider de gestion d'état pour la gestion des utilisateurs.
// Utilise ChangeNotifier pour notifier les widgets des changements.
//
// Responsabilités :
// - Chargement des utilisateurs paginés
// - Recherche et filtrage
// - CRUD complet
// - Gestion des rôles et statuts
// - Actions en masse
// ============================================

// ============================================
// IMPORTS
// ============================================

// Flutter
import 'package:flutter/material.dart';

// Entities (même feature admin)
import '../../domain/entities/admin_user.dart';

// Repositories (même feature admin)
import '../../domain/repositories/admin_user_repository.dart';

// Repositories Impl (même feature admin)
import '../../data/repositories/admin_user_repository_impl.dart';
import '../../data/models/admin_user_model.dart';
// ============================================
// ENUM D'ÉTAT
// ============================================

/// États possibles du provider utilisateurs
enum AdminUserStatus2 {
  initial,
  loading,
  loaded,
  loadingMore,
  updating,
  error,
}

// ============================================
// CLASSE PRINCIPALE
// ============================================

/// Provider de gestion des utilisateurs administrés.
///
/// Gère :
/// - La liste paginée des utilisateurs
/// - La recherche et les filtres
/// - Les opérations CRUD
/// - Les changements de rôle et statut
class AdminUserProvider extends ChangeNotifier {
  // ============================================
  // DÉPENDANCES
  // ============================================

  final AdminUserRepository _repository;

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

  // Filtres
  String? _searchQuery;
  AdminUserRole? _filterRole;
  AdminUserStatus? _filterStatus;
  String _sortBy = 'created_at';
  String _sortDirection = 'desc';

  // Sélection pour actions en masse
  final Set<int> _selectedUserIds = {};

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  AdminUserProvider({AdminUserRepository? repository})
      : _repository = repository ?? AdminUserRepositoryImpl();

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
  bool get isUpdating => _status == AdminUserStatus2.updating;
  bool get hasError => _status == AdminUserStatus2.error;

  /// Nombre d'utilisateurs chargés
  int get usersCount => _users.length;

  /// Vrai si la liste est vide
  bool get isEmpty => _users.isEmpty;

  /// Vrai si des utilisateurs sont sélectionnés
  bool get hasSelection => _selectedUserIds.isNotEmpty;

  /// Nombre d'utilisateurs sélectionnés
  int get selectedCount => _selectedUserIds.length;

  /// IDs sélectionnés
  List<int> get selectedUserIds => List.unmodifiable(_selectedUserIds);

  /// Filtres actuels
  String? get searchQuery => _searchQuery;
  AdminUserRole? get filterRole => _filterRole;
  AdminUserStatus? get filterStatus => _filterStatus;

  // ============================================
  // ACTIONS PRINCIPALES
  // ============================================

  /// Charge la première page des utilisateurs.
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

    // ✅ CONVERSION : Si users est List<AdminUserModel>, convertir en List<AdminUser>
    _users = users.map((user) {
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
    }).toList();

    _hasMore = users.length >= _perPage;
    _status = AdminUserStatus2.loaded;
  } catch (e) {
    _errorMessage = e.toString();
    _status = AdminUserStatus2.error;
    debugPrint('Erreur loadUsers: $e');
  }

  notifyListeners();
}

  /// Charge la page suivante (pagination).
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
        _users = [..._users, ...users];
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

  /// Rafraîchit la liste sans loader complet.
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

      _users = users;
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
  // RECHERCHE ET FILTRES
  // ============================================

  /// Recherche des utilisateurs.
  Future<void> search(String query) async {
    _searchQuery = query.trim().isEmpty ? null : query.trim();
    await loadUsers();
  }

  /// Filtre par rôle.
  Future<void> filterByRole(AdminUserRole? role) async {
    _filterRole = role;
    await loadUsers();
  }

  /// Filtre par statut.
  Future<void> filterByStatus(AdminUserStatus? status) async {
    _filterStatus = status;
    await loadUsers();
  }

  /// Trie les résultats.
  Future<void> sort(String sortBy, {String direction = 'asc'}) async {
    _sortBy = sortBy;
    _sortDirection = direction;
    await loadUsers();
  }

  /// Efface tous les filtres.
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

  /// Crée un nouvel utilisateur.
  Future<bool> createUser(AdminUser user) async {
    _status = AdminUserStatus2.updating;
    notifyListeners();

    try {
      final created = await _repository.createUser(user);
      _users.insert(0, created);
      _status = AdminUserStatus2.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminUserStatus2.error;
      debugPrint('Erreur createUser: $e');
      notifyListeners();
      return false;
    }
  }

  /// Met à jour un utilisateur.
  Future<bool> updateUser(AdminUser user) async {
    _status = AdminUserStatus2.updating;
    notifyListeners();

    try {
      final updated = await _repository.updateUser(user);
      final index = _users.indexWhere((u) => u.id == updated.id);
      if (index != -1) {
        _users[index] = updated;
      }
      _status = AdminUserStatus2.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminUserStatus2.error;
      debugPrint('Erreur updateUser: $e');
      notifyListeners();
      return false;
    }
  }

  /// Supprime un utilisateur.
  Future<bool> deleteUser(int id) async {
    try {
      final success = await _repository.deleteUser(id);
      if (success) {
        _users.removeWhere((u) => u.id == id);
        _selectedUserIds.remove(id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Erreur deleteUser: $e');
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // GESTION DES RÔLES
  // ============================================

  /// Change le rôle d'un utilisateur.
  Future<bool> changeUserRole(int userId, AdminUserRole newRole) async {
    try {
      final success = await _repository.changeUserRole(userId, newRole);
      if (success) {
        final index = _users.indexWhere((u) => u.id == userId);
        if (index != -1) {
          _users[index] = _users[index].copyWith(roles: [newRole]);
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Erreur changeUserRole: $e');
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // GESTION DES STATUTS
  // ============================================

  /// Active un utilisateur.
  Future<bool> activateUser(int id) async {
    try {
      final success = await _repository.activateUser(id);
      if (success) {
        _updateUserStatus(id, AdminUserStatus.active);
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Désactive un utilisateur.
  Future<bool> deactivateUser(int id) async {
    try {
      final success = await _repository.deactivateUser(id);
      if (success) {
        _updateUserStatus(id, AdminUserStatus.inactive);
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Bannit un utilisateur.
  Future<bool> banUser(int id, {String? reason}) async {
    try {
      final success = await _repository.banUser(id, reason: reason);
      if (success) {
        _updateUserStatus(id, AdminUserStatus.banned);
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Suspend un utilisateur.
  Future<bool> suspendUser(int id, {Duration duration = const Duration(days: 7)}) async {
    try {
      final success = await _repository.suspendUser(id, duration: duration);
      if (success) {
        _updateUserStatus(id, AdminUserStatus.suspended);
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // SÉLECTION POUR ACTIONS EN MASSE
  // ============================================

  /// Sélectionne/désélectionne un utilisateur.
  void toggleSelection(int userId) {
    if (_selectedUserIds.contains(userId)) {
      _selectedUserIds.remove(userId);
    } else {
      _selectedUserIds.add(userId);
    }
    notifyListeners();
  }

  /// Sélectionne tous les utilisateurs visibles.
  void selectAll() {
    _selectedUserIds.clear();
    _selectedUserIds.addAll(_users.map((u) => u.id));
    notifyListeners();
  }

  /// Désélectionne tous les utilisateurs.
  void clearSelection() {
    _selectedUserIds.clear();
    notifyListeners();
  }

  /// Vérifie si un utilisateur est sélectionné.
  bool isSelected(int userId) => _selectedUserIds.contains(userId);

  // ============================================
  // ACTIONS EN MASSE
  // ============================================

  /// Active les utilisateurs sélectionnés.
  Future<int> bulkActivateSelected() async {
    final count = await _repository.bulkActivateUsers(selectedUserIds);
    _selectedUserIds.clear();
    await refreshUsers();
    return count;
  }

  /// Désactive les utilisateurs sélectionnés.
  Future<int> bulkDeactivateSelected() async {
    final count = await _repository.bulkDeactivateUsers(selectedUserIds);
    _selectedUserIds.clear();
    await refreshUsers();
    return count;
  }

  /// Supprime les utilisateurs sélectionnés.
  Future<int> bulkDeleteSelected() async {
    final count = await _repository.bulkDeleteUsers(selectedUserIds);
    _selectedUserIds.clear();
    await refreshUsers();
    return count;
  }

  // ============================================
  // HELPERS PRIVÉS
  // ============================================

  /// Met à jour le statut d'un utilisateur dans la liste.
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

  /// Réinitialise le provider.
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
    notifyListeners();
  }

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'AdminUserProvider(status: $_status, users: ${_users.length}, '
        'page: $_currentPage, hasMore: $_hasMore, selected: ${_selectedUserIds.length})';
  }
}