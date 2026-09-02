// Dialog de confirmation de paiement
// Affiche le résultat du paiement (succès ou échec)

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
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône de succès ou échec
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: (isSuccess ? AppColors.success : AppColors.error)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSuccess ? Icons.check_circle : Icons.cancel,
                size: 45,
                color: isSuccess ? AppColors.success : AppColors.error,
              ),
            ),

            const SizedBox(height: 20),

            // Titre
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

            // Description
            Text(
              isSuccess
                  ? 'Votre paiement a été traité avec succès.'
                  : 'Une erreur est survenue lors du paiement.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 20),

            // Détails du paiement
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildDetailRow('N° Paiement', payment.paymentNumber),
                  const SizedBox(height: 5),
                  _buildDetailRow('Commande', payment.orderNumber),
                  const SizedBox(height: 5),
                  _buildDetailRow('Méthode', payment.methodLabel),
                  const SizedBox(height: 5),
                  _buildDetailRow('Montant', payment.formattedTotal),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Bouton
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
          ],
        ),
      ),
    );
  }

  // Ligne de détail
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

// Fonction pour afficher le dialog
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