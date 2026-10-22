// ============================================
// PROVIDER : SellerNotificationProvider
// ============================================
// Gestion d'état pour les notifications vendeur.
//
// Responsabilités :
//   - Charger les notifications avec filtres (all, unread, read)
//   - Marquer une notification comme lue
//   - Marquer toutes les notifications comme lues
//   - Compter les non lues (badge)
//   - Supprimer une notification
//   - Gérer la pagination infinie
//
// Pattern :
//   - ChangeNotifier (Provider)
//   - États via enums
//   - Cache local
// ============================================

// Flutter
import 'package:flutter/foundation.dart';

// Domain
import '../../domain/entities/seller_notification.dart';

// Data
import '../../data/sources/seller_notification_api.dart';

// ============================================
// ENUMS
// ============================================

enum SellerNotificationListStatus {
  initial,
  loading,
  loaded,
  loadingMore,
  error,
  unauthorized,
}

enum SellerNotificationActionStatus {
  idle,
  marking,
  markingAll,
  deleting,
  error,
}

// ============================================
// FILTRES
// ============================================

enum SellerNotificationFilter {
  all('all', 'Toutes'),
  unread('unread', 'Non lues'),
  read('read', 'Lues');

  final String code;
  final String label;

  const SellerNotificationFilter(this.code, this.label);
}

// ============================================
// PROVIDER PRINCIPAL
// ============================================

class SellerNotificationProvider extends ChangeNotifier {
  final SellerNotificationApi _api;

  SellerNotificationProvider({SellerNotificationApi? api})
      : _api = api ?? SellerNotificationApi();

  // ============================================
  // ÉTAT : LISTE
  // ============================================

  SellerNotificationListStatus _listStatus =
      SellerNotificationListStatus.initial;
  List<SellerNotification> _notifications = [];
  String? _listError;

  // Pagination
  int _currentPage = 1;
  int _lastPage = 1;
  int _total = 0;
  bool _hasMore = false;
  int _perPage = 20;

  // Filtre actif
  SellerNotificationFilter _filter = SellerNotificationFilter.all;

  // Stats
  SellerNotificationsStats _stats = const SellerNotificationsStats.empty();

  // ============================================
  // ÉTAT : ACTION
  // ============================================

  SellerNotificationActionStatus _actionStatus =
      SellerNotificationActionStatus.idle;
  String? _actionError;
  String? _lastAffectedId;

  // ============================================
  // GETTERS : LISTE
  // ============================================

  SellerNotificationListStatus get listStatus => _listStatus;
  List<SellerNotification> get notifications =>
      List.unmodifiable(_notifications);
  String? get listError => _listError;

  bool get isLoading => _listStatus == SellerNotificationListStatus.loading;
  bool get isLoaded => _listStatus == SellerNotificationListStatus.loaded;
  bool get isLoadingMore =>
      _listStatus == SellerNotificationListStatus.loadingMore;
  bool get hasError => _listStatus == SellerNotificationListStatus.error;
  bool get isUnauthorized =>
      _listStatus == SellerNotificationListStatus.unauthorized;

  bool get isEmpty => _notifications.isEmpty;
  int get notificationsCount => _notifications.length;
  int get total => _total;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  bool get hasMore => _hasMore;

  SellerNotificationFilter get filter => _filter;

  // ============================================
  // GETTERS : STATS
  // ============================================

  SellerNotificationsStats get stats => _stats;
  int get totalCount => _stats.total;
  int get unreadCount => _stats.unread;
  int get readCount => _stats.read;

  bool get hasUnread => _stats.hasUnread;

  /// Label du badge (ex: "99+").
  String get badgeLabel => _stats.badgeLabel;

  // ============================================
  // GETTERS : ACTION
  // ============================================

  SellerNotificationActionStatus get actionStatus => _actionStatus;
  String? get actionError => _actionError;
  String? get lastAffectedId => _lastAffectedId;

  bool get isMarking => _actionStatus == SellerNotificationActionStatus.marking;
  bool get isMarkingAll =>
      _actionStatus == SellerNotificationActionStatus.markingAll;
  bool get isDeleting =>
      _actionStatus == SellerNotificationActionStatus.deleting;
  bool get hasActionError =>
      _actionStatus == SellerNotificationActionStatus.error;

  bool get isPerformingAction =>
      _actionStatus != SellerNotificationActionStatus.idle &&
      _actionStatus != SellerNotificationActionStatus.error;

  // ============================================
  // CHARGEMENT
  // ============================================

  /// Charge la première page.
  Future<void> loadNotifications({bool forceRefresh = false}) async {
    if (isLoading && !forceRefresh) return;

    _listStatus = SellerNotificationListStatus.loading;
    _listError = null;
    _currentPage = 1;
    notifyListeners();

    try {
      final result = await _api.getNotifications(
        page: 1,
        perPage: _perPage,
        filter: _filter.code,
      );

      _notifications = result.notifications;
      _stats = result.stats;
      _currentPage = result.currentPage;
      _lastPage = result.lastPage;
      _total = result.total;
      _hasMore = result.hasMore;
      _listStatus = SellerNotificationListStatus.loaded;
    } on SellerNotificationUnauthorizedException catch (e) {
      _listStatus = SellerNotificationListStatus.unauthorized;
      _listError = e.message;
    } catch (e) {
      _listStatus = SellerNotificationListStatus.error;
      _listError = e.toString().replaceFirst('Exception: ', '');
    }

    notifyListeners();
  }

