// ============================================
// PROVIDER : AdminOrderProvider
// ============================================
// Provider de gestion d'état pour la gestion des commandes.
// Utilise ChangeNotifier pour notifier les widgets des changements.
//
// Responsabilités :
// - Chargement des commandes paginées
// - Recherche et filtrage
// - Changement de statut
// - Gestion des paiements
// - Statistiques
// ============================================

// ============================================
// IMPORTS
// ============================================

// Flutter
import 'package:flutter/material.dart';

// Entities (autres features)
import '../../../orders/domain/entities/order.dart';

// Repositories (même feature admin)
import '../../domain/repositories/admin_order_repository.dart';

// Repositories Impl (même feature admin)
import '../../data/repositories/admin_order_repository_impl.dart';

// ============================================
// ENUM D'ÉTAT
// ============================================

/// États possibles du provider commandes
enum AdminOrderStatus2 {
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

/// Provider de gestion des commandes administrées.
///
/// Gère :
/// - La liste paginée des commandes
/// - Les changements de statut
/// - La gestion des paiements
/// - Les statistiques
class AdminOrderProvider extends ChangeNotifier {
  // ============================================
  // DÉPENDANCES
  // ============================================

  final AdminOrderRepository _repository;

  // ============================================
  // ÉTAT
  // ============================================

  AdminOrderStatus2 _status = AdminOrderStatus2.initial;
  List<Order> _orders = [];
  String? _errorMessage;
  int _currentPage = 1;
  int _perPage = 20;
  bool _hasMore = true;

  // Filtres
  String? _filterStatus;
  String? _filterPaymentStatus;
  String? _searchQuery;
  String _sortBy = 'created_at';
  String _sortDirection = 'desc';

  // Sélection
  final Set<int> _selectedIds = {};

  // Statistiques
  Map<String, int> _statusCounts = {};
  Map<String, int> _paymentStatusCounts = {};
  double _totalRevenue = 0;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  AdminOrderProvider({AdminOrderRepository? repository})
      : _repository = repository ?? AdminOrderRepositoryImpl();

  // ============================================
  // GETTERS
  // ============================================

  AdminOrderStatus2 get status => _status;
  List<Order> get orders => List.unmodifiable(_orders);
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get perPage => _perPage;
  bool get hasMore => _hasMore;
  bool get isLoading => _status == AdminOrderStatus2.loading;
  bool get isLoaded => _status == AdminOrderStatus2.loaded;
  bool get isLoadingMore => _status == AdminOrderStatus2.loadingMore;
  bool get isUpdating => _status == AdminOrderStatus2.updating;
  bool get hasError => _status == AdminOrderStatus2.error;
  int get ordersCount => _orders.length;
  bool get isEmpty => _orders.isEmpty;
  bool get hasSelection => _selectedIds.isNotEmpty;
  int get selectedCount => _selectedIds.length;
  List<int> get selectedIds => List.unmodifiable(_selectedIds);
  Map<String, int> get statusCounts => Map.unmodifiable(_statusCounts);
  Map<String, int> get paymentStatusCounts => Map.unmodifiable(_paymentStatusCounts);
  double get totalRevenue => _totalRevenue;

  String? get filterStatus => _filterStatus;
  String? get filterPaymentStatus => _filterPaymentStatus;

  /// Commandes en attente
  List<Order> get pendingOrders =>
      _orders.where((o) => o.status == 'pending').toList();

  /// Commandes confirmées
  List<Order> get confirmedOrders =>
      _orders.where((o) => o.status == 'confirmed').toList();

  /// Commandes en traitement
  List<Order> get processingOrders =>
      _orders.where((o) => o.status == 'processing').toList();

  /// Commandes expédiées
  List<Order> get shippedOrders =>
      _orders.where((o) => o.status == 'shipped').toList();

  /// Commandes livrées
  List<Order> get deliveredOrders =>
      _orders.where((o) => o.status == 'delivered').toList();

  /// Commandes annulées
  List<Order> get cancelledOrders =>
      _orders.where((o) => o.status == 'cancelled').toList();

  /// Nombre de commandes en attente
  int get pendingCount => pendingOrders.length;

