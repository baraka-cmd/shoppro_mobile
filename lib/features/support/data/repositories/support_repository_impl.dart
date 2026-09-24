// ============================================
// IMPLÉMENTATION DU REPOSITORY SUPPORT - PREMIUM
// ============================================
// Gère la logique métier avec API et cache local.
// Design ShopPro.
// ============================================

import '../../domain/entities/faq.dart';
import '../../domain/entities/faq_category.dart';
import '../../domain/entities/support_ticket.dart';
import '../../domain/entities/ticket_message.dart';
import '../../domain/repositories/support_repository.dart';
import '../models/faq_model.dart';
import '../models/faq_category_model.dart';
import '../models/support_ticket_model.dart';
import '../models/ticket_message_model.dart';
import '../sources/support_api.dart';
import '../sources/support_local_data_source.dart';

class SupportRepositoryImpl implements SupportRepository {
  final SupportApi _supportApi;
  final SupportLocalDataSource _localDataSource;

  SupportRepositoryImpl({
    SupportApi? supportApi,
    SupportLocalDataSource? localDataSource,
  })  : _supportApi = supportApi ?? SupportApi(),
        _localDataSource = localDataSource ?? SupportLocalDataSource();

  // ============================================
  // FAQ
  // ============================================

  @override
  Future<List<Faq>> getFaqs() async {
    try {
      final faqs = await _supportApi.getFaqs();

      // Mettre en cache
      await _localDataSource.saveFaqs(faqs);

      return faqs;
    } catch (e) {
      // En cas d'erreur réseau, utiliser le cache
      final cachedFaqs = await _localDataSource.getCachedFaqs();
      if (cachedFaqs.isNotEmpty) {
        return cachedFaqs;
      }
      rethrow;
    }
  }

  @override
  Future<Faq?> getFaqById(int faqId) async {
    try {
      final faq = await _supportApi.getFaqById(faqId);
      return faq;
    } catch (e) {
      // Chercher dans le cache
      final cachedFaqs = await _localDataSource.getCachedFaqs();
      for (final faq in cachedFaqs) {
        if (faq.id == faqId) {
          return faq;
        }
      }
      rethrow;
    }
  }

  @override
  Future<List<Faq>> getPopularFaqs({int limit = 10}) async {
    try {
      final faqs = await _supportApi.getPopularFaqs(limit: limit);
      return faqs;
    } catch (e) {
      // Utiliser le cache et filtrer les populaires
      final cachedFaqs = await _localDataSource.getCachedFaqs();
      if (cachedFaqs.isNotEmpty) {
        return cachedFaqs.where((f) => f.isPopular).take(limit).toList();
      }
      rethrow;
    }
  }

  @override
  Future<List<Faq>> searchFaqs(String query) async {
    try {
      final results = await _supportApi.searchFaqs(query);
      return results;
    } catch (e) {
      // Rechercher dans le cache
      final cachedFaqs = await _localDataSource.getCachedFaqs();
      final searchLower = query.toLowerCase();
      return cachedFaqs.where((faq) {
        return faq.question.toLowerCase().contains(searchLower) ||
            faq.answer.toLowerCase().contains(searchLower);
      }).toList();
    }
  }

  @override
  Future<List<Faq>> getFaqsByCategory(int categoryId) async {
    try {
      final faqs = await _supportApi.getFaqsByCategory(categoryId);
      return faqs;
    } catch (e) {
      final cachedFaqs = await _localDataSource.getCachedFaqs();
      return cachedFaqs.where((f) => f.faqCategoryId == categoryId).toList();
    }
  }

  @override
  Future<Faq> markFaqHelpful(int faqId) async {
    final faq = await _supportApi.markFaqHelpful(faqId);
    if (faq == null) {
      throw Exception('FAQ introuvable');
    }
    return faq;
  }

  // ============================================
  // CATÉGORIES DE FAQ
  // ============================================

