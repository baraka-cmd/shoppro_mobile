// ============================================
// INTERFACE DU REPOSITORY SUPPORT - PREMIUM
// ============================================
// Définit le contrat que le repository doit
// respecter. Gestion FAQ, tickets et contact.
// ============================================

import '../entities/faq.dart';
import '../entities/faq_category.dart';
import '../entities/support_ticket.dart';
import '../entities/ticket_message.dart';

abstract class SupportRepository {
  // ============================================
  // FAQ
  // ============================================

  /// Récupérer toutes les FAQs
  Future<List<Faq>> getFaqs();

  /// Récupérer une FAQ par ID
  Future<Faq?> getFaqById(int faqId);

  /// Récupérer les FAQs populaires
  Future<List<Faq>> getPopularFaqs({int limit = 10});

  /// Rechercher des FAQs
  Future<List<Faq>> searchFaqs(String query);

  /// Récupérer les FAQs par catégorie
  Future<List<Faq>> getFaqsByCategory(int categoryId);

  /// Marquer une FAQ comme utile
  Future<Faq> markFaqHelpful(int faqId);

  // ============================================
  // CATÉGORIES DE FAQ
  // ============================================

  /// Récupérer toutes les catégories de FAQ
  Future<List<FaqCategory>> getFaqCategories();

  /// Récupérer une catégorie par ID
  Future<FaqCategory?> getFaqCategoryById(int categoryId);

  // ============================================
  // TICKETS DE SUPPORT
  // ============================================

  /// Récupérer les tickets de l'utilisateur
  Future<List<SupportTicket>> getTickets();

  /// Récupérer un ticket par ID
  Future<SupportTicket?> getTicketById(int ticketId);

  /// Créer un ticket
  Future<SupportTicket> createTicket({
    required String subject,
    required String description,
    required String category,
    String priority = 'medium',
    int? orderId,
  });

  /// Fermer un ticket
  Future<SupportTicket> closeTicket(int ticketId);

  /// Récupérer les messages d'un ticket
  Future<List<TicketMessage>> getTicketMessages(int ticketId);

  /// Envoyer un message dans un ticket
  Future<TicketMessage> sendTicketMessage({
    required int ticketId,
    required String message,
    String? attachment,
  });

  // ============================================
  // CONTACT
  // ============================================

  /// Envoyer un message de contact
  Future<SupportTicket> sendContactMessage({
    required String subject,
    required String message,
    required String category,
    String priority = 'medium',
    int? orderId,
  });

  // ============================================
  // SAUVEGARDE LOCALE
  // ============================================

  /// Sauvegarder les FAQs localement
  Future<void> saveFaqs(List<Faq> faqs);

  /// Sauvegarder les catégories localement
  Future<void> saveFaqCategories(List<FaqCategory> categories);

  /// Récupérer les FAQs depuis le cache local
  Future<List<Faq>> getCachedFaqs();

  /// Récupérer les catégories depuis le cache local
  Future<List<FaqCategory>> getCachedFaqCategories();

  /// Synchroniser avec le backend
  Future<void> syncWithBackend();

  /// Vérifier si les données sont synchronisées
  Future<bool> isSynced();
}