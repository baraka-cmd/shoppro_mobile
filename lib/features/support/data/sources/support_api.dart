// ============================================
// SERVICE API SUPPORT - VERSION PREMIUM
// ============================================
// Contient toutes les requêtes HTTP vers le
// backend Laravel pour le support et FAQ.
// ============================================

import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/faq_model.dart';
import '../models/faq_category_model.dart';
import '../models/support_ticket_model.dart';
import '../models/ticket_message_model.dart';

class SupportApi {
  final Dio _dio = ApiClient().dio;

  // ============================================
  // FAQ
  // ============================================

  /// Récupérer la liste des FAQs
  Future<List<FaqModel>> getFaqs() async {
    try {
      final response = await _dio.get('/faqs');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map((json) => FaqModel.fromJson(json))
              .toList();
        }
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer une FAQ par ID
  Future<FaqModel?> getFaqById(int faqId) async {
    try {
      final response = await _dio.get('/faqs/$faqId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return FaqModel.fromJson(data);
        }
      }

      return null;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer les FAQs populaires
  Future<List<FaqModel>> getPopularFaqs({int limit = 10}) async {
    try {
      final response = await _dio.get(
        '/faqs',
        queryParameters: {'popular': true, 'limit': limit},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map((json) => FaqModel.fromJson(json))
              .toList();
        }
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Rechercher des FAQs
  Future<List<FaqModel>> searchFaqs(String query) async {
    try {
      final response = await _dio.get(
        '/faqs',
        queryParameters: {'search': query},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map((json) => FaqModel.fromJson(json))
              .toList();
        }
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer les FAQs par catégorie
  Future<List<FaqModel>> getFaqsByCategory(int categoryId) async {
    try {
      final response = await _dio.get(
        '/faqs',
        queryParameters: {'category_id': categoryId},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map((json) => FaqModel.fromJson(json))
              .toList();
        }
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Marquer une FAQ comme utile
  Future<FaqModel?> markFaqHelpful(int faqId) async {
    try {
      final response = await _dio.post('/faqs/$faqId/helpful');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return FaqModel.fromJson(data);
        }
      }

      return null;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // CATÉGORIES DE FAQ
  // ============================================

  /// Récupérer les catégories de FAQ
  Future<List<FaqCategoryModel>> getFaqCategories() async {
    try {
      final response = await _dio.get('/faq-categories');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map((json) => FaqCategoryModel.fromJson(json))
              .toList();
        }
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // TICKETS DE SUPPORT
  // ============================================

  /// Récupérer les tickets de l'utilisateur
  Future<List<SupportTicketModel>> getTickets() async {
    try {
      final response = await _dio.get('/support/tickets');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map((json) => SupportTicketModel.fromJson(json))
              .toList();
        }
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer un ticket par ID
  Future<SupportTicketModel?> getTicketById(int ticketId) async {
    try {
      final response = await _dio.get('/support/tickets/$ticketId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return SupportTicketModel.fromJson(data);
        }
      }

      return null;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Créer un ticket
  Future<SupportTicketModel?> createTicket({
    required String subject,
    required String description,
    required String category,
    String priority = 'medium',
    int? orderId,
  }) async {
    try {
      final response = await _dio.post(
        '/support/tickets',
        data: {
          'subject': subject,
          'description': description,
          'category': category,
          'priority': priority,
          'order_id': orderId,
        },
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return SupportTicketModel.fromJson(data);
        }
      }

      return null;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Fermer un ticket
  Future<SupportTicketModel?> closeTicket(int ticketId) async {
    try {
      final response = await _dio.post('/support/tickets/$ticketId/close');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return SupportTicketModel.fromJson(data);
        }
      }

      return null;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer les messages d'un ticket
  Future<List<TicketMessageModel>> getTicketMessages(int ticketId) async {
    try {
      final response = await _dio.get('/support/tickets/$ticketId/messages');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map((json) => TicketMessageModel.fromJson(json))
              .toList();
        }
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Envoyer un message dans un ticket
  Future<TicketMessageModel?> sendTicketMessage({
    required int ticketId,
    required String message,
    String? attachment,
  }) async {
    try {
      final response = await _dio.post(
        '/support/tickets/$ticketId/messages',
        data: {
          'message': message,
          'attachment': attachment,
        },
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return TicketMessageModel.fromJson(data);
        }
      }

      return null;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // CONTACT
  // ============================================

  /// Envoyer un message de contact
  Future<SupportTicketModel?> sendContactMessage({
    required String subject,
    required String message,
    required String category,
    String priority = 'medium',
    int? orderId,
  }) async {
    try {
      final response = await _dio.post(
        '/contact',
        data: {
          'subject': subject,
          'message': message,
          'category': category,
          'priority': priority,
          'order_id': orderId,
        },
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return SupportTicketModel.fromJson(data);
        }
      }

      return null;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // GESTION DES ERREURS
  // ============================================

  Exception _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return Exception('Connexion lente. Vérifiez votre réseau et réessayez.');

      case DioExceptionType.connectionError:
        return Exception('Impossible de se connecter au serveur.');

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;

        if (data is Map<String, dynamic> && data['message'] != null) {
          return Exception(data['message'].toString());
        }

        if (statusCode == 401) {
          return Exception('Session expirée. Veuillez vous reconnecter.');
        }
        if (statusCode == 404) {
          return Exception('Ressource introuvable.');
        }
        if (statusCode == 422) {
          return Exception('Données invalides. Vérifiez les champs saisis.');
        }

        return Exception('Erreur ${statusCode ?? 'inconnue'}.');

      default:
        return Exception('Une erreur est survenue. Veuillez réessayer.');
    }
  }
}