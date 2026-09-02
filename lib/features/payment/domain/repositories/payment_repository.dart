// Interface du repository des paiements
// Définit le contrat que le repository doit respecter

import '../entities/payment.dart';

abstract class PaymentRepository {
  /// Récupérer tous les paiements
  Future<List<Payment>> getPayments();

  /// Récupérer un paiement par ID
  Future<Payment?> getPaymentById(int paymentId);

  /// Récupérer un paiement par numéro
  Future<Payment?> getPaymentByNumber(String paymentNumber);

  /// Récupérer les paiements d'une commande
  Future<List<Payment>> getPaymentsByOrder(int orderId);

  /// Créer un paiement
  Future<Payment> createPayment({
    required int orderId,
    required String orderNumber,
    required double amount,
    double fee = 0,
    required String method,
    String? currency,
  });

  /// Simuler un paiement (pour développement)
  Future<Payment> simulatePayment(int paymentId, {bool success = true});

  /// Vérifier le statut d'un paiement
  Future<Payment> verifyPayment(int paymentId);

  /// Confirmer un paiement
  Future<Payment> confirmPayment(int paymentId, String transactionId);

  /// Marquer un paiement comme échoué
  Future<Payment> failPayment(int paymentId, String errorMessage);

  /// Rembourser un paiement
  Future<Payment> refundPayment(int paymentId);

  /// Récupérer les paiements par statut
  Future<List<Payment>> getPaymentsByStatus(String status);

  /// Sauvegarder les paiements localement
  Future<void> savePayments(List<Payment> payments);

  /// Récupérer le nombre de paiements
  Future<int> getPaymentsCount();

  /// Générer un reçu de paiement
  Future<String> generateReceipt(int paymentId);
}