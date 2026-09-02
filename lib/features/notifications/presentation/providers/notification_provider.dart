// Provider des notifications
// Gère l'état des notifications et les actions

import 'package:flutter/foundation.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../data/repositories/notification_repository_impl.dart';

enum NotificationStatus {
  initial,
  loading,
  loaded,
  updating,
  error,
}

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _notificationRepository;

  NotificationProvider({NotificationRepository? notificationRepository})
      : _notificationRepository = notificationRepository ?? NotificationRepositoryImpl();

  NotificationStatus _status = NotificationStatus.initial;
  List<AppNotification> _notifications = [];
  String? _errorMessage;

  // Getters
  NotificationStatus get status => _status;
  List<AppNotification> get notifications => _notifications;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == NotificationStatus.loading;
  bool get hasError => _status == NotificationStatus.error;
  bool get isEmpty => _notifications.isEmpty;
  int get totalCount => _notifications.length;

  /// Notifications non lues
  int get unreadCount {
    return _notifications.where((n) => !n.isRead).length;
  }

  /// Notifications par type
  List<AppNotification> getOrderNotifications() =>
      _notifications.where((n) => n.type == 'order').toList();
  List<AppNotification> getPromotionNotifications() =>
      _notifications.where((n) => n.type == 'promotion').toList();
  List<AppNotification> getDeliveryNotifications() =>
      _notifications.where((n) => n.type == 'delivery').toList();
  List<AppNotification> getPriceAlertNotifications() =>
      _notifications.where((n) => n.type == 'price_alert').toList();

  /// Charger les notifications
  Future<void> loadNotifications() async {
    _setStatus(NotificationStatus.loading);
    _clearError();

    try {
      _notifications = await _notificationRepository.getNotifications();
      _setStatus(NotificationStatus.loaded);
    } catch (e) {
      _setError(e.toString());
      _setStatus(NotificationStatus.error);
    }

    notifyListeners();
  }

  /// Ajouter une notification
  Future<bool> addNotification(AppNotification notification) async {
    _setStatus(NotificationStatus.updating);

    try {
      _notifications = await _notificationRepository.addNotification(notification);
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

  /// Marquer comme lue
  Future<bool> markAsRead(int notificationId) async {
    _setStatus(NotificationStatus.updating);

    try {
      _notifications = await _notificationRepository.markAsRead(notificationId);
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

  /// Tout marquer comme lu
  Future<void> markAllAsRead() async {
    await _notificationRepository.markAllAsRead();
    _notifications = await _notificationRepository.getNotifications();
    notifyListeners();
  }

  /// Supprimer une notification
  Future<bool> removeNotification(int notificationId) async {
    _setStatus(NotificationStatus.updating);

    try {
      _notifications = await _notificationRepository.removeNotification(notificationId);
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

  /// Tout effacer
  Future<void> clearAll() async {
    await _notificationRepository.clearAllNotifications();
    _notifications = [];
    notifyListeners();
  }

  /// Effacer l'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Méthodes privées
  void _setStatus(NotificationStatus newStatus) {
    _status = newStatus;
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setError(String message) {
    _errorMessage = message.replaceFirst('Exception: ', '');
  }
}