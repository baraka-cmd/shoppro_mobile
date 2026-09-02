// ============================================
// WIDGET : AdminSearchBar
// ============================================
// Barre de recherche réutilisable avec debounce.
// Design moderne avec icône, placeholder et bouton effacer.
// ============================================

// ============================================
// IMPORTS
// ============================================

// Dart
import 'dart:async';

// Flutter
import 'package:flutter/material.dart';

// Core
import '../../../../core/constants/app_colors.dart';

// ============================================
// WIDGET PRINCIPAL
// ============================================

/// Barre de recherche avec debounce intégré.
class AdminSearchBar extends StatefulWidget {
  final String placeholder;
  final ValueChanged<String> onSearch;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final Duration debounceDuration;
  final bool isLoading;
  final String? initialValue;
  final double height;
  final double? width;

  AdminSearchBar({
    super.key,
    this.placeholder = 'Rechercher...',
    required this.onSearch,
    this.onChanged,
    this.onClear,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.isLoading = false,
    this.initialValue,
    this.height = 40,
    this.width,
  });

  @override
  State<AdminSearchBar> createState() => _AdminSearchBarState();
}

// ============================================
// STATE
// ============================================

class _AdminSearchBarState extends State<AdminSearchBar> {
  // ============================================
  // CONTRÔLEURS
  // ============================================

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounceTimer;

  // ============================================
  // INIT
  // ============================================

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.borderColor,
        ),
      ),
      child: Row(
        children: [
          // ============================================
          // ICÔNE DE RECHERCHE
          // ============================================
          const Padding(
            padding: EdgeInsets.only(left: 12),
            child: Icon(
              Icons.search,
              size: 18,
              color: AppColors.textTertiary,
            ),
          ),

          const SizedBox(width: 8),

          // ============================================
          // CHAMP DE SAISIE
          // ============================================
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: _onTextChanged,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: widget.placeholder,
                hintStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppColors.textLight,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          // ============================================
          // INDICATEUR DE CHARGEMENT OU BOUTON EFFACER
          // ============================================
          if (widget.isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            )
          else if (_controller.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: IconButton(
                onPressed: _clearSearch,
                icon: const Icon(
                  Icons.close,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
                tooltip: 'Effacer',
                splashRadius: 16,
              ),
            ),
        ],
      ),
    );
  }

  // ============================================
  // MÉTHODES PRIVÉES
  // ============================================

  void _onTextChanged(String value) {
    widget.onChanged?.call(value);

    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDuration, () {
      widget.onSearch(value);
    });

    setState(() {});
  }

  void _clearSearch() {
    _debounceTimer?.cancel();
    _controller.clear();
    widget.onSearch('');
    widget.onClear?.call();
    setState(() {});
  }

  // ============================================
  // API PUBLIQUE
  // ============================================

  String get text => _controller.text;

  void setText(String value) {
    _controller.text = value;
    setState(() {});
  }

  void clear() {
    _clearSearch();
  }

  void focus() {
    _focusNode.requestFocus();
  }
}