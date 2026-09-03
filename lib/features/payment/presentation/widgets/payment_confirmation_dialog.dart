// ============================================
// DIALOG DE CONFIRMATION DE PAIEMENT - PREMIUM
// ============================================
// Affiche le résultat du paiement avec détails
// et animations. Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/payment.dart';

class PaymentConfirmationDialog extends StatelessWidget {
  final Payment payment;
  final bool isSuccess;
  final VoidCallback? onDone;

  const PaymentConfirmationDialog({
    super.key,
    required this.payment,
    required this.isSuccess,
    this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: AppColors.mediumShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ============================================
            // ICÔNE DE SUCCÈS OU ÉCHEC (animée)
            // ============================================
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.5, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: (isSuccess ? AppColors.success : AppColors.error)
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isSuccess ? AppColors.success : AppColors.error)
                          .withValues(alpha: 0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  isSuccess ? Icons.check_circle : Icons.cancel,
                  size: 45,
                  color: isSuccess ? AppColors.success : AppColors.error,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ============================================
            // TITRE
            // ============================================
            Text(
              isSuccess ? 'Paiement réussi !' : 'Paiement échoué',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSuccess ? AppColors.success : AppColors.error,
              ),
            ),

            const SizedBox(height: 10),

            // ============================================
            // DESCRIPTION
            // ============================================
            Text(
              isSuccess
                  ? 'Votre paiement a été traité avec succès.'
                  : 'Une erreur est survenue lors du paiement.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 20),

            // ============================================
            // DÉTAILS DU PAIEMENT
            // ============================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildDetailRow('N° Paiement', payment.paymentNumber),
                  const SizedBox(height: 5),
                  _buildDetailRow('Commande', payment.orderNumber),
                  const SizedBox(height: 5),
                  _buildDetailRow('Méthode', payment.method),
                  const SizedBox(height: 5),
                  _buildDetailRow('Montant', payment.formattedTotalAmount),
                  if (payment.transactionId != null) ...[
                    const SizedBox(height: 5),
                    _buildDetailRow('Transaction', payment.transactionId!),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ============================================
            // BOUTON
            // ============================================
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDone?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSuccess ? AppColors.success : AppColors.error,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                shadowColor: (isSuccess ? AppColors.success : AppColors.error)
                    .withValues(alpha: 0.3),
              ),
              child: Text(
                isSuccess ? 'VOIR MES COMMANDES' : 'RÉESSAYER',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ============================================
            // BOUTON FERMER (si succès)
            // ============================================
            if (isSuccess)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onDone?.call();
                },
                child: const Text(
                  'Continuer mes achats',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // LIGNE DE DÉTAIL
  // ============================================

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================
// FONCTION POUR AFFICHER LE DIALOG
// ============================================

Future<void> showPaymentConfirmation({
  required BuildContext context,
  required Payment payment,
  required bool isSuccess,
  VoidCallback? onDone,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return PaymentConfirmationDialog(
        payment: payment,
        isSuccess: isSuccess,
        onDone: onDone,
      );
    },
  );
}