  @override
  Future<List<FaqCategory>> getFaqCategories() async {
    try {
      final categories = await _supportApi.getFaqCategories();
      await _localDataSource.saveFaqCategories(categories);
      return categories;
    } catch (e) {
      final cachedCategories = await _localDataSource.getCachedFaqCategories();
      if (cachedCategories.isNotEmpty) {
        return cachedCategories;
      }
      rethrow;
    }
  }

  @override
  Future<FaqCategory?> getFaqCategoryById(int categoryId) async {
    try {
      final categories = await getFaqCategories();
      for (final category in categories) {
        if (category.id == categoryId) {
          return category;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // TICKETS DE SUPPORT
  // ============================================

  @override
  Future<List<SupportTicket>> getTickets() async {
    final tickets = await _supportApi.getTickets();
    return tickets;
  }

  @override
  Future<SupportTicket?> getTicketById(int ticketId) async {
    final ticket = await _supportApi.getTicketById(ticketId);
    return ticket;
  }

  @override
  Future<SupportTicket> createTicket({
    required String subject,
    required String description,
    required String category,
    String priority = 'medium',
    int? orderId,
  }) async {
    final ticket = await _supportApi.createTicket(
      subject: subject,
      description: description,
      category: category,
      priority: priority,
      orderId: orderId,
    );

    if (ticket == null) {
      throw Exception('Impossible de créer le ticket');
    }

    return ticket;
  }

  @override
  Future<SupportTicket> closeTicket(int ticketId) async {
    final ticket = await _supportApi.closeTicket(ticketId);
    if (ticket == null) {
      throw Exception('Impossible de fermer le ticket');
    }
    return ticket;
  }

  @override
  Future<List<TicketMessage>> getTicketMessages(int ticketId) async {
    final messages = await _supportApi.getTicketMessages(ticketId);
    return messages;
  }

  @override
  Future<TicketMessage> sendTicketMessage({
    required int ticketId,
    required String message,
    String? attachment,
  }) async {
    final ticketMessage = await _supportApi.sendTicketMessage(
      ticketId: ticketId,
      message: message,
      attachment: attachment,
    );

    if (ticketMessage == null) {
      throw Exception('Impossible d\'envoyer le message');
    }

    return ticketMessage;
  }

  // ============================================
  // CONTACT
  // ============================================

  @override
  Future<SupportTicket> sendContactMessage({
    required String subject,
    required String message,
    required String category,
    String priority = 'medium',
    int? orderId,
  }) async {
    final ticket = await _supportApi.sendContactMessage(
      subject: subject,
      message: message,
      category: category,
      priority: priority,
      orderId: orderId,
    );

    if (ticket == null) {
      throw Exception('Impossible d\'envoyer le message');
    }

    return ticket;
  }

  // ============================================
  // SAUVEGARDE LOCALE
  // ============================================

  @override
  Future<void> saveFaqs(List<Faq> faqs) async {
    final faqModels = faqs
        .map((faq) => FaqModel.fromEntity(faq))
        .toList();
    await _localDataSource.saveFaqs(faqModels);
  }

  @override
  Future<void> saveFaqCategories(List<FaqCategory> categories) async {
    final categoryModels = categories
        .map((category) => FaqCategoryModel.fromEntity(category))
        .toList();
    await _localDataSource.saveFaqCategories(categoryModels);
  }

  @override
  Future<List<Faq>> getCachedFaqs() async {
    return await _localDataSource.getCachedFaqs();
  }

  @override
  Future<List<FaqCategory>> getCachedFaqCategories() async {
    return await _localDataSource.getCachedFaqCategories();
  }

  @override
  Future<void> syncWithBackend() async {
    try {
      final faqs = await _supportApi.getFaqs();
      final categories = await _supportApi.getFaqCategories();
      await _localDataSource.saveFaqs(faqs);
      await _localDataSource.saveFaqCategories(categories);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> isSynced() async {
    return await _localDataSource.isCacheFresh();
  }
}