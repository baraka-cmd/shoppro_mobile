// Barre de recherche personnalisée
// Avec auto-focus, effacement et debounce

import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../core/constants/app_colors.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final VoidCallback? onBack;
  final bool autoFocus;
  final Duration debounceDuration;
  final String hintText;

  const CustomSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onBack,
    this.autoFocus = true,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.hintText = 'Rechercher un produit...',
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  Timer? _debounce;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _hasText = widget.controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  // Détecter le changement de texte
  void _onTextChanged() {
    setState(() {
      _hasText = widget.controller.text.isNotEmpty;
    });

    // Annuler le debounce précédent
    _debounce?.cancel();

    // Créer un nouveau debounce
    _debounce = Timer(widget.debounceDuration, () {
      if (mounted) {
        widget.onChanged?.call(widget.controller.text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          // Bouton retour
          if (widget.onBack != null)
            GestureDetector(
              onTap: widget.onBack,
              child: const Icon(
                Icons.arrow_back_ios,
                size: 16,
                color: AppColors.textPrimary,
              ),
            ),

          if (widget.onBack != null) const SizedBox(width: 8),

          // Icône recherche
          const Icon(
            Icons.search,
            size: 20,
            color: AppColors.textSecondary,
          ),

          const SizedBox(width: 10),

          // Champ de texte
          Expanded(
            child: TextField(
              controller: widget.controller,
              autofocus: widget.autoFocus,
              textInputAction: TextInputAction.search,
              onSubmitted: widget.onSubmitted,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppColors.textLight,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),

          // Bouton effacer
          if (_hasText)
            GestureDetector(
              onTap: () {
                widget.controller.clear();
                widget.onClear?.call();
              },
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}