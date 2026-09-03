// ============================================
// IMPLÉMENTATION DU REPOSITORY DES PAIEMENTS - PREMIUM
// ============================================
// Gère la logique métier avec stockage local,
// simulation et vérification. Design ShopPro.
// ============================================

import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';
import '../models/payment_model.dart';
import '../sources/payment_local_data_source.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentLocalDataSource _localDataSource;

  PaymentRepositoryImpl({PaymentLocalDataSource? localDataSource})
      : _localDataSource = localDataSource ?? PaymentLocalDataSource();

  // ============================================
  // LECTURE
  // ============================================

  @override
  Future<List<Payment>> getPayments() async {
    final payments = await _localDataSource.getPayments();
    payments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return payments;
  }

  @override
  Future<Payment?> getPaymentById(int paymentId) async {
    final payments = await getPayments();
    for (final payment in payments) {
      if (payment.id == paymentId) {
        return payment;
      }
    }
    return null;
  }

  @override
  Future<Payment?> getPaymentByNumber(String paymentNumber) async {
    final payments = await getPayments();
    for (final payment in payments) {
      if (payment.paymentNumber.toLowerCase() == paymentNumber.toLowerCase()) {
        return payment;
      }
    }
    return null;
  }

  @override
  Future<List<Payment>> getPaymentsByOrder(int orderId) async {
    final payments = await getPayments();
    return payments.where((p) => p.orderId == orderId).toList();
  }

  @override
  Future<List<Payment>> getPaymentsByStatus(String status) async {
    final payments = await getPayments();
    return payments.where((p) => p.status == status).toList();
  }

  @override
  Future<List<Payment>> getPendingPayments() async {
    final payments = await getPayments();
    return payments.where((p) => p.isPending || p.isProcessing).toList();
  }

  @override
  Future<List<Payment>> getSuccessfulPayments() async {
    final payments = await getPayments();
    return payments.where((p) => p.isSuccess).toList();
  }

  @override
  Future<List<Payment>> getFailedPayments() async {
    final payments = await getPayments();
    return payments.where((p) => p.isFailed).toList();
  }

  @override
  Future<Payment?> getLatestPaymentByOrder(int orderId) async {
    final payments = await getPaymentsByOrder(orderId);
    if (payments.isEmpty) return null;
    return payments.first;
  }

  @override
  Future<int> getPaymentsCount() async {
    return await _localDataSource.getPaymentsCount();
  }

  @override
  Future<bool> hasPaymentForOrder(int orderId) async {
    final payments = await getPaymentsByOrder(orderId);
    return payments.isNotEmpty;
  }

  // ============================================
  // CRÉATION
  // ============================================

  @override
  Future<Payment> createPayment({
    required int orderId,
    required String orderNumber,
    required double amount,
    double fee = 0,
    required String method,
    String? currency,
  }) async {
    // Vérifier si un paiement est déjà en cours pour cette commande
    final existingPayments = await getPaymentsByOrder(orderId);
    final pendingPayment = existingPayments.where((p) => p.isInProgress).firstOrNull;

    if (pendingPayment != null) {
      return pendingPayment;
    }

    final payments = await getPayments();

    final payment = PaymentModel(
      id: DateTime.now().millisecondsSinceEpoch,
      paymentNumber: _generatePaymentNumber(),
      orderId: orderId,
      orderNumber: orderNumber,
      userId: 0, // Sera mis à jour avec l'utilisateur connecté
      amount: amount,
      fee: fee,
      totalAmount: amount + fee,
      currency: currency ?? 'FCFA',
      method: method,
      status: 'pending',
      expiredAt: DateTime.now().add(const Duration(minutes: 10)),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    payments.add(payment);
    await _localDataSource.savePayments(payments);

    return payment;
  }

  // ============================================
  // TRAITEMENT
  // ============================================

  @override
  Future<Payment> simulatePayment(int paymentId, {bool success = true}) async {
    final payments = await getPayments();
    final index = payments.indexWhere((p) => p.id == paymentId);

    if (index < 0) {
      throw Exception('Paiement introuvable');
    }

    final payment = payments[index];
    final now = DateTime.now();

    final updatedPayment = PaymentModel(
      id: payment.id,
      paymentNumber: payment.paymentNumber,
      orderId: payment.orderId,
      orderNumber: payment.orderNumber,
      userId: payment.userId,
      amount: payment.amount,
      fee: payment.fee,
      totalAmount: payment.totalAmount,
      currency: payment.currency,
      method: payment.method,
      status: success ? 'completed' : 'failed',
      transactionId: success ? 'SIM-${now.millisecondsSinceEpoch}' : null,
      gatewayReference: success ? 'SIM-${now.millisecondsSinceEpoch}' : null,
      paidAt: success ? now : null,
      failedAt: !success ? now : null,
      errorMessage: !success ? 'Paiement refusé par simulation' : null,
      expiredAt: payment.expiredAt,
      createdAt: payment.createdAt,
      updatedAt: now,
    );

    payments[index] = updatedPayment;
    await _localDataSource.savePayments(payments);

    return updatedPayment;
  }

  @override
  Future<Payment> verifyPayment(int paymentId) async {
    final payment = await getPaymentById(paymentId);
    if (payment == null) {
      throw Exception('Paiement introuvable');
    }
    return payment;
  }

  @override
  Future<Payment> confirmPayment(int paymentId, String transactionId) async {
    final payments = await getPayments();
    final index = payments.indexWhere((p) => p.id == paymentId);

    if (index < 0) {
      throw Exception('Paiement introuvable');
    }

    final payment = payments[index];
    final now = DateTime.now();

    final updatedPayment = PaymentModel(
      id: payment.id,
      paymentNumber: payment.paymentNumber,
      orderId: payment.orderId,
      orderNumber: payment.orderNumber,
      userId: payment.userId,
      amount: payment.amount,
      fee: payment.fee,
      totalAmount: payment.totalAmount,
      currency: payment.currency,
      method: payment.method,
      status: 'completed',
      transactionId: transactionId,
      gatewayReference: payment.gatewayReference,
      paidAt: now,
      failedAt: null,
      errorMessage: null,
      expiredAt: payment.expiredAt,
      createdAt: payment.createdAt,
      updatedAt: now,
    );

    payments[index] = updatedPayment;
    await _localDataSource.savePayments(payments);
    return updatedPayment;
  }

  @override
  Future<Payment> failPayment(int paymentId, String errorMessage) async {
    final payments = await getPayments();
    final index = payments.indexWhere((p) => p.id == paymentId);

    if (index < 0) {
      throw Exception('Paiement introuvable');
    }

    final payment = payments[index];
    final now = DateTime.now();

    final updatedPayment = PaymentModel(
      id: payment.id,
      paymentNumber: payment.paymentNumber,
      orderId: payment.orderId,
      orderNumber: payment.orderNumber,
      userId: payment.userId,
      amount: payment.amount,
      fee: payment.fee,
      totalAmount: payment.totalAmount,
      currency: payment.currency,
      method: payment.method,
      status: 'failed',
      errorMessage: errorMessage,
      failedAt: now,
      paidAt: null,
      expiredAt: payment.expiredAt,
      createdAt: payment.createdAt,
      updatedAt: now,
    );

    payments[index] = updatedPayment;
    await _localDataSource.savePayments(payments);
    return updatedPayment;
  }

  @override
  Future<Payment> cancelPayment(int paymentId) async {
    final payments = await getPayments();
    final index = payments.indexWhere((p) => p.id == paymentId);

    if (index < 0) {
      throw Exception('Paiement introuvable');
    }

    final payment = payments[index];
    final now = DateTime.now();

    final updatedPayment = PaymentModel(
      id: payment.id,
      paymentNumber: payment.paymentNumber,
      orderId: payment.orderId,
      orderNumber: payment.orderNumber,
      userId: payment.userId,
      amount: payment.amount,
      fee: payment.fee,
      totalAmount: payment.totalAmount,
      currency: payment.currency,
      method: payment.method,
      status: 'cancelled',
      errorMessage: 'Paiement annulé',
      expiredAt: payment.expiredAt,
      createdAt: payment.createdAt,
      updatedAt: now,
    );

    payments[index] = updatedPayment;
    await _localDataSource.savePayments(payments);
    return updatedPayment;
  }

  @override
  Future<Payment> expirePayment(int paymentId) async {
    final payments = await getPayments();
    final index = payments.indexWhere((p) => p.id == paymentId);

    if (index < 0) {
      throw Exception('Paiement introuvable');
    }

    final payment = payments[index];
    final now = DateTime.now();

    final updatedPayment = PaymentModel(
      id: payment.id,
      paymentNumber: payment.paymentNumber,
      orderId: payment.orderId,
      orderNumber: payment.orderNumber,
      userId: payment.userId,
      amount: payment.amount,
      fee: payment.fee,
      totalAmount: payment.totalAmount,
      currency: payment.currency,
      method: payment.method,
      status: 'expired',
      errorMessage: 'Paiement expiré',
      expiredAt: now,
      createdAt: payment.createdAt,
      updatedAt: now,
    );

    payments[index] = updatedPayment;
    await _localDataSource.savePayments(payments);
    return updatedPayment;
  }

  // ============================================
  // REMBOURSEMENT
  // ============================================

  @override
  Future<bool> canRefundPayment(int paymentId) async {
    final payment = await getPaymentById(paymentId);
    return payment != null && payment.isSuccess && !payment.isRefunded;
  }

  @override
  Future<Payment> refundPayment(int paymentId) async {
    if (!await canRefundPayment(paymentId)) {
      throw Exception('Ce paiement ne peut pas être remboursé');
    }

    final payments = await getPayments();
    final index = payments.indexWhere((p) => p.id == paymentId);

    final payment = payments[index];
    final now = DateTime.now();

    final updatedPayment = PaymentModel(
      id: payment.id,
      paymentNumber: payment.paymentNumber,
      orderId: payment.orderId,
      orderNumber: payment.orderNumber,
      userId: payment.userId,
      amount: payment.amount,
      fee: payment.fee,
      totalAmount: payment.totalAmount,
      currency: payment.currency,
      method: payment.method,
      status: 'refunded',
      errorMessage: null,
      paidAt: payment.paidAt,
      failedAt: null,
      expiredAt: payment.expiredAt,
      createdAt: payment.createdAt,
      updatedAt: now,
    );

    payments[index] = updatedPayment;
    await _localDataSource.savePayments(payments);
    return updatedPayment;
  }

  @override
  Future<Payment> partiallyRefundPayment(int paymentId, double amount) async {
    if (!await canRefundPayment(paymentId)) {
      throw Exception('Ce paiement ne peut pas être remboursé');
    }

    final payments = await getPayments();
    final index = payments.indexWhere((p) => p.id == paymentId);

    final payment = payments[index];
    final now = DateTime.now();

    final updatedPayment = PaymentModel(
      id: payment.id,
      paymentNumber: payment.paymentNumber,
      orderId: payment.orderId,
      orderNumber: payment.orderNumber,
      userId: payment.userId,
      amount: amount,
      fee: payment.fee,
      totalAmount: amount + payment.fee,
      currency: payment.currency,
      method: payment.method,
      status: 'partially_refunded',
      errorMessage: null,
      paidAt: payment.paidAt,
      failedAt: null,
      expiredAt: payment.expiredAt,
      createdAt: payment.createdAt,
      updatedAt: now,
    );

    payments[index] = updatedPayment;
    await _localDataSource.savePayments(payments);
    return updatedPayment;
  }

  // ============================================
  // REÇU
  // ============================================

  @override
  Future<String> generateReceipt(int paymentId) async {
    final payment = await getPaymentById(paymentId);

    if (payment == null) {
      throw Exception('Paiement introuvable');
    }

    return '''
=== REÇU DE PAIEMENT ===
Numéro : ${payment.paymentNumber}
Commande : ${payment.orderNumber}
Méthode : ${payment.method}
Montant : ${payment.formattedAmount}
Frais : ${payment.formattedFee}
Total : ${payment.formattedTotalAmount}
Statut : ${payment.statusLabel}
Date : ${payment.createdAt.toString()}
======================
''';
  }

  // ============================================
  // SAUVEGARDE
  // ============================================

  @override
  Future<void> savePayments(List<Payment> payments) async {
    await _localDataSource.savePayments(payments);
  }

  @override
  Future<List<Payment>> syncWithBackend() async {
    // TODO: Synchroniser avec l'API Laravel
    return await getPayments();
  }

  @override
  Future<bool> isPaymentsSynced() async {
    return true;
  }

  // ============================================
  // ANNULATION (Undo)
  // ============================================

  @override
  Future<void> savePaymentsSnapshot() async {
    await _localDataSource.savePaymentsSnapshot();
  }

  @override
  Future<List<Payment>> restorePaymentsSnapshot() async {
    return await _localDataSource.restorePaymentsSnapshot() ?? [];
  }

  @override
  Future<void> clearPaymentsSnapshot() async {
    await _localDataSource.clearPaymentsSnapshot();
  }

  // ============================================
  // GÉNÉRATION DU NUMÉRO DE PAIEMENT
  // ============================================

  String _generatePaymentNumber() {
    final date = DateTime.now();
    final dateStr = '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    final random = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
    return 'PAY-$dateStr-$random';
  }
}

// Extension firstOrNull
extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}