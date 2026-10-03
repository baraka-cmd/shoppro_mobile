// ============================================
// BOUTON FACTURE PDF - SHOPPRO
// ============================================
// Bouton réutilisable qui :
// - Télécharge la facture PDF depuis l'API
// - Affiche une progression pendant le téléchargement
// - Ouvre le PDF automatiquement
// - Propose le partage via share_plus
// - Gère le cache (évite de re-télécharger)
// - Gère les erreurs avec messages clairs
//
// Utilisable dans :
// - OrderDetailScreen (client)
// - AdminOrderDetailScreen (admin)
// ============================================

import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/file_download_service.dart';

class InvoiceButton extends StatefulWidget {
  /// ID de la commande
  final int orderId;

  /// Numéro de commande (utilisé pour le nom du fichier)
  final String orderNumber;

  /// Endpoint API de la facture
  /// Par défaut : '/orders/{id}/invoice' (client)
  /// Pour admin : '/admin/orders/{id}/invoice'
  final String? customEndpoint;

  /// Style du bouton :
  /// - 'primary' → bouton plein (par défaut)
  /// - 'outline' → bouton contour
  /// - 'icon'    → icône seule (compact)
  final String style;

  /// Texte personnalisé (par défaut "Télécharger la facture")
  final String? label;

  /// Affiche automatiquement le PDF après téléchargement
  final bool autoOpen;

  /// Callback appelé après un téléchargement réussi
  final VoidCallback? onSuccess;

  /// Callback appelé en cas d'erreur
  final ValueChanged<String>? onError;

  const InvoiceButton({
    super.key,
    required this.orderId,
    required this.orderNumber,
    this.customEndpoint,
    this.style = 'primary',
    this.label,
    this.autoOpen = true,
    this.onSuccess,
    this.onError,
  });

  @override
  State<InvoiceButton> createState() => _InvoiceButtonState();
}

class _InvoiceButtonState extends State<InvoiceButton> {
  final FileDownloadService _downloadService = FileDownloadService();

  // ─────────────────────────────────────────────
  // ÉTAT
  // ─────────────────────────────────────────────
  bool _isDownloading = false;
  double _progress = 0.0;
  File? _downloadedFile;

  // ─────────────────────────────────────────────
  // ENDPOINT
  // ─────────────────────────────────────────────
  String get _endpoint {
  if (widget.customEndpoint != null) {
    return widget.customEndpoint!;
  }
  return '/orders/by-number/${widget.orderNumber}/invoice';  // 👈 AJOUTE / AU DÉBUT
}

  // ─────────────────────────────────────────────
  // NOM DU FICHIER
  // ─────────────────────────────────────────────
  String get _filename {
    // Nettoyer le numéro de commande pour éviter les caractères invalides
    final clean = widget.orderNumber.replaceAll(
      RegExp(r'[^\w\-]'),
      '_',
    );
    return 'facture-$clean.pdf';
  }

  // ─────────────────────────────────────────────
  // TÉLÉCHARGER + OUVRIR
  // ─────────────────────────────────────────────
  Future<void> _handleDownload() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
      _progress = 0.0;
    });

    try {
      // 1. Télécharger le PDF
      final file = await _downloadService.downloadPdf(
        endpoint: _endpoint,
        filename: _filename,
        onProgress: (received, total) {
          if (total > 0 && mounted) {
            setState(() {
              _progress = received / total;
            });
          }
        },
      );

      if (!mounted) return;

      // 2. Vérifier le résultat
      if (file == null) {
        _showError(
          'Impossible de télécharger la facture. Vérifiez votre connexion.',
        );
        return;
      }

      setState(() {
        _downloadedFile = file;
      });

      // 3. Callback succès
      widget.onSuccess?.call();

      // 4. Ouvrir automatiquement
      if (widget.autoOpen) {
        final opened = await _downloadService.openFile(file);

        if (!opened && mounted) {
          _showError(
            'Impossible d\'ouvrir le PDF. Vérifiez qu\'un lecteur PDF est installé.',
          );
        }
      }

      // 5. Proposer le partage
      if (mounted) {
        _showShareDialog(file);
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Erreur : $e');
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _progress = 0.0;
        });
      }
    }
  }

  // ─────────────────────────────────────────────
  // DIALOG DE PARTAGE
  // ─────────────────────────────────────────────
  void _showShareDialog(File file) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icône succès
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 36,
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                'Facture téléchargée',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                _filename,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 20),

              // Bouton partager
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _shareFile(file);
                  },
                  icon: const Icon(Icons.share, size: 16),
                  label: const Text(
                    'PARTAGER',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Bouton fermer
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'FERMER',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // PARTAGER
  // ─────────────────────────────────────────────
  Future<void> _shareFile(File file) async {
    await _downloadService.shareFile(
      file: file,
      subject: 'Facture ${widget.orderNumber}',
      text: 'Voici la facture de votre commande ${widget.orderNumber}.',
    );
  }

  // ─────────────────────────────────────────────
  // AFFICHER UNE ERREUR
  // ─────────────────────────────────────────────
  void _showError(String message) {
    widget.onError?.call(message);

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
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    switch (widget.style) {
      case 'icon':
        return _buildIconButton();
      case 'outline':
        return _buildOutlineButton();
      case 'primary':
      default:
        return _buildPrimaryButton();
    }
  }

  // ─────────────────────────────────────────────
  // BOUTON PRINCIPAL (plein)
  // ─────────────────────────────────────────────
  Widget _buildPrimaryButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isDownloading ? null : _handleDownload,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          disabledBackgroundColor: AppColors.borderColor,
          disabledForegroundColor: AppColors.textTertiary,
        ),
        child: _buildButtonContent(
          textColor: Colors.white,
          iconColor: Colors.white,
          icon: Icons.download,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BOUTON CONTOUR (outline)
  // ─────────────────────────────────────────────
  Widget _buildOutlineButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _isDownloading ? null : _handleDownload,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _buildButtonContent(
          textColor: AppColors.primary,
          iconColor: AppColors.primary,
          icon: Icons.download_outlined,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BOUTON ICÔNE SEULE
  // ─────────────────────────────────────────────
  Widget _buildIconButton() {
    return GestureDetector(
      onTap: _isDownloading ? null : _handleDownload,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: _isDownloading
            ? Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    value: _progress > 0 ? _progress : null,
                    color: AppColors.primary,
                    strokeWidth: 2.5,
                  ),
                ),
              )
            : const Icon(
                Icons.download,
                color: AppColors.primary,
                size: 20,
              ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // CONTENU DU BOUTON (texte + icône + loader)
  // ─────────────────────────────────────────────
  Widget _buildButtonContent({
    required Color textColor,
    required Color iconColor,
    required IconData icon,
  }) {
    if (_isDownloading) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              value: _progress > 0 ? _progress : null,
              color: textColor,
              strokeWidth: 2.5,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _progress > 0
                ? '${(_progress * 100).toInt()} %'
                : 'Téléchargement...',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Text(
          widget.label ?? 'TÉLÉCHARGER LA FACTURE',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }
}