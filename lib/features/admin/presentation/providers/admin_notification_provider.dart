// ============================================
// PROVIDER : AdminNotificationProvider
// ============================================
// Provider de gestion d'état pour les notifications système.
// Utilise ChangeNotifier pour notifier les widgets des changements.
//
// Responsabilités :
// - Chargement des notifications paginées
// - Marquage lu/non lu
// - Archivage
// - Suppression
// - Statistiques
// ============================================

// ============================================
// IMPORTS
// ============================================

// Flutter
import 'package:flutter/material.dart';

// Entities (même feature admin)
import '../../domain/entities/admin_notification.dart';

// Repositories (même feature admin)
import '../../domain/repositories/admin_notification_repository.dart';

// Repositories Impl (même feature admin)
import '../../data/repositories/admin_notification_repository_impl.dart';
import '../../data/models/admin_notification_model.dart';
// ============================================
// ENUM D'ÉTAT
// ============================================

/// États possibles du provider notifications
enum AdminNotificationStatus2 {
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

/// Provider de gestion des notifications système.
///
/// Gère :
/// - La liste paginée des notifications
/// - Le marquage lu/non lu
/// - L'archivage
/// - La suppression
class AdminNotificationProvider extends ChangeNotifier {
  // ============================================
  // DÉPENDANCES
  // ============================================

  final AdminNotificationRepository _repository;

  // ============================================
  // ÉTAT
  // ============================================

  AdminNotificationStatus2 _status = AdminNotificationStatus2.initial;
  List<AdminNotification> _notifications = [];
  String? _errorMessage;
  int _currentPage = 1;
  int _perPage = 20;
  bool _hasMore = true;

  // Filtres
  AdminNotificationType? _filterType;
  AdminNotificationPriority? _filterPriority;
  bool? _filterIsRead;
  bool? _filterIsArchived;

  // Sélection
  final Set<int> _selectedIds = {};

  // Statistiques
  int _totalCount = 0;
  int _unreadCount = 0;
  int _readCount = 0;
  int _archivedCount = 0;
  Map<String, int> _typeCounts = {};
  Map<String, int> _priorityCounts = {};


  // ============================================
  // CONSTRUCTEUR
  // ============================================

  AdminNotificationProvider({AdminNotificationRepository? repository})
      : _repository = repository ?? AdminNotificationRepositoryImpl();

  // ============================================
  // GETTERS
  // ============================================

  AdminNotificationStatus2 get status => _status;
  List<AdminNotification> get notifications => List.unmodifiable(_notifications);
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get perPage => _perPage;
  bool get hasMore => _hasMore;
  bool get isLoading => _status == AdminNotificationStatus2.loading;
  bool get isLoaded => _status == AdminNotificationStatus2.loaded;
  bool get isLoadingMore => _status == AdminNotificationStatus2.loadingMore;
  bool get isUpdating => _status == AdminNotificationStatus2.updating;
  bool get hasError => _status == AdminNotificationStatus2.error;
  int get notificationsCount => _notifications.length;
  bool get isEmpty => _notifications.isEmpty;
  bool get hasSelection => _selectedIds.isNotEmpty;
  int get selectedCount => _selectedIds.length;
  List<int> get selectedIds => List.unmodifiable(_selectedIds);
  int get totalCount => _notifications.length;
int get unreadCount => _notifications.where((n) => n.isRead == false && n.isArchived == false).length;
int get readCount => _notifications.where((n) => n.isRead == true).length;
int get archivedCount => _notifications.where((n) => n.isArchived == true).length;
  Map<String, int> get typeCounts => Map.unmodifiable(_typeCounts);
  Map<String, int> get priorityCounts => Map.unmodifiable(_priorityCounts);
  
bool? get filterIsRead => _filterIsRead;
bool? get filterIsArchived => _filterIsArchived;

  /// Notifications non lues
  List<AdminNotification> get unreadNotifications =>
      _notifications.where((n) => n.isUnread).toList();

  /// Notifications lues
  List<AdminNotification> get readNotifications =>
      _notifications.where((n) => n.isRead).toList();

  /// Notifications archivées
  List<AdminNotification> get archivedNotifications =>
      _notifications.where((n) => n.isArchived).toList();

  /// Notifications urgentes
  List<AdminNotification> get urgentNotifications =>
      _notifications.where((n) => n.isUrgent).toList();

  /// Notifications de haute priorité
  List<AdminNotification> get highPriorityNotifications =>
      _notifications.where((n) => n.isHighPriority).toList();

  /// Nombre de notifications non lues dans la liste
  int get unreadInListCount => unreadNotifications.length;

  /// Vrai s'il y a des notifications non lues
  bool get hasUnread => _unreadCount > 0;

  // ============================================
  // ACTIONS PRINCIPALES
  // ============================================

  /// Charge la première page des notifications.
  Future<void> loadNotifications() async {
  _status = AdminNotificationStatus2.loading;
  _errorMessage = null;
  _currentPage = 1;
  notifyListeners();

  try {
    final notifications = await _repository.getNotifications(
      page: _currentPage,
      perPage: _perPage,
      type: _filterType,
      priority: _filterPriority,
      isRead: _filterIsRead,
      isArchived: _filterIsArchived,
    );

    // ✅ CONVERSION : Si notifications est List<AdminNotificationModel>, convertir
    _notifications = notifications.map((notification) {
      if (notification is AdminNotificationModel) {
        return AdminNotification(
          id: notification.id,
          title: notification.title,
          body: notification.body,
          type: notification.type,
          priority: notification.priority,
          createdAt: notification.createdAt,
          isRead: notification.isRead,
          readAt: notification.readAt,
          isArchived: notification.isArchived,
          archivedAt: notification.archivedAt,
          targetType: notification.targetType,
          targetId: notification.targetId,
          targetUrl: notification.targetUrl,
          image: notification.image,
          icon: notification.icon,
          metadata: notification.metadata,
        );
      }
      return notification;
    }).toList();

    _hasMore = notifications.length >= _perPage;
    _status = AdminNotificationStatus2.loaded;
    await _loadStatistics();
  } catch (e) {
    _errorMessage = e.toString();
    _status = AdminNotificationStatus2.error;
    debugPrint('Erreur loadNotifications: $e');
  }

  notifyListeners();
}

  /// Charge la page suivante.
  Future<void> loadMoreNotifications() async {
    if (_status == AdminNotificationStatus2.loadingMore || !_hasMore) return;

    _status = AdminNotificationStatus2.loadingMore;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final notifications = await _repository.getNotifications(
        page: nextPage,
        perPage: _perPage,
        type: _filterType,
        priority: _filterPriority,
        isRead: _filterIsRead,
        isArchived: _filterIsArchived,
      );

      if (notifications.isEmpty) {
        _hasMore = false;
      } else {
        _notifications = [..._notifications, ...notifications];
        _currentPage = nextPage;
        _hasMore = notifications.length >= _perPage;
      }

      _status = AdminNotificationStatus2.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminNotificationStatus2.error;
      debugPrint('Erreur loadMoreNotifications: $e');
    }

    notifyListeners();
  }

  /// Rafraîchit sans loader.
  Future<void> refreshNotifications() async {
    try {
      final notifications = await _repository.getNotifications(
        page: 1,
        perPage: _perPage,
        type: _filterType,
        priority: _filterPriority,
        isRead: _filterIsRead,
        isArchived: _filterIsArchived,
      );

      _notifications = notifications;
      _currentPage = 1;
      _hasMore = notifications.length >= _perPage;
      _status = AdminNotificationStatus2.loaded;
      await _loadStatistics();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Erreur refreshNotifications: $e');
    }

    notifyListeners();
  }

  // ============================================
  // FILTRES
  // ============================================

  /// Filtre par type.
  Future<void> filterByType(AdminNotificationType? type) async {
    _filterType = type;
    await loadNotifications();
  }

  /// Filtre par priorité.
  Future<void> filterByPriority(AdminNotificationPriority? priority) async {
    _filterPriority = priority;
    await loadNotifications();
  }

  /// Filtre par statut de lecture.
  Future<void> filterByReadStatus(bool? isRead) async {
    _filterIsRead = isRead;
    await loadNotifications();
  }

  /// Filtre par archivage.
  Future<void> filterByArchivedStatus(bool? isArchived) async {
    _filterIsArchived = isArchived;
    await loadNotifications();
  }

  /// Efface les filtres.
  Future<void> clearFilters() async {
    _filterType = null;
    _filterPriority = null;
    _filterIsRead = null;
    _filterIsArchived = null;
    await loadNotifications();
  }

  // ============================================
  // MARQUAGE
  // ============================================

  /// Marque une notification comme lue.
  Future<bool> markAsRead(int id) async {
    try {
      final success = await _repository.markAsRead(id);
      if (success) {
        _updateReadStatus(id, true);
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Marque une notification comme non lue.
  Future<bool> markAsUnread(int id) async {
    try {
      final success = await _repository.markAsUnread(id);
      if (success) {
        _updateReadStatus(id, false);
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Marque toutes les notifications comme lues.
  Future<bool> markAllAsRead() async {
    try {
      final success = await _repository.markAllAsRead();
      if (success) {
        // Récupérer l'index et modifier l'élément dans la liste
        for (int i = 0; i < _notifications.length; i++) {
          _notifications[i] = _notifications[i].copyWith(
            isRead: true,
            readAt: DateTime.now(),
          );
        }
        await _loadStatistics();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Marque les notifications sélectionnées comme lues.
  Future<int> bulkMarkAsReadSelected() async {
    final count = await _repository.bulkMarkAsRead(selectedIds);
    _selectedIds.clear();
    await refreshNotifications();
    return count;
  }

  // ============================================
  // ARCHIVAGE
  // ============================================

  /// Archive une notification.
  Future<bool> archiveNotification(int id) async {
    try {
      final success = await _repository.archiveNotification(id);
      if (success) {
        _updateArchivedStatus(id, true);
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Désarchive une notification.
  Future<bool> unarchiveNotification(int id) async {
    try {
      final success = await _repository.unarchiveNotification(id);
      if (success) {
        _updateArchivedStatus(id, false);
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Archive toutes les notifications lues.
  Future<int> archiveAllRead() async {
    try {
      final count = await _repository.archiveAllReadNotifications();
      await refreshNotifications();
      return count;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return 0;
    }
  }

  // ============================================
  // SUPPRESSION
  // ============================================

  /// Supprime une notification.
  Future<bool> deleteNotification(int id) async {
    try {
      final success = await _repository.deleteNotification(id);
      if (success) {
        _notifications.removeWhere((n) => n.id == id);
        _selectedIds.remove(id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Supprime toutes les notifications lues.
  Future<int> deleteAllRead() async {
    try {
      final count = await _repository.deleteAllReadNotifications();
      await refreshNotifications();
      return count;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return 0;
    }
  }

  /// Supprime toutes les notifications archivées.
  Future<int> deleteAllArchived() async {
    try {
      final count = await _repository.deleteAllArchivedNotifications();
      await refreshNotifications();
      return count;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return 0;
    }
  }

  /// Efface toutes les notifications.
  Future<bool> clearAll() async {
    try {
      final success = await _repository.clearAllNotifications();
      if (success) {
        _notifications = [];
        _selectedIds.clear();
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
    _selectedIds.addAll(_notifications.map((n) => n.id));
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

  /// Met à jour le statut de lecture.
  void _updateReadStatus(int id, bool isRead) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(
        isRead: isRead,
        readAt: isRead ? DateTime.now() : null,
      );
      notifyListeners();
    }
  }

  /// Met à jour le statut d'archivage.
  void _updateArchivedStatus(int id, bool isArchived) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(
        isArchived: isArchived,
        archivedAt: isArchived ? DateTime.now() : null,
      );
      notifyListeners();
    }
  }

  /// Charge les statistiques.
  Future<void> _loadStatistics() async {
    try {
      _totalCount = await _repository.getTotalNotificationsCount();
      _unreadCount = await _repository.getUnreadCount();
      _readCount = await _repository.getReadCount();
      _archivedCount = await _repository.getArchivedCount();
      _typeCounts = await _repository.getNotificationsCountByType();
      _priorityCounts = await _repository.getNotificationsCountByPriority();
    } catch (e) {
      debugPrint('Erreur _loadStatistics: $e');
    }
  }

  // ============================================
  // RÉINITIALISATION
  // ============================================

  /// Réinitialise le provider.
  void reset() {
    _status = AdminNotificationStatus2.initial;
    _notifications = [];
    _errorMessage = null;
    _currentPage = 1;
    _hasMore = true;
    _filterType = null;
    _filterPriority = null;
    _filterIsRead = null;
    _filterIsArchived = null;
    _selectedIds.clear();
    _totalCount = 0;
    _unreadCount = 0;
    _readCount = 0;
    _archivedCount = 0;
    _typeCounts = {};
    _priorityCounts = {};
    notifyListeners();
  }

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'AdminNotificationProvider(status: $_status, notifications: ${_notifications.length}, '
        'unread: $_unreadCount, archived: $_archivedCount)';
  }
}