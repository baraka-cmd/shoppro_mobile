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
// - Détails d'une commande (NOUVEAU)
// - Historique d'une commande (NOUVEAU)
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
  loadingDetail,
  updating,
  error,
}

// ============================================
// CLASSE PRINCIPALE
// ============================================

/// Provider de gestion des commandes administrées.
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

  // 🆕 DÉTAIL D'UNE COMMANDE
Order? _currentOrder;
Map<String, dynamic>? _currentOrderJson;   // 👈 NOUVEAU — JSON brut
List<Map<String, dynamic>> _currentOrderHistory = [];
Map<String, dynamic>? _currentOrderTracking;

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
  bool get isLoadingDetail => _status == AdminOrderStatus2.loadingDetail;
  bool get isUpdating => _status == AdminOrderStatus2.updating;
  bool get hasError => _status == AdminOrderStatus2.error;
  int get ordersCount => _orders.length;
  bool get isEmpty => _orders.isEmpty;
  bool get hasSelection => _selectedIds.isNotEmpty;
  int get selectedCount => _selectedIds.length;
  List<int> get selectedIds => List.unmodifiable(_selectedIds);
  Map<String, int> get statusCounts => Map.unmodifiable(_statusCounts);
  Map<String, int> get paymentStatusCounts =>
      Map.unmodifiable(_paymentStatusCounts);
  double get totalRevenue => _totalRevenue;

  // 🆕 Getters détail
  Order? get currentOrder => _currentOrder;
  Map<String, dynamic>? get currentOrderJson => _currentOrderJson;   // 👈 NOUVEAU
  List<Map<String, dynamic>> get currentOrderHistory =>
      List.unmodifiable(_currentOrderHistory);
  Map<String, dynamic>? get currentOrderTracking => _currentOrderTracking;
  bool get hasCurrentOrder => _currentOrder != null;

  String? get filterStatus => _filterStatus;
  String? get filterPaymentStatus => _filterPaymentStatus;

  // ============================================
  // COMMANDES PAR STATUT
  // ============================================

  List<Order> get pendingOrders =>
      _orders.where((o) => o.status == 'pending').toList();
  List<Order> get confirmedOrders =>
      _orders.where((o) => o.status == 'confirmed').toList();
  List<Order> get processingOrders =>
      _orders.where((o) => o.status == 'processing').toList();
  List<Order> get shippedOrders =>
      _orders.where((o) => o.status == 'shipped').toList();
  List<Order> get deliveredOrders =>
      _orders.where((o) => o.status == 'delivered').toList();
  List<Order> get cancelledOrders =>
      _orders.where((o) => o.status == 'cancelled').toList();
  List<Order> get returnedOrders =>
      _orders.where((o) => o.status == 'returned').toList();
  List<Order> get refundedOrders =>
      _orders.where((o) => o.status == 'refunded').toList();

  int get pendingCount => pendingOrders.length;
  int get deliveredCount => deliveredOrders.length;
  int get cancelledCount => cancelledOrders.length;

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
  // 🆕 DÉTAIL D'UNE COMMANDE
  // ============================================

  /// Charge les détails complets d'une commande.
  ///
  /// Charge :
  /// - La commande complète (avec items, adresses, paiements)
  /// - L'historique des statuts
  /// - Le suivi de livraison (si existant)
  Future<void> loadOrderDetail(int orderId) async {
  _status = AdminOrderStatus2.loadingDetail;
  _errorMessage = null;
  _currentOrder = null;
  _currentOrderJson = null;
  _currentOrderHistory = [];
  _currentOrderTracking = null;
  notifyListeners();

  try {
    // 1. Charger la commande
    final order = await _repository.getOrderById(orderId);

    if (order == null) {
      _errorMessage = 'Commande introuvable.';
      _status = AdminOrderStatus2.error;
      notifyListeners();
      return;
    }

    _currentOrder = order;
    // ⚠️ Le JSON brut n'est pas retourné par getOrderById
    // → On va devoir utiliser l'API directement OU enrichir le repo
    // Pour l'instant, on utilise Order + les données qu'il a

    // 2. Charger l'historique
    try {
      _currentOrderHistory = await _repository.getOrderStatusHistory(orderId);
    } catch (e) {
      debugPrint('⚠️ Historique non chargé: $e');
      _currentOrderHistory = [];
    }

    // 3. Charger le tracking
    try {
      _currentOrderTracking = await _repository.getOrderTracking(orderId);
    } catch (e) {
      debugPrint('⚠️ Tracking non chargé: $e');
      _currentOrderTracking = null;
    }

    _status = AdminOrderStatus2.loaded;
  } catch (e) {
    _errorMessage = e.toString();
    _status = AdminOrderStatus2.error;
    debugPrint('Erreur loadOrderDetail: $e');
  }

  notifyListeners();
}

  /// Récupère une commande depuis la liste locale (instantané).
  ///
  /// Utile pour afficher les données de base immédiatement
  /// pendant que le détail complet se charge.
  Order? getOrderById(int orderId) {
    // 1. Vérifier si c'est la commande courante
    if (_currentOrder?.id == orderId) {
      return _currentOrder;
    }

    // 2. Chercher dans la liste
    for (final order in _orders) {
      if (order.id == orderId) {
        return order;
      }
    }

    return null;
  }

  /// Recharge uniquement l'historique d'une commande.
  Future<void> reloadOrderHistory(int orderId) async {
    try {
      final history = await _repository.getOrderStatusHistory(orderId);
      _currentOrderHistory = history;
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur reloadOrderHistory: $e');
    }
  }

  /// Efface le détail courant.
  void clearCurrentOrder() {
  _currentOrder = null;
  _currentOrderJson = null;
  _currentOrderHistory = [];
  _currentOrderTracking = null;
  notifyListeners();
}

  // ============================================
  // RECHERCHE ET FILTRES
  // ============================================

  Future<void> search(String query) async {
    _searchQuery = query.trim().isEmpty ? null : query.trim();
    await loadOrders();
  }

  Future<void> filterByStatus(String? status) async {
    _filterStatus = status;
    await loadOrders();
  }

  Future<void> filterByPaymentStatus(String? status) async {
    _filterPaymentStatus = status;
    await loadOrders();
  }

  Future<void> sort(String sortBy, {String direction = 'asc'}) async {
    _sortBy = sortBy;
    _sortDirection = direction;
    await loadOrders();
  }

  Future<void> clearFilters() async {
    _filterStatus = null;
    _filterPaymentStatus = null;
    _searchQuery = null;
    _sortBy = 'created_at';
    _sortDirection = 'desc';
    await loadOrders();
  }

  // ============================================
  // CHANGEMENT DE STATUT (avec rechargement détail)
  // ============================================

  Future<bool> confirmOrder(int orderId) async {
    _status = AdminOrderStatus2.updating;
    notifyListeners();

    try {
      final success = await _repository.confirmOrder(orderId);
      if (success) {
        // Recharger le détail si on est dessus
        if (_currentOrder?.id == orderId) {
          await loadOrderDetail(orderId);
        }
        // Recharger la liste
        await refreshOrders();
      }
      _status = AdminOrderStatus2.loaded;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminOrderStatus2.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> processOrder(int orderId) async {
    _status = AdminOrderStatus2.updating;
    notifyListeners();

    try {
      final success = await _repository.processOrder(orderId);
      if (success) {
        if (_currentOrder?.id == orderId) {
          await loadOrderDetail(orderId);
        }
        await refreshOrders();
      }
      _status = AdminOrderStatus2.loaded;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminOrderStatus2.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> shipOrder(
    int orderId, {
    String? trackingNumber,
    String? carrier,
  }) async {
    _status = AdminOrderStatus2.updating;
    notifyListeners();

    try {
      final success = await _repository.shipOrder(
        orderId,
        trackingNumber: trackingNumber,
        carrier: carrier,
      );
      if (success) {
        if (_currentOrder?.id == orderId) {
          await loadOrderDetail(orderId);
        }
        await refreshOrders();
      }
      _status = AdminOrderStatus2.loaded;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminOrderStatus2.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deliverOrder(int orderId) async {
    _status = AdminOrderStatus2.updating;
    notifyListeners();

    try {
      final success = await _repository.deliverOrder(orderId);
      if (success) {
        if (_currentOrder?.id == orderId) {
          await loadOrderDetail(orderId);
        }
        await refreshOrders();
      }
      _status = AdminOrderStatus2.loaded;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminOrderStatus2.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelOrder(int orderId, {String? reason}) async {
    _status = AdminOrderStatus2.updating;
    notifyListeners();

    try {
      final success = await _repository.cancelOrder(orderId, reason: reason);
      if (success) {
        if (_currentOrder?.id == orderId) {
          await loadOrderDetail(orderId);
        }
        await refreshOrders();
      }
      _status = AdminOrderStatus2.loaded;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminOrderStatus2.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> refundOrder(int orderId) async {
    _status = AdminOrderStatus2.updating;
    notifyListeners();

    try {
      final success = await _repository.refundOrder(orderId);
      if (success) {
        if (_currentOrder?.id == orderId) {
          await loadOrderDetail(orderId);
        }
        await refreshOrders();
      }
      _status = AdminOrderStatus2.loaded;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminOrderStatus2.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> returnOrder(int orderId, {String? reason}) async {
    _status = AdminOrderStatus2.updating;
    notifyListeners();

    try {
      final success = await _repository.returnOrder(orderId, reason: reason);
      if (success) {
        if (_currentOrder?.id == orderId) {
          await loadOrderDetail(orderId);
        }
        await refreshOrders();
      }
      _status = AdminOrderStatus2.loaded;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminOrderStatus2.error;
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // PAIEMENT
  // ============================================

  Future<bool> markPaymentAsPaid(int orderId) async {
    try {
      final success = await _repository.markPaymentAsPaid(orderId);
      if (success && _currentOrder?.id == orderId) {
        await loadOrderDetail(orderId);
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> markPaymentAsFailed(int orderId) async {
    try {
      final success = await _repository.markPaymentAsFailed(orderId);
      if (success && _currentOrder?.id == orderId) {
        await loadOrderDetail(orderId);
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> markPaymentAsRefunded(int orderId) async {
    try {
      final success = await _repository.markPaymentAsRefunded(orderId);
      if (success && _currentOrder?.id == orderId) {
        await loadOrderDetail(orderId);
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // NOTES ADMIN
  // ============================================

  Future<bool> addAdminNote(int orderId, String note) async {
    try {
      final success = await _repository.addAdminNote(orderId, note);
      if (success && _currentOrder?.id == orderId) {
        await loadOrderDetail(orderId);
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

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

  void toggleSelection(int id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }

  void selectAll() {
    _selectedIds.clear();
    _selectedIds.addAll(_orders.map((o) => o.id));
    notifyListeners();
  }

  void clearSelection() {
    _selectedIds.clear();
    notifyListeners();
  }

  bool isSelected(int id) => _selectedIds.contains(id);

  // ============================================
  // HELPERS PRIVÉS
  // ============================================

  /// Charge les statistiques des commandes.
  Future<void> _loadStatistics() async {
    try {
      _statusCounts = await _repository.getOrdersCountByStatus();
      _paymentStatusCounts =
          await _repository.getOrdersCountByPaymentStatus();
      _totalRevenue = await _repository.getTotalRevenue();
    } catch (e) {
      debugPrint('Erreur _loadStatistics: $e');
    }
  }

  // ============================================
  // RÉINITIALISATION
  // ============================================

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
    _currentOrder = null;
    _currentOrderHistory = [];
    _currentOrderTracking = null;
    notifyListeners();
  }

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'AdminOrderProvider(status: $_status, orders: ${_orders.length}, '
        'pending: $pendingCount, delivered: $deliveredCount, '
        'revenue: $_totalRevenue, current: ${_currentOrder?.id ?? 'none'})';
  }
}