// ============================================
// PROVIDER DES PAIEMENTS - VERSION PREMIUM
// ============================================
// Gère l'état des paiements avec actions complètes,
// vérification et annulation.
// ============================================

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

  // ============================================
  // ÉTAT
  // ============================================

  PaymentStatus _status = PaymentStatus.initial;
  List<Payment> _payments = [];
  Payment? _currentPayment;
  String? _errorMessage;
  int _processingPaymentId = -1;

  // ============================================
  // GETTERS DE BASE
  // ============================================

  PaymentStatus get status => _status;
  List<Payment> get payments => _payments;
  Payment? get currentPayment => _currentPayment;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == PaymentStatus.loading;
  bool get isProcessing => _status == PaymentStatus.processing;
  bool get isSuccess => _status == PaymentStatus.success;
  bool get isFailed => _status == PaymentStatus.failed;
  bool get hasError => _status == PaymentStatus.error;
  bool get isEmpty => _payments.isEmpty;
  int get paymentsCount => _payments.length;

  /// ID du paiement en cours de traitement
  int get processingPaymentId => _processingPaymentId;

  // ============================================
  // GETTERS DÉRIVÉS
  // ============================================

  /// Paiements en attente
  List<Payment> get pendingPayments {
    return _payments.where((p) => p.isPending || p.isProcessing).toList();
  }

  /// Paiements réussis
  List<Payment> get successfulPayments {
    return _payments.where((p) => p.isSuccess).toList();
  }

  /// Paiements échoués
  List<Payment> get failedPayments {
    return _payments.where((p) => p.isFailed).toList();
  }

  // ============================================
  // CHARGEMENT
  // ============================================

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

  /// Rafraîchir les paiements
  Future<void> refreshPayments() async {
    await loadPayments();
  }

  // ============================================
  // CRÉATION
  // ============================================

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
      await _paymentRepository.savePaymentsSnapshot();
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

  // ============================================
  // TRAITEMENT
  // ============================================

  /// Simuler un paiement
  Future<Payment?> simulatePayment(int paymentId, {bool success = true}) async {
    _processingPaymentId = paymentId;
    _setStatus(PaymentStatus.processing);
    _clearError();
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));

      final payment = await _paymentRepository.simulatePayment(
        paymentId,
        success: success,
      );

      _currentPayment = payment;
      _payments = await _paymentRepository.getPayments();
      _processingPaymentId = -1;

      if (payment.isSuccess) {
        _setStatus(PaymentStatus.success);
      } else {
        _setStatus(PaymentStatus.failed);
      }

      notifyListeners();
      return payment;
    } catch (e) {
      _processingPaymentId = -1;
      _setError(e.toString());
      _setStatus(PaymentStatus.error);
      notifyListeners();
      return null;
    }
  }

  /// Vérifier le statut d'un paiement
  Future<Payment?> verifyPayment(int paymentId) async {
    _processingPaymentId = paymentId;
    notifyListeners();

    try {
      final payment = await _paymentRepository.verifyPayment(paymentId);
      _currentPayment = payment;
      _processingPaymentId = -1;
      notifyListeners();
      return payment;
    } catch (e) {
      _processingPaymentId = -1;
      _setError(e.toString());
      notifyListeners();
      return null;
    }
  }

  /// Confirmer un paiement
  Future<Payment?> confirmPayment(int paymentId, String transactionId) async {
    _processingPaymentId = paymentId;
    _setStatus(PaymentStatus.processing);

    try {
      final payment = await _paymentRepository.confirmPayment(
        paymentId,
        transactionId,
      );

      _currentPayment = payment;
      _payments = await _paymentRepository.getPayments();
      _processingPaymentId = -1;
      _setStatus(PaymentStatus.success);
      notifyListeners();
      return payment;
    } catch (e) {
      _processingPaymentId = -1;
      _setError(e.toString());
      _setStatus(PaymentStatus.error);
      notifyListeners();
      return null;
    }
  }

  /// Échouer un paiement
  Future<Payment?> failPayment(int paymentId, String errorMessage) async {
    _processingPaymentId = paymentId;

    try {
      final payment = await _paymentRepository.failPayment(
        paymentId,
        errorMessage,
      );

      _currentPayment = payment;
      _payments = await _paymentRepository.getPayments();
      _processingPaymentId = -1;
      _setStatus(PaymentStatus.failed);
      notifyListeners();
      return payment;
    } catch (e) {
      _processingPaymentId = -1;
      _setError(e.toString());
      notifyListeners();
      return null;
    }
  }

  /// Annuler un paiement
  Future<Payment?> cancelPayment(int paymentId) async {
    _processingPaymentId = paymentId;

    try {
      final payment = await _paymentRepository.cancelPayment(paymentId);
      _currentPayment = payment;
      _payments = await _paymentRepository.getPayments();
      _processingPaymentId = -1;
      notifyListeners();
      return payment;
    } catch (e) {
      _processingPaymentId = -1;
      _setError(e.toString());
      notifyListeners();
      return null;
    }
  }

  // ============================================
  // REMBOURSEMENT
  // ============================================

  /// Rembourser un paiement
  Future<Payment?> refundPayment(int paymentId) async {
    _processingPaymentId = paymentId;

    try {
      final payment = await _paymentRepository.refundPayment(paymentId);
      _currentPayment = payment;
      _payments = await _paymentRepository.getPayments();
      _processingPaymentId = -1;
      notifyListeners();
      return payment;
    } catch (e) {
      _processingPaymentId = -1;
      _setError(e.toString());
      notifyListeners();
      return null;
    }
  }

  // ============================================
  // REÇU
  // ============================================

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

  // ============================================
  // RECHERCHE
  // ============================================

  /// Récupérer un paiement par ID
  Payment? getPaymentById(int paymentId) {
    for (final payment in _payments) {
      if (payment.id == paymentId) {
        return payment;
      }
    }
    return null;
  }

  // ============================================
  // ANNULATION (Undo)
  // ============================================

  /// Annuler la dernière action
  Future<bool> undoLastAction() async {
    try {
      final restored = await _paymentRepository.restorePaymentsSnapshot();
      if (restored != null) {
        _payments = restored;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
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

  void _setStatus(PaymentStatus newStatus) {
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
    return 'PaymentProvider(status: $_status, payments: ${_payments.length}, '
        'current: ${_currentPayment?.paymentNumber ?? 'none'}, '
        'processing: $_processingPaymentId)';
  }
}