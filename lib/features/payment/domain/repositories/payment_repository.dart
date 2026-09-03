// ============================================
// INTERFACE DU REPOSITORY DES PAIEMENTS - PREMIUM
// ============================================
// Définit le contrat que le repository doit
// respecter. Gestion complète des paiements,
// vérification, remboursement et reçus.
// ============================================

import '../entities/payment.dart';

abstract class PaymentRepository {
  // ============================================
  // LECTURE
  // ============================================

  /// Récupérer tous les paiements
  Future<List<Payment>> getPayments();

  /// Récupérer un paiement par ID
  Future<Payment?> getPaymentById(int paymentId);

  /// Récupérer un paiement par numéro
  Future<Payment?> getPaymentByNumber(String paymentNumber);

  /// Récupérer les paiements d'une commande
  Future<List<Payment>> getPaymentsByOrder(int orderId);

  /// Récupérer les paiements par statut
  Future<List<Payment>> getPaymentsByStatus(String status);

  /// Récupérer les paiements en attente
  Future<List<Payment>> getPendingPayments();

  /// Récupérer les paiements réussis
  Future<List<Payment>> getSuccessfulPayments();

  /// Récupérer les paiements échoués
  Future<List<Payment>> getFailedPayments();

  /// Récupérer le dernier paiement d'une commande
  Future<Payment?> getLatestPaymentByOrder(int orderId);

  /// Récupérer le nombre de paiements
  Future<int> getPaymentsCount();

  /// Vérifier si un paiement existe déjà pour une commande
  Future<bool> hasPaymentForOrder(int orderId);

  // ============================================
  // CRÉATION
  // ============================================

  /// Créer un paiement
  Future<Payment> createPayment({
    required int orderId,
    required String orderNumber,
    required double amount,
    double fee = 0,
    required String method,
    String? currency,
  });

  // ============================================
  // TRAITEMENT
  // ============================================

  /// Simuler un paiement (pour développement)
  Future<Payment> simulatePayment(int paymentId, {bool success = true});

  /// Vérifier le statut d'un paiement
  Future<Payment> verifyPayment(int paymentId);

  /// Confirmer un paiement
  Future<Payment> confirmPayment(int paymentId, String transactionId);

  /// Marquer un paiement comme échoué
  Future<Payment> failPayment(int paymentId, String errorMessage);

  /// Annuler un paiement
  Future<Payment> cancelPayment(int paymentId);

  /// Marquer un paiement comme expiré
  Future<Payment> expirePayment(int paymentId);

  // ============================================
  // REMBOURSEMENT
  // ============================================

  /// Rembourser un paiement
  Future<Payment> refundPayment(int paymentId);

  /// Rembourser partiellement
  Future<Payment> partiallyRefundPayment(int paymentId, double amount);

  /// Vérifier si un paiement peut être remboursé
  Future<bool> canRefundPayment(int paymentId);

  // ============================================
  // REÇU
  // ============================================

  /// Générer un reçu de paiement
  Future<String> generateReceipt(int paymentId);

  // ============================================
  // SAUVEGARDE
  // ============================================

  /// Sauvegarder les paiements localement
  Future<void> savePayments(List<Payment> payments);

  /// Synchroniser avec le backend
  Future<List<Payment>> syncWithBackend();

  /// Vérifier si les paiements sont synchronisés
  Future<bool> isPaymentsSynced();

  // ============================================
  // ANNULATION (Undo)
  // ============================================

  /// Sauvegarder le snapshot des paiements
  Future<void> savePaymentsSnapshot();

  /// Restaurer le snapshot des paiements
  Future<List<Payment>> restorePaymentsSnapshot();

  /// Effacer le snapshot
  Future<void> clearPaymentsSnapshot();
}