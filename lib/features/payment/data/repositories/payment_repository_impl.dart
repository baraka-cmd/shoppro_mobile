// Implémentation du repository des paiements
// Gère la logique métier avec stockage local et simulation

import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';
import '../models/payment_model.dart';
import '../sources/payment_local_data_source.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentLocalDataSource _localDataSource;

  PaymentRepositoryImpl({PaymentLocalDataSource? localDataSource})
      : _localDataSource = localDataSource ?? PaymentLocalDataSource();

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
      if (payment.paymentNumber == paymentNumber) {
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
  Future<Payment> createPayment({
    required int orderId,
    required String orderNumber,
    required double amount,
    double fee = 0,
    required String method,
    String? currency,
  }) async {
    final payments = await getPayments();

    final payment = PaymentModel(
      id: DateTime.now().millisecondsSinceEpoch,
      paymentNumber: _generatePaymentNumber(),
      orderId: orderId,
      orderNumber: orderNumber,
      amount: amount,
      fee: fee,
      totalAmount: amount + fee,
      currency: currency ?? 'FCFA',
      method: method,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    payments.add(payment);
    await _localDataSource.savePayments(payments);

    return payment;
  }

  @override
  Future<Payment> simulatePayment(int paymentId, {bool success = true}) async {
    final payments = await getPayments();
    final index = payments.indexWhere((p) => p.id == paymentId);

    if (index < 0) {
      throw Exception('Paiement introuvable');
    }

    final payment = payments[index];

    // ✅ Utiliser PaymentModel
    final updatedPayment = PaymentModel(
      id: payment.id,
      paymentNumber: payment.paymentNumber,
      orderId: payment.orderId,
      orderNumber: payment.orderNumber,
      amount: payment.amount,
      fee: payment.fee,
      totalAmount: payment.totalAmount,
      currency: payment.currency,
      method: payment.method,
      status: success ? 'completed' : 'failed',
      transactionId: success ? 'SIM-${DateTime.now().millisecondsSinceEpoch}' : null,
      gatewayReference: success ? 'SIM-${DateTime.now().millisecondsSinceEpoch}' : null,
      paidAt: success ? DateTime.now() : null,
      failedAt: !success ? DateTime.now() : null,
      errorMessage: !success ? 'Paiement refusé par simulation' : null,
      createdAt: payment.createdAt,
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

    // ✅ PaymentModel
    final updatedPayment = PaymentModel(
      id: payment.id,
      paymentNumber: payment.paymentNumber,
      orderId: payment.orderId,
      orderNumber: payment.orderNumber,
      amount: payment.amount,
      fee: payment.fee,
      totalAmount: payment.totalAmount,
      currency: payment.currency,
      method: payment.method,
      status: 'completed',
      transactionId: transactionId,
      paidAt: DateTime.now(),
      createdAt: payment.createdAt,
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

    // ✅ PaymentModel
    final updatedPayment = PaymentModel(
      id: payment.id,
      paymentNumber: payment.paymentNumber,
      orderId: payment.orderId,
      orderNumber: payment.orderNumber,
      amount: payment.amount,
      fee: payment.fee,
      totalAmount: payment.totalAmount,
      currency: payment.currency,
      method: payment.method,
      status: 'failed',
      errorMessage: errorMessage,
      failedAt: DateTime.now(),
      createdAt: payment.createdAt,
    );

    payments[index] = updatedPayment;
    await _localDataSource.savePayments(payments);
    return updatedPayment;
  }

  @override
  Future<Payment> refundPayment(int paymentId) async {
    final payments = await getPayments();
    final index = payments.indexWhere((p) => p.id == paymentId);

    if (index < 0) {
      throw Exception('Paiement introuvable');
    }

    final payment = payments[index];

    // ✅ PaymentModel
    final updatedPayment = PaymentModel(
      id: payment.id,
      paymentNumber: payment.paymentNumber,
      orderId: payment.orderId,
      orderNumber: payment.orderNumber,
      amount: payment.amount,
      fee: payment.fee,
      totalAmount: payment.totalAmount,
      currency: payment.currency,
      method: payment.method,
      status: 'refunded',
      refundedAt: DateTime.now(),
      createdAt: payment.createdAt,
    );

    payments[index] = updatedPayment;
    await _localDataSource.savePayments(payments);
    return updatedPayment;
  }

  @override
  Future<List<Payment>> getPaymentsByStatus(String status) async {
    final payments = await getPayments();
    return payments.where((p) => p.status == status).toList();
  }

  @override
  Future<void> savePayments(List<Payment> payments) async {
    await _localDataSource.savePayments(payments);
  }

  @override
  Future<int> getPaymentsCount() async {
    return await _localDataSource.getPaymentsCount();
  }

  @override
  Future<String> generateReceipt(int paymentId) async {
    final payment = await getPaymentById(paymentId);

    if (payment == null) {
      throw Exception('Paiement introuvable');
    }

    final receipt = '''
=== REÇU DE PAIEMENT ===
Numéro : ${payment.paymentNumber}
Commande : ${payment.orderNumber}
Méthode : ${payment.methodLabel}
Montant : ${payment.formattedAmount}
Frais : ${payment.formattedFee}
Total : ${payment.formattedTotal}
Statut : ${payment.statusLabel}
Date : ${payment.createdAt.toString()}
======================
''';

    return receipt;
  }

  // Générer un numéro de paiement unique
  String _generatePaymentNumber() {
    final date = DateTime.now();
    final dateStr = '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    final random = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
    return 'PAY-$dateStr-$random';
  }
}