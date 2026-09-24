// ============================================
// PROVIDER SUPPORT - VERSION PREMIUM
// ============================================
// Gère l'état des FAQs, catégories, tickets
// et messages. Design ShopPro.
// ============================================

import 'package:flutter/foundation.dart';
import '../../domain/entities/faq.dart';
import '../../domain/entities/faq_category.dart';
import '../../domain/entities/support_ticket.dart';
import '../../domain/entities/ticket_message.dart';
import '../../domain/repositories/support_repository.dart';
import '../../data/repositories/support_repository_impl.dart';

enum SupportStatus {
  initial,
  loading,
  loaded,
  refreshing,
  searching,
  creating,
  sending,
  syncing,
  empty,
  error,
}

class SupportProvider extends ChangeNotifier {
  final SupportRepository _supportRepository;

  SupportProvider({SupportRepository? supportRepository})
      : _supportRepository = supportRepository ?? SupportRepositoryImpl();

  // ============================================
  // ÉTAT
  // ============================================

  SupportStatus _status = SupportStatus.initial;
  String? _errorMessage;
  String _currentFaqFilter = 'all';
  String _searchQuery = '';
  int _updatingFaqId = -1;
  int _activeTicketId = -1;

  // ============================================
  // DONNÉES
  // ============================================

  List<Faq> _faqs = [];
  List<FaqCategory> _faqCategories = [];
  List<SupportTicket> _tickets = [];
  List<TicketMessage> _ticketMessages = [];
  SupportTicket? _activeTicket;

  // ============================================
  // GETTERS DE BASE
  // ============================================

  SupportStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get currentFaqFilter => _currentFaqFilter;
  String get searchQuery => _searchQuery;
  int get updatingFaqId => _updatingFaqId;
  int get activeTicketId => _activeTicketId;

  bool get isLoading => _status == SupportStatus.loading;
  bool get isRefreshing => _status == SupportStatus.refreshing;
  bool get isSearching => _status == SupportStatus.searching;
  bool get isCreating => _status == SupportStatus.creating;
  bool get isSending => _status == SupportStatus.sending;
  bool get isSyncing => _status == SupportStatus.syncing;
  bool get hasError => _status == SupportStatus.error;
  bool get isEmpty => _faqs.isEmpty;

  List<Faq> get faqs => _faqs;
  List<FaqCategory> get faqCategories => _faqCategories;
  List<SupportTicket> get tickets => _tickets;
  List<TicketMessage> get ticketMessages => _ticketMessages;
  SupportTicket? get activeTicket => _activeTicket;

  // ============================================
  // GETTERS DÉRIVÉS
  // ============================================

  /// FAQs filtrées
  List<Faq> get filteredFaqs {
    var result = _faqs;

    // Filtre par catégorie
    if (_currentFaqFilter != 'all') {
      result = result.where((faq) {
        return faq.faqCategoryId.toString() == _currentFaqFilter;
      }).toList();
    }

    // Filtre par recherche
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((faq) {
        return faq.question.toLowerCase().contains(query) ||
            faq.answer.toLowerCase().contains(query);
      }).toList();
    }