  /// Charge la page suivante.
  Future<void> loadMore() async {
    if (isLoadingMore || !_hasMore) return;

    _listStatus = SellerNotificationListStatus.loadingMore;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final result = await _api.getNotifications(
        page: nextPage,
        perPage: _perPage,
        filter: _filter.code,
      );

      _notifications = [..._notifications, ...result.notifications];
      _stats = result.stats;
      _currentPage = result.currentPage;
      _total = result.total;
      _hasMore = result.hasMore;
      _listStatus = SellerNotificationListStatus.loaded;
    } catch (e) {
      _listStatus = SellerNotificationListStatus.error;
      _listError = e.toString().replaceFirst('Exception: ', '');
    }

    notifyListeners();
  }

  /// Rafraîchit la liste.
  Future<void> refresh() async {
    await loadNotifications(forceRefresh: true);
  }

  // ============================================
  // FILTRES
  // ============================================

  /// Change le filtre.
  Future<void> setFilter(SellerNotificationFilter newFilter) async {
    if (_filter == newFilter) return;
    _filter = newFilter;
    _notifications = [];
    await loadNotifications();
  }

  // ============================================
  // ACTIONS
  // ============================================

  /// Marque une notification comme lue.
  Future<bool> markAsRead(String notificationId) async {
    // Vérifier si déjà lue
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && _notifications[index].isRead) {
      return true; // Déjà lue
    }

    _actionStatus = SellerNotificationActionStatus.marking;
    _actionError = null;
    _lastAffectedId = notificationId;
    notifyListeners();

    try {
      final unreadCount = await _api.markAsRead(notificationId);

      // Mettre à jour localement
      if (index != -1) {
        final newList = List<SellerNotification>.from(_notifications);
        newList[index] = newList[index].copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );
        _notifications = newList;
      }

      // Mettre à jour les stats
      _stats = SellerNotificationsStats(
        total: _stats.total,
        unread: unreadCount,
        read: _stats.total - unreadCount,
      );

      _actionStatus = SellerNotificationActionStatus.idle;
      notifyListeners();
      return true;
    } catch (e) {
      _actionStatus = SellerNotificationActionStatus.error;
      _actionError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Marque toutes les notifications comme lues.
  Future<bool> markAllAsRead() async {
    if (_stats.unread == 0) return true;

    _actionStatus = SellerNotificationActionStatus.markingAll;
    _actionError = null;
    notifyListeners();

    try {
      final result = await _api.markAllAsRead();

      // Mettre à jour localement toutes les notifications
      final now = DateTime.now();
      _notifications = _notifications.map((n) {
        if (!n.isRead) {
          return n.copyWith(isRead: true, readAt: now);
        }
        return n;
      }).toList();

      // Mettre à jour les stats
      _stats = SellerNotificationsStats(
        total: _stats.total,
        unread: result.unreadCount,
        read: _stats.total - result.unreadCount,
      );

      _actionStatus = SellerNotificationActionStatus.idle;
      notifyListeners();
      return true;
    } catch (e) {
      _actionStatus = SellerNotificationActionStatus.error;
      _actionError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Supprime une notification.
  Future<bool> deleteNotification(String notificationId) async {
    _actionStatus = SellerNotificationActionStatus.deleting;
    _actionError = null;
    _lastAffectedId = notificationId;
    notifyListeners();

    try {
      await _api.deleteNotification(notificationId);

      // Retirer de la liste locale
      final wasUnread = _notifications
          .firstWhere(
            (n) => n.id == notificationId,
            orElse: () => _notifications.first,
          )
          .isUnread;

      _notifications =
          _notifications.where((n) => n.id != notificationId).toList();

      // Mettre à jour les stats
      _stats = SellerNotificationsStats(
        total: _stats.total - 1,
        unread: wasUnread ? _stats.unread - 1 : _stats.unread,
        read: wasUnread ? _stats.read : _stats.read - 1,
      );

      _actionStatus = SellerNotificationActionStatus.idle;
      notifyListeners();
      return true;
    } catch (e) {
      _actionStatus = SellerNotificationActionStatus.error;
      _actionError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // RAFRAÎCHISSEMENT DU COMPTEUR
  // ============================================

  /// Rafraîchit le compteur de non lues (pour le badge AppBar).
  Future<void> refreshUnreadCount() async {
    try {
      final unreadCount = await _api.getUnreadCount();
      _stats = SellerNotificationsStats(
        total: _stats.total,
        unread: unreadCount,
        read: _stats.total - unreadCount,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('⚠️ Impossible de rafraîchir le compteur: $e');
    }
  }

  // ============================================
  // RESET / CLEAR
  // ============================================

  /// Efface les erreurs.
  void clearErrors() {
    _listError = null;
    _actionError = null;
    _lastAffectedId = null;

    if (_listStatus == SellerNotificationListStatus.error) {
      _listStatus = _notifications.isNotEmpty
          ? SellerNotificationListStatus.loaded
          : SellerNotificationListStatus.initial;
    }

    if (_actionStatus == SellerNotificationActionStatus.error) {
      _actionStatus = SellerNotificationActionStatus.idle;
    }

    notifyListeners();
  }

  /// Réinitialise complètement le provider.
  void reset() {
    _listStatus = SellerNotificationListStatus.initial;
    _actionStatus = SellerNotificationActionStatus.idle;
    _notifications = [];
    _listError = null;
    _actionError = null;
    _lastAffectedId = null;
    _filter = SellerNotificationFilter.all;
    _currentPage = 1;
    _lastPage = 1;
    _total = 0;
    _hasMore = false;
    _stats = const SellerNotificationsStats.empty();
    notifyListeners();
  }

  @override
  String toString() {
    return 'SellerNotificationProvider(filter: ${_filter.label}, '
        'count: ${_notifications.length}, unread: $unreadCount)';
  }
}