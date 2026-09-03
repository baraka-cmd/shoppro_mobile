// ============================================
// PROVIDER DES NOTIFICATIONS - VERSION PREMIUM
// ============================================
// Gère l'état des notifications avec actions
// complètes, filtres et annulation.
// ============================================

import 'package:flutter/foundation.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../data/repositories/notification_repository_impl.dart';

enum NotificationStatus {
  initial,
  loading,
  loaded,
  refreshing,
  updating,
  markingAsRead,
  markingAllAsRead,
  deleting,
  syncing,
  empty,
  error,
}

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _notificationRepository;

  NotificationProvider({NotificationRepository? notificationRepository})
      : _notificationRepository =
            notificationRepository ?? NotificationRepositoryImpl();

  // ============================================
  // ÉTAT
  // ============================================

  NotificationStatus _status = NotificationStatus.initial;
  List<AppNotification> _notifications = [];
  String? _errorMessage;
  int _updatingNotificationId = -1;
  String _currentFilter = 'all';

  // ============================================
  // GETTERS DE BASE
  // ============================================

  NotificationStatus get status => _status;
  List<AppNotification> get notifications => _notifications;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == NotificationStatus.loading;
  bool get isRefreshing => _status == NotificationStatus.refreshing;
  bool get isUpdating => _status == NotificationStatus.updating;
  bool get isSyncing => _status == NotificationStatus.syncing;
  bool get hasError => _status == NotificationStatus.error;
  bool get isEmpty => _notifications.isEmpty;
  int get totalCount => _notifications.length;

  /// ID de la notification en cours de mise à jour
  int get updatingNotificationId => _updatingNotificationId;

  /// Filtre actuel
  String get currentFilter => _currentFilter;

  // ============================================
  // GETTERS DÉRIVÉS
  // ============================================

  /// Notifications non lues
  int get unreadCount {
    return _notifications.where((n) => !n.isRead && !n.isArchived).length;
  }

  /// Notifications non archivées
  List<AppNotification> get activeNotifications {
    return _notifications.where((n) => !n.isArchived).toList();
  }

  /// Notifications archivées
  List<AppNotification> get archivedNotifications {
    return _notifications.where((n) => n.isArchived).toList();
  }

  /// Notifications non lues
  List<AppNotification> get unreadNotifications {
    return _notifications.where((n) => !n.isRead && !n.isArchived).toList();
  }

  /// Notifications filtrées
  List<AppNotification> get filteredNotifications {
    switch (_currentFilter) {
      case 'unread':
        return unreadNotifications;
      case 'order':
        return getOrderNotifications();
      case 'promotion':
        return getPromotionNotifications();
      case 'price_alert':
        return getPriceAlertNotifications();
      case 'stock_alert':
        return getStockAlertNotifications();
      default:
        return activeNotifications;
    }
  }

  /// Notifications par type
  List<AppNotification> getOrderNotifications() =>
      _notifications.where((n) => n.type == AppNotification.typeOrder).toList();

  List<AppNotification> getPromotionNotifications() => _notifications
      .where((n) => n.type == AppNotification.typePromotion)
      .toList();

  List<AppNotification> getDeliveryNotifications() => _notifications
      .where((n) => n.type == AppNotification.typeDelivery)
      .toList();

  List<AppNotification> getPriceAlertNotifications() => _notifications
      .where((n) => n.type == AppNotification.typePriceAlert)
      .toList();

  List<AppNotification> getStockAlertNotifications() => _notifications
      .where((n) => n.type == AppNotification.typeStockAlert)
      .toList();

  List<AppNotification> getSystemNotifications() =>
      _notifications.where((n) => n.type == AppNotification.typeSystem).toList();

  // ============================================
  // CHARGEMENT
  // ============================================

  /// Charger les notifications
  Future<void> loadNotifications() async {
    _setStatus(NotificationStatus.loading);
    _clearError();

    try {
      _notifications = await _notificationRepository.getNotifications();
      _setStatus(_notifications.isEmpty
          ? NotificationStatus.empty
          : NotificationStatus.loaded);
    } catch (e) {
      _setError(e.toString());
      _setStatus(NotificationStatus.error);
    }

    notifyListeners();
  }

  /// Rafraîchir les notifications (silencieux)
  Future<void> refreshNotifications() async {
    _setStatus(NotificationStatus.refreshing);

    try {
      _notifications = await _notificationRepository.getNotifications();
      _setStatus(_notifications.isEmpty
          ? NotificationStatus.empty
          : NotificationStatus.loaded);
    } catch (e) {
      _setError(e.toString());
      _setStatus(NotificationStatus.error);
    }

    notifyListeners();
  }

  /// Synchroniser avec le backend
  Future<void> syncNotifications() async {
    _setStatus(NotificationStatus.syncing);

    try {
      _notifications = await _notificationRepository.syncWithBackend();
      _setStatus(_notifications.isEmpty
          ? NotificationStatus.empty
          : NotificationStatus.loaded);
    } catch (e) {
      _setError(e.toString());
      _setStatus(NotificationStatus.error);
    }

    notifyListeners();
  }

  // ============================================
  // AJOUT
  // ============================================

  /// Ajouter une notification
  Future<bool> addNotification(AppNotification notification) async {
    _setStatus(NotificationStatus.updating);

    try {
      await _notificationRepository.saveNotificationsSnapshot();
      _notifications =
          await _notificationRepository.addNotification(notification);
      _setStatus(NotificationStatus.loaded);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setStatus(NotificationStatus.error);
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // MARQUAGE
  // ============================================

  /// Marquer comme lue
  Future<bool> markAsRead(int notificationId) async {
    _updatingNotificationId = notificationId;
    _setStatus(NotificationStatus.markingAsRead);

    try {
      _notifications =
          await _notificationRepository.markAsRead(notificationId);
      _updatingNotificationId = -1;
      _setStatus(NotificationStatus.loaded);
      notifyListeners();
      return true;
    } catch (e) {
      _updatingNotificationId = -1;
      _setError(e.toString());
      _setStatus(NotificationStatus.error);
      notifyListeners();
      return false;
    }
  }

  /// Marquer comme non lue
  Future<bool> markAsUnread(int notificationId) async {
    _updatingNotificationId = notificationId;

    try {
      _notifications =
          await _notificationRepository.markAsUnread(notificationId);
      _updatingNotificationId = -1;
      notifyListeners();
      return true;
    } catch (e) {
      _updatingNotificationId = -1;
      _setError(e.toString());
      notifyListeners();
      return false;
    }
  }

  /// Tout marquer comme lu
  Future<void> markAllAsRead() async {
    _setStatus(NotificationStatus.markingAllAsRead);

    try {
      await _notificationRepository.markAllAsRead();
      _notifications = await _notificationRepository.getNotifications();
      _setStatus(NotificationStatus.loaded);
    } catch (e) {
      _setError(e.toString());
      _setStatus(NotificationStatus.error);
    }

    notifyListeners();
  }

  // ============================================
  // ARCHIVAGE
  // ============================================

  /// Archiver une notification
  Future<bool> archiveNotification(int notificationId) async {
    _updatingNotificationId = notificationId;

    try {
      _notifications =
          await _notificationRepository.archiveNotification(notificationId);
      _updatingNotificationId = -1;
      notifyListeners();
      return true;
    } catch (e) {
      _updatingNotificationId = -1;
      _setError(e.toString());
      notifyListeners();
      return false;
    }
  }

  /// Désarchiver une notification
  Future<bool> unarchiveNotification(int notificationId) async {
    _updatingNotificationId = notificationId;

    try {
      _notifications =
          await _notificationRepository.unarchiveNotification(notificationId);
      _updatingNotificationId = -1;
      notifyListeners();
      return true;
    } catch (e) {
      _updatingNotificationId = -1;
      _setError(e.toString());
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // SUPPRESSION
  // ============================================

  /// Supprimer une notification
  Future<bool> removeNotification(int notificationId) async {
    _updatingNotificationId = notificationId;
    _setStatus(NotificationStatus.deleting);

    try {
      await _notificationRepository.saveNotificationsSnapshot();
      _notifications =
          await _notificationRepository.removeNotification(notificationId);
      _updatingNotificationId = -1;
      _setStatus(NotificationStatus.loaded);
      notifyListeners();
      return true;
    } catch (e) {
      _updatingNotificationId = -1;
      _setError(e.toString());
      _setStatus(NotificationStatus.error);
      notifyListeners();
      return false;
    }
  }

  /// Tout effacer
  Future<void> clearAll() async {
    await _notificationRepository.clearAllNotifications();
    _notifications = [];
    notifyListeners();
  }

  // ============================================
  // FILTRES
  // ============================================

  /// Changer le filtre
  void setFilter(String filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  /// Effacer le filtre
  void clearFilter() {
    _currentFilter = 'all';
    notifyListeners();
  }

  // ============================================
  // ANNULATION (Undo)
  // ============================================

  /// Annuler la dernière action
  Future<bool> undoLastAction() async {
    try {
      final restored =
          await _notificationRepository.restoreNotificationsSnapshot();
      if (restored != null) {
        _notifications = restored;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ============================================
  // EFFACEMENT
  // ============================================

  /// Effacer l'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ============================================
  // MÉTHODES PRIVÉES
  // ============================================

  void _setStatus(NotificationStatus newStatus) {
    _status = newStatus;
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setError(String message) {
    _errorMessage = message.replaceFirst('Exception: ', '');
  }

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'NotificationProvider(status: $_status, notifications: ${_notifications.length}, '
        'unread: $unreadCount, filter: $_currentFilter, updating: $_updatingNotificationId)';
  }
}