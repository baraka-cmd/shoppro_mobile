// ============================================
// FORMULAIRE DE CONTACT - VERSION PREMIUM
// ============================================
// Formulaire complet avec catégories, priorité
// et message. Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ContactForm extends StatefulWidget {
  final bool isLoading;
  final ValueChanged<Map<String, dynamic>>? onSubmit;

  const ContactForm({
    super.key,
    this.isLoading = false,
    this.onSubmit,
  });

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String _selectedCategory = 'general';
  String _selectedPriority = 'medium';

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // ============================================
  // SOUMISSION
  // ============================================

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    widget.onSubmit?.call({
      'subject': _subjectController.text.trim(),
      'message': _messageController.text.trim(),
      'category': _selectedCategory,
      'priority': _selectedPriority,
    });
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================
          // CATÉGORIE
          // ============================================
          const Text(
            'Catégorie',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(
                  value: 'general',
                  child: Text('Question générale', style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                ),
                DropdownMenuItem(
                  value: 'order',
                  child: Text('Problème avec ma commande', style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                ),
                DropdownMenuItem(
                  value: 'payment',
                  child: Text('Problème de paiement', style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                ),
                DropdownMenuItem(
                  value: 'delivery',
                  child: Text('Problème de livraison', style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                ),
                DropdownMenuItem(
                  value: 'return',
                  child: Text('Retour / Remboursement', style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                ),
                DropdownMenuItem(
                  value: 'account',
                  child: Text('Problème avec mon compte', style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                ),
                DropdownMenuItem(
                  value: 'technical',
                  child: Text('Problème technique', style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                ),
                DropdownMenuItem(
                  value: 'other',
                  child: Text('Autre', style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value ?? 'general';
                });
              },
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
          ),

          const SizedBox(height: 15),

          // ============================================
          // PRIORITÉ
          // ============================================
          const Text(
            'Priorité',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildPriorityChip('low', 'Basse'),
              _buildPriorityChip('medium', 'Moyenne'),
              _buildPriorityChip('high', 'Haute'),
              _buildPriorityChip('urgent', 'Urgente'),
            ],
          ),

          const SizedBox(height: 15),

          // ============================================
          // SUJET
          // ============================================
          const Text(
            'Sujet',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _subjectController,
            maxLength: 255,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le sujet est obligatoire';
              }
              return null;
            },
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Résumé de votre problème...',
              hintStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppColors.textLight,
              ),
              filled: true,
              fillColor: Colors.white,
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // ============================================
          // MESSAGE
          // ============================================
          const Text(
            'Message',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _messageController,
            maxLines: 5,
            maxLength: 2000,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le message est obligatoire';
              }
              if (value.trim().length < 10) {
                return 'Le message doit contenir au moins 10 caractères';
              }
              return null;
            },
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Expliquez-nous votre problème...',
              hintStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppColors.textLight,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ============================================
          // BOUTON ENVOYER
          // ============================================
          ElevatedButton(
            onPressed: widget.isLoading ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
              shadowColor: AppColors.primary.withValues(alpha: 0.3),
              disabledBackgroundColor: AppColors.borderColor,
            ),
            child: widget.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'ENVOYER LE MESSAGE',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // CHIP DE PRIORITÉ
  // ============================================

  Widget _buildPriorityChip(String value, String label) {
    final isSelected = _selectedPriority == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPriority = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderColor,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}