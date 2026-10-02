// ============================================
// BARRE DE RECHERCHE PERSONNALISÉE - PREMIUM
// ============================================
// Avec auto-focus, effacement, debounce et
// micro-interactions. Design ShopPro.
// (Recherche vocale désactivée temporairement)
// ============================================

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
    this.debounceDuration = const Duration(milliseconds: 350),
    this.hintText = 'Rechercher un produit...',
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  Timer? _debounce;
  bool _hasText = false;
  bool _isFocused = false;

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

  // ============================================
  // DÉTECTION DE TEXTE
  // ============================================

  void _onTextChanged() {
    final hasText = widget.controller.text.isNotEmpty;

    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }

    _debounce?.cancel();
    _debounce = Timer(widget.debounceDuration, () {
      if (mounted) {
        widget.onChanged?.call(widget.controller.text);
      }
    });
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _isFocused ? Colors.white : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isFocused ? AppColors.primary : AppColors.borderColor,
          width: _isFocused ? 2 : 1.5,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 5,
                ),
              ],
      ),
      child: Row(
        children: [
          // ============================================
          // BOUTON RETOUR
          // ============================================
          if (widget.onBack != null) ...[
            GestureDetector(
              onTap: widget.onBack,
              child: const Icon(
                Icons.arrow_back_ios,
                size: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
          ],

          // ============================================
          // ICÔNE RECHERCHE
          // ============================================
          const Icon(
            Icons.search,
            size: 20,
            color: AppColors.textSecondary,
          ),

          const SizedBox(width: 10),

          // ============================================
          // CHAMP DE TEXTE
          // ============================================
          Expanded(
            child: Focus(
              onFocusChange: (isFocused) {
                setState(() {
                  _isFocused = isFocused;
                });
              },
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
                cursorColor: AppColors.primary,
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
          ),

          // ============================================
          // BOUTON EFFACER (animé)
          // ============================================
          AnimatedScale(
            scale: _hasText ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: _hasText
                ? GestureDetector(
                    onTap: () {
                      widget.controller.clear();
                      widget.onClear?.call();
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : const SizedBox(
                    width: 24,
                    height: 24,
                  ),
          ),
        ],
      ),
    );
  }
}