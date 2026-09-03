// ============================================
// ÉCRAN DE PAIEMENT - VERSION PREMIUM
// ============================================
// Permet de choisir le mode et de confirmer
// le paiement en toute sécurité. Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../../../notifications/domain/entities/app_notification.dart';
import '../providers/payment_provider.dart';
import '../widgets/payment_method_card.dart';
import '../widgets/payment_summary.dart';
import '../widgets/payment_confirmation_dialog.dart';

class PaymentScreen extends StatefulWidget {
  final dynamic order;

  const PaymentScreen({
    super.key,
    required this.order,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'cash_on_delivery';
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'method': 'cash_on_delivery',
      'label': 'À la livraison',
      'description': 'Payez en espèces à la réception',
      'icon': Icons.payments_outlined,
      'color': AppColors.success,
      'available': true,
    },
    {
      'method': 'airtel_money',
      'label': 'Airtel Money',
      'description': 'Payez via Airtel Money',
      'icon': Icons.phone_android,
      'color': const Color(0xFFFF0000),
      'available': true,
    },
    {
      'method': 'orange_money',
      'label': 'Orange Money',
      'description': 'Payez via Orange Money',
      'icon': Icons.phone_android,
      'color': const Color(0xFFFF7900),
      'available': true,
    },
    {
      'method': 'card',
      'label': 'Carte bancaire',
      'description': 'Visa, Mastercard (bientôt)',
      'icon': Icons.credit_card_outlined,
      'color': AppColors.primary,
      'available': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final selectedMethod = _paymentMethods.firstWhere(
      (m) => m['method'] == _selectedMethod,
    );

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
        title: const Text(
          'Paiement',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================
            // TITRE
            // ============================================
            const Text(
              'CHOISISSEZ VOTRE MODE DE PAIEMENT',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 12),

            // ============================================
            // MÉTHODES DE PAIEMENT
            // ============================================
            ..._paymentMethods.map((method) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: PaymentMethodCard(
                  method: method['method'],
                  label: method['label'],
                  description: method['description'],
                  icon: method['icon'],
                  color: method['color'],
                  isSelected: _selectedMethod == method['method'],
                  isAvailable: method['available'],
                  onTap: method['available']
                      ? () {
                          setState(() {
                            _selectedMethod = method['method'];
                          });
                        }
                      : null,
                ),
              );
            }),

            const SizedBox(height: 15),

            // ============================================
            // RÉSUMÉ
            // ============================================
            PaymentSummary(
              amount: widget.order.total,
              fee: 0,
              total: widget.order.total,
              currency: widget.order.currency,
              methodLabel: selectedMethod['label'],
            ),

            const SizedBox(height: 15),

            // ============================================
            // SÉCURITÉ
            // ============================================
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.2),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 16,
                    color: AppColors.info,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Vos informations de paiement sont sécurisées.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : () => _showConfirmationDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              shadowColor: AppColors.primary.withValues(alpha: 0.3),
              disabledBackgroundColor: AppColors.borderColor,
            ),
            child: _isProcessing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'PAYER ${widget.order.formattedTotal}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // ============================================
  // DIALOG DE CONFIRMATION
  // ============================================

  void _showConfirmationDialog() {
    final selectedMethod = _paymentMethods.firstWhere(
      (m) => m['method'] == _selectedMethod,
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Confirmer le paiement ?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Commande : ${widget.order.orderNumber}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Montant : ${widget.order.formattedTotal}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Méthode : ${selectedMethod['label']}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Modifier',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _processPayment();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'CONFIRMER',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================
  // TRAITER LE PAIEMENT
  // ============================================

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final paymentProvider = context.read<PaymentProvider>();

      final payment = await paymentProvider.createPayment(
        orderId: widget.order.id,
        orderNumber: widget.order.orderNumber,
        amount: widget.order.total,
        fee: 0,
        method: _selectedMethod,
      );

      if (payment == null) {
        setState(() {
          _isProcessing = false;
        });
        _showError('Erreur lors de la création du paiement');
        return;
      }

      final result = await paymentProvider.simulatePayment(
        payment.id,
        success: true,
      );

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      if (result != null) {
        final notificationProvider = context.read<NotificationProvider>();
        await notificationProvider.addNotification(
          AppNotification(
            id: DateTime.now().millisecondsSinceEpoch,
            title: 'Paiement réussi !',
            body: 'Votre paiement de ${result.formattedTotalAmount} a été traité avec succès.',
            type: 'order',
            createdAt: DateTime.now(),
          ),
        );

        await showPaymentConfirmation(
          context: context,
          payment: result,
          isSuccess: result.isSuccess,
          onDone: () {
            final cartProvider = context.read<CartProvider>();
            cartProvider.clearCart();

            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.orders,
              (route) => false,
            );
          },
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showError('Erreur: $e');
    }
  }

  // ============================================
  // AFFICHER UNE ERREUR
  // ============================================

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}