  /// Nombre de commandes livrées
  int get deliveredCount => deliveredOrders.length;

  // ============================================
  // ACTIONS PRINCIPALES
  // ============================================

  /// Charge la première page des commandes.
  Future<void> loadOrders() async {
    _status = AdminOrderStatus2.loading;
    _errorMessage = null;
    _currentPage = 1;
    notifyListeners();

    try {
      final orders = await _repository.getOrders(
        page: _currentPage,
        perPage: _perPage,
        status: _filterStatus,
        paymentStatus: _filterPaymentStatus,
        searchQuery: _searchQuery,
        sortBy: _sortBy,
        sortDirection: _sortDirection,
      );

      _orders = orders;
      _hasMore = orders.length >= _perPage;
      _status = AdminOrderStatus2.loaded;
      await _loadStatistics();
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminOrderStatus2.error;
      debugPrint('Erreur loadOrders: $e');
    }

    notifyListeners();
  }

  /// Charge la page suivante.
  Future<void> loadMoreOrders() async {
    if (_status == AdminOrderStatus2.loadingMore || !_hasMore) return;

    _status = AdminOrderStatus2.loadingMore;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final orders = await _repository.getOrders(
        page: nextPage,
        perPage: _perPage,
        status: _filterStatus,
        paymentStatus: _filterPaymentStatus,
        searchQuery: _searchQuery,
        sortBy: _sortBy,
        sortDirection: _sortDirection,
      );

      if (orders.isEmpty) {
        _hasMore = false;
      } else {
        _orders = [..._orders, ...orders];
        _currentPage = nextPage;
        _hasMore = orders.length >= _perPage;
      }

      _status = AdminOrderStatus2.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminOrderStatus2.error;
      debugPrint('Erreur loadMoreOrders: $e');
    }

    notifyListeners();
  }

  /// Rafraîchit sans loader.
  Future<void> refreshOrders() async {
    try {
      final orders = await _repository.getOrders(
        page: 1,
        perPage: _perPage,
        status: _filterStatus,
        paymentStatus: _filterPaymentStatus,
        searchQuery: _searchQuery,
        sortBy: _sortBy,
        sortDirection: _sortDirection,
      );

      _orders = orders;
      _currentPage = 1;
      _hasMore = orders.length >= _perPage;
      _status = AdminOrderStatus2.loaded;
      await _loadStatistics();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Erreur refreshOrders: $e');
    }

    notifyListeners();
  }

  // ============================================
  // RECHERCHE ET FILTRES
  // ============================================

  /// Recherche des commandes.
  Future<void> search(String query) async {
    _searchQuery = query.trim().isEmpty ? null : query.trim();
    await loadOrders();
  }

  /// Filtre par statut.
  Future<void> filterByStatus(String? status) async {
    _filterStatus = status;
    await loadOrders();
  }

  /// Filtre par statut de paiement.
  Future<void> filterByPaymentStatus(String? status) async {
    _filterPaymentStatus = status;
    await loadOrders();
  }

  /// Trie les résultats.
  Future<void> sort(String sortBy, {String direction = 'asc'}) async {
    _sortBy = sortBy;
    _sortDirection = direction;
    await loadOrders();
  }

  /// Efface les filtres.
  Future<void> clearFilters() async {
    _filterStatus = null;
    _filterPaymentStatus = null;
    _searchQuery = null;
    _sortBy = 'created_at';
    _sortDirection = 'desc';
    await loadOrders();
  }

  // ============================================
  // CHANGEMENT DE STATUT
  // ============================================

  /// Confirme une commande.
  Future<bool> confirmOrder(int orderId) async {
    _status = AdminOrderStatus2.updating;
    notifyListeners();

    try {
      final success = await _repository.confirmOrder(orderId);
      if (success) {
        _updateOrderStatus(orderId, 'confirmed');
      }
      _status = AdminOrderStatus2.loaded;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminOrderStatus2.error;
      debugPrint('Erreur confirmOrder: $e');
      notifyListeners();
      return false;
    }
  }

  /// Marque comme en traitement.
  Future<bool> processOrder(int orderId) async {
    try {
      final success = await _repository.processOrder(orderId);
      if (success) {
        _updateOrderStatus(orderId, 'processing');
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Expédie une commande.
  Future<bool> shipOrder(int orderId, {String? trackingNumber, String? carrier}) async {
    try {
      final success = await _repository.shipOrder(
        orderId,
        trackingNumber: trackingNumber,
        carrier: carrier,
      );
      if (success) {
        _updateOrderStatus(orderId, 'shipped');
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Livre une commande.
  Future<bool> deliverOrder(int orderId) async {
    try {
      final success = await _repository.deliverOrder(orderId);
      if (success) {
        _updateOrderStatus(orderId, 'delivered');
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Annule une commande.
  Future<bool> cancelOrder(int orderId, {String? reason}) async {
    try {
      final success = await _repository.cancelOrder(orderId, reason: reason);
      if (success) {
        _updateOrderStatus(orderId, 'cancelled');
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Rembourse une commande.
  Future<bool> refundOrder(int orderId) async {
    try {
      final success = await _repository.refundOrder(orderId);
      if (success) {
        _updateOrderStatus(orderId, 'refunded');
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // PAIEMENT
  // ============================================

  /// Marque le paiement comme reçu.
  Future<bool> markPaymentAsPaid(int orderId) async {
    try {
      return await _repository.markPaymentAsPaid(orderId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Marque le paiement comme échoué.
  Future<bool> markPaymentAsFailed(int orderId) async {
    try {
      return await _repository.markPaymentAsFailed(orderId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Marque le paiement comme remboursé.
  Future<bool> markPaymentAsRefunded(int orderId) async {
    try {
      return await _repository.markPaymentAsRefunded(orderId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // NOTES ADMIN
  // ============================================

  /// Ajoute une note admin.
  Future<bool> addAdminNote(int orderId, String note) async {
    try {
      return await _repository.addAdminNote(orderId, note);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Récupère les notes admin.
  Future<List<Map<String, dynamic>>> getAdminNotes(int orderId) async {
    try {
      return await _repository.getAdminNotes(orderId);
    } catch (e) {
      _errorMessage = e.toString();
      return [];
    }
  }

  // ============================================
  // SÉLECTION
  // ============================================

  /// Toggle la sélection.
  void toggleSelection(int id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }

  /// Sélectionne tout.
  void selectAll() {
    _selectedIds.clear();
    _selectedIds.addAll(_orders.map((o) => o.id));
    notifyListeners();
  }

  /// Efface la sélection.
  void clearSelection() {
    _selectedIds.clear();
    notifyListeners();
  }

  /// Vérifie la sélection.
  bool isSelected(int id) => _selectedIds.contains(id);

  // ============================================
  // HELPERS PRIVÉS
  // ============================================

  /// Met à jour le statut d'une commande dans la liste.
  void _updateOrderStatus(int orderId, String status) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      // Utiliser copyWith si disponible sur Order
      // Sinon recharger la liste
      notifyListeners();
    }
  }

  /// Charge les statistiques des commandes.
  Future<void> _loadStatistics() async {
    try {
      _statusCounts = await _repository.getOrdersCountByStatus();
      _paymentStatusCounts = await _repository.getOrdersCountByPaymentStatus();
      _totalRevenue = await _repository.getTotalRevenue();
    } catch (e) {
      debugPrint('Erreur _loadStatistics: $e');
    }
  }

  // ============================================
  // RÉINITIALISATION
  // ============================================

  /// Réinitialise le provider.
  void reset() {
    _status = AdminOrderStatus2.initial;
    _orders = [];
    _errorMessage = null;
    _currentPage = 1;
    _hasMore = true;
    _filterStatus = null;
    _filterPaymentStatus = null;
    _searchQuery = null;
    _selectedIds.clear();
    _statusCounts = {};
    _paymentStatusCounts = {};
    _totalRevenue = 0;
    notifyListeners();
  }

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'AdminOrderProvider(status: $_status, orders: ${_orders.length}, '
        'pending: $pendingCount, delivered: $deliveredCount, revenue: $_totalRevenue)';
  }
}