    return result;
  }

  /// FAQs populaires
  List<Faq> get popularFaqs {
    return _faqs.where((f) => f.isPopular).toList();
  }

  /// Nombre de FAQs
  int get faqsCount => _faqs.length;

  /// Nombre de catégories
  int get categoriesCount => _faqCategories.length;

  /// Nombre de tickets
  int get ticketsCount => _tickets.length;

  /// Tickets actifs
  List<SupportTicket> get activeTickets {
    return _tickets.where((t) => t.isActive).toList();
  }

  /// Tickets résolus
  List<SupportTicket> get resolvedTickets {
    return _tickets.where((t) => t.isResolved).toList();
  }

  /// Tickets fermés
  List<SupportTicket> get closedTickets {
    return _tickets.where((t) => t.isClosed).toList();
  }

  // ============================================
  // CHARGEMENT
  // ============================================

  /// Charger les FAQs et catégories
  Future<void> loadFaqs() async {
    _setStatus(SupportStatus.loading);
    _clearError();

    try {
      final results = await Future.wait([
        _supportRepository.getFaqs(),
        _supportRepository.getFaqCategories(),
      ]);

      _faqs = results[0] as List<Faq>;
      _faqCategories = results[1] as List<FaqCategory>;
      _setStatus(_faqs.isEmpty ? SupportStatus.empty : SupportStatus.loaded);
    } catch (e) {
      _setError(e.toString());
      _setStatus(SupportStatus.error);
    }

    notifyListeners();
  }

  /// Rafraîchir les FAQs
  Future<void> refreshFaqs() async {
    _setStatus(SupportStatus.refreshing);

    try {
      final results = await Future.wait([
        _supportRepository.getFaqs(),
        _supportRepository.getFaqCategories(),
      ]);

      _faqs = results[0] as List<Faq>;
      _faqCategories = results[1] as List<FaqCategory>;
      _setStatus(_faqs.isEmpty ? SupportStatus.empty : SupportStatus.loaded);
    } catch (e) {
      _setError(e.toString());
      _setStatus(SupportStatus.error);
    }

    notifyListeners();
  }

  /// Rechercher des FAQs
  Future<void> searchFaqs(String query) async {
    _searchQuery = query.trim();
    _setStatus(SupportStatus.searching);

    try {
      _faqs = await _supportRepository.searchFaqs(_searchQuery);
      _setStatus(_faqs.isEmpty ? SupportStatus.empty : SupportStatus.loaded);
    } catch (e) {
      _setError(e.toString());
      _setStatus(SupportStatus.error);
    }

    notifyListeners();
  }

  /// Synchroniser avec le backend
  Future<void> syncWithBackend() async {
    _setStatus(SupportStatus.syncing);

    try {
      await _supportRepository.syncWithBackend();
      await loadFaqs();
    } catch (e) {
      _setError(e.toString());
      _setStatus(SupportStatus.error);
    }

    notifyListeners();
  }

  // ============================================
  // FILTRES
  // ============================================

  /// Changer le filtre de catégorie
  void setFaqFilter(String filter) {
    _currentFaqFilter = filter;
    notifyListeners();
  }

  /// Effacer le filtre
  void clearFaqFilter() {
    _currentFaqFilter = 'all';
    notifyListeners();
  }

  /// Effacer la recherche
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // ============================================
  // FAQ UTILES
  // ============================================

  /// Marquer une FAQ comme utile
  Future<bool> markFaqHelpful(int faqId) async {
    _updatingFaqId = faqId;

    try {
      final updatedFaq = await _supportRepository.markFaqHelpful(faqId);
      final index = _faqs.indexWhere((f) => f.id == faqId);
      if (index >= 0) {
        _faqs[index] = updatedFaq;
      }
      _updatingFaqId = -1;
      notifyListeners();
      return true;
    } catch (e) {
      _updatingFaqId = -1;
      _setError(e.toString());
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // TICKETS
  // ============================================

  /// Charger les tickets
  Future<void> loadTickets() async {
    _setStatus(SupportStatus.loading);
    _clearError();

    try {
      _tickets = await _supportRepository.getTickets();
      _setStatus(_tickets.isEmpty ? SupportStatus.empty : SupportStatus.loaded);
    } catch (e) {
      _setError(e.toString());
      _setStatus(SupportStatus.error);
    }

    notifyListeners();
  }

  /// Charger un ticket et ses messages
  Future<void> loadTicket(int ticketId) async {
    _activeTicketId = ticketId;
    _setStatus(SupportStatus.loading);

    try {
      _activeTicket = await _supportRepository.getTicketById(ticketId);
      _ticketMessages = await _supportRepository.getTicketMessages(ticketId);
      _setStatus(SupportStatus.loaded);
    } catch (e) {
      _setError(e.toString());
      _setStatus(SupportStatus.error);
    }

    notifyListeners();
  }

  /// Créer un ticket
  Future<SupportTicket?> createTicket({
    required String subject,
    required String description,
    required String category,
    String priority = 'medium',
    int? orderId,
  }) async {
    _setStatus(SupportStatus.creating);
    _clearError();

    try {
      final ticket = await _supportRepository.createTicket(
        subject: subject,
        description: description,
        category: category,
        priority: priority,
        orderId: orderId,
      );

      _tickets.insert(0, ticket);
      _setStatus(SupportStatus.loaded);
      notifyListeners();
      return ticket;
    } catch (e) {
      _setError(e.toString());
      _setStatus(SupportStatus.error);
      notifyListeners();
      return null;
    }
  }

  /// Fermer un ticket
  Future<bool> closeTicket(int ticketId) async {
    try {
      final updatedTicket = await _supportRepository.closeTicket(ticketId);
      final index = _tickets.indexWhere((t) => t.id == ticketId);
      if (index >= 0) {
        _tickets[index] = updatedTicket;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      notifyListeners();
      return false;
    }
  }

  /// Envoyer un message dans un ticket
  Future<TicketMessage?> sendTicketMessage({
    required int ticketId,
    required String message,
    String? attachment,
  }) async {
    _setStatus(SupportStatus.sending);
    _clearError();

    try {
      final ticketMessage = await _supportRepository.sendTicketMessage(
        ticketId: ticketId,
        message: message,
        attachment: attachment,
      );

      _ticketMessages.add(ticketMessage);
      _setStatus(SupportStatus.loaded);
      notifyListeners();
      return ticketMessage;
    } catch (e) {
      _setError(e.toString());
      _setStatus(SupportStatus.error);
      notifyListeners();
      return null;
    }
  }

  // ============================================
  // CONTACT
  // ============================================

  /// Envoyer un message de contact
  Future<SupportTicket?> sendContactMessage({
    required String subject,
    required String message,
    required String category,
    String priority = 'medium',
    int? orderId,
  }) async {
    _setStatus(SupportStatus.sending);
    _clearError();

    try {
      final ticket = await _supportRepository.sendContactMessage(
        subject: subject,
        message: message,
        category: category,
        priority: priority,
        orderId: orderId,
      );

      _setStatus(SupportStatus.loaded);
      notifyListeners();
      return ticket;
    } catch (e) {
      _setError(e.toString());
      _setStatus(SupportStatus.error);
      notifyListeners();
      return null;
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

  void _setStatus(SupportStatus newStatus) {
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
    return 'SupportProvider(status: $_status, faqs: $_faqs.length, '
        'categories: $_faqCategories.length, tickets: $_tickets.length, '
        'filter: $_currentFaqFilter)';
  }
}