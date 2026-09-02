// Provider des paiements
// Gère l'état des paiements et les actions

import 'package:flutter/foundation.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../data/repositories/payment_repository_impl.dart';

enum PaymentStatus {
  initial,
  loading,
  loaded,
  processing,
  success,
  failed,
  error,
}

class PaymentProvider extends ChangeNotifier {
  final PaymentRepository _paymentRepository;

  PaymentProvider({PaymentRepository? paymentRepository})
      : _paymentRepository = paymentRepository ?? PaymentRepositoryImpl();

  PaymentStatus _status = PaymentStatus.initial;
  List<Payment> _payments = [];
  Payment? _currentPayment;
  String? _errorMessage;

  // Getters
  PaymentStatus get status => _status;
  List<Payment> get payments => _payments;
  Payment? get currentPayment => _currentPayment;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == PaymentStatus.loading;
  bool get isProcessing => _status == PaymentStatus.processing;
  bool get isSuccess => _status == PaymentStatus.success;
  bool get hasError => _status == PaymentStatus.error;
  bool get isEmpty => _payments.isEmpty;
  int get paymentsCount => _payments.length;

  /// Charger les paiements
  Future<void> loadPayments() async {
    _setStatus(PaymentStatus.loading);
    _clearError();

    try {
      _payments = await _paymentRepository.getPayments();
      _setStatus(PaymentStatus.loaded);
    } catch (e) {
      _setError(e.toString());
      _setStatus(PaymentStatus.error);
    }

    notifyListeners();
  }

  /// Créer un paiement
  Future<Payment?> createPayment({
    required int orderId,
    required String orderNumber,
    required double amount,
    double fee = 0,
    required String method,
  }) async {
    _setStatus(PaymentStatus.processing);
    _clearError();

    try {
      final payment = await _paymentRepository.createPayment(
        orderId: orderId,
        orderNumber: orderNumber,
        amount: amount,
        fee: fee,
        method: method,
      );

      _currentPayment = payment;
      _payments = await _paymentRepository.getPayments();
      _setStatus(PaymentStatus.loaded);
      notifyListeners();
      return payment;
    } catch (e) {
      _setError(e.toString());
      _setStatus(PaymentStatus.error);
      notifyListeners();
      return null;
    }
  }

  /// Simuler un paiement
  Future<Payment?> simulatePayment(int paymentId, {bool success = true}) async {
    print('=== PROVIDER SIMULATE PAYMENT START ===');
    print('paymentId: $paymentId');
    
    _setStatus(PaymentStatus.processing);
    _clearError();

    try {
      // Simuler un délai de traitement
      await Future.delayed(const Duration(seconds: 2));
      print('Délai 2 secondes terminé');

      final payment = await _paymentRepository.simulatePayment(
        paymentId,
        success: success,
      );
      print('Payment reçu du repository: ${payment.status}');

      _currentPayment = payment;
      _payments = await _paymentRepository.getPayments();
      print('Liste mise à jour: ${_payments.length} paiements');

      if (payment.isSuccessful) {
        _setStatus(PaymentStatus.success);
      } else {
        _setStatus(PaymentStatus.failed);
      }

      notifyListeners();
      print('=== PROVIDER SIMULATE PAYMENT END - RETURNING ${payment.status} ===');
      
      return payment;
    } catch (e) {
      print('ERREUR DANS PROVIDER: $e');
      _setError(e.toString());
      _setStatus(PaymentStatus.error);
      notifyListeners();
      return null;
    }
  }

  /// Confirmer un paiement
  Future<Payment?> confirmPayment(int paymentId, String transactionId) async {
    _setStatus(PaymentStatus.processing);

    try {
      final payment = await _paymentRepository.confirmPayment(
        paymentId,
        transactionId,
      );

      _currentPayment = payment;
      _payments = await _paymentRepository.getPayments();
      _setStatus(PaymentStatus.success);
      notifyListeners();
      return payment;
    } catch (e) {
      _setError(e.toString());
      _setStatus(PaymentStatus.error);
      notifyListeners();
      return null;
    }
  }

  /// Échouer un paiement
  Future<Payment?> failPayment(int paymentId, String errorMessage) async {
    _setStatus(PaymentStatus.processing);

    try {
      final payment = await _paymentRepository.failPayment(
        paymentId,
        errorMessage,
      );

      _currentPayment = payment;
      _payments = await _paymentRepository.getPayments();
      _setStatus(PaymentStatus.failed);
      notifyListeners();
      return payment;
    } catch (e) {
      _setError(e.toString());
      _setStatus(PaymentStatus.error);
      notifyListeners();
      return null;
    }
  }

  /// Rembourser un paiement
  Future<Payment?> refundPayment(int paymentId) async {
    _setStatus(PaymentStatus.processing);

    try {
      final payment = await _paymentRepository.refundPayment(paymentId);
      _currentPayment = payment;
      _payments = await _paymentRepository.getPayments();
      _setStatus(PaymentStatus.loaded);
      notifyListeners();
      return payment;
    } catch (e) {
      _setError(e.toString());
      _setStatus(PaymentStatus.error);
      notifyListeners();
      return null;
    }
  }

  /// Générer un reçu
  Future<String?> generateReceipt(int paymentId) async {
    try {
      return await _paymentRepository.generateReceipt(paymentId);
    } catch (e) {
      _setError(e.toString());
      notifyListeners();
      return null;
    }
  }

  /// Récupérer un paiement par ID
  Payment? getPaymentById(int paymentId) {
    for (final payment in _payments) {
      if (payment.id == paymentId) {
        return payment;
      }
    }
    return null;
  }

  /// Effacer l'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Méthodes privées
  void _setStatus(PaymentStatus newStatus) {
    _status = newStatus;
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setError(String message) {
    _errorMessage = message.replaceFirst('Exception: ', '');
  }
}