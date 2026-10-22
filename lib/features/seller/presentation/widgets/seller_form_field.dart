// ============================================
// WIDGET : SellerFormField
// ============================================
// Champ de formulaire professionnel pour le module vendeur.
//
// Fonctionnalités :
//   - Label flottant personnalisé (au-dessus du champ)
//   - Icône à gauche (optionnelle)
//   - Icône suffixe (optionnelle, ex: œil pour mot de passe)
//   - Validation inline avec message d'erreur rouge
//   - Compteur de caractères (optionnel)
//   - Champ obligatoire (astérisque)
//   - Champ multi-ligne (textarea)
//   - Design cohérent ShopPro (Poppins, orange accent vendeur)
//   - Focus animé avec bordure orange
//
// Usage :
//   SellerFormField(
//     label: 'Nom du produit',
//     hint: 'Ex: iPhone 15',
//     controller: _nameController,
//     isRequired: true,
//     validator: (v) => v?.isEmpty == true ? 'Obligatoire' : null,
//   )
// ============================================

// Flutter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Core
import '../../../../core/constants/app_colors.dart';

// ============================================
// WIDGET PRINCIPAL
// ============================================

class SellerFormField extends StatefulWidget {
  /// Label affiché au-dessus du champ.
  final String label;

  /// Texte d'aide (placeholder) affiché dans le champ vide.
  final String? hint;

  /// Texte d'aide affiché sous le label (description).
  final String? helperText;

  /// Contrôleur du champ.
  final TextEditingController? controller;

  /// Type de clavier (text, number, email, etc.).
  final TextInputType? keyboardType;

  /// Icône affichée à gauche du champ.
  final IconData? prefixIcon;

  /// Widget affiché à droite du champ (ex: icône œil).
  final Widget? suffixWidget;

  /// Masquer le texte (mot de passe).
  final bool obscureText;

  /// Nombre de lignes (1 = champ simple, >1 = textarea).
  final int maxLines;

  /// Nombre maximum de caractères (affiche un compteur si défini).
  final int? maxLength;

  /// Le champ est-il obligatoire ? (affiche un astérisque)
  final bool isRequired;

  /// Le champ est-il désactivé ?
  final bool enabled;

  /// Fonction de validation.
  final String? Function(String?)? validator;

  /// Callback quand la valeur change.
  final void Function(String)? onChanged;

  /// Callback quand le champ est soumis (clavier "Entrée").
  final void Function(String)? onSubmitted;

  /// Focus node externe (pour gérer le focus entre champs).
  final FocusNode? focusNode;

  /// Formatters (pour limiter les caractères, formatage auto).
  final List<TextInputFormatter>? inputFormatters;

  /// Texte initial (si pas de controller).
  final String? initialValue;

  /// Afficher un bouton pour effacer le contenu.
  final bool showClearButton;

  /// Autofocus au chargement.
  final bool autofocus;

  /// Action du clavier quand on appuie sur "Entrée".
  final TextInputAction? textInputAction;

  const SellerFormField({
    super.key,
    required this.label,
    this.hint,
    this.helperText,
    this.controller,
    this.keyboardType,
    this.prefixIcon,
    this.suffixWidget,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.isRequired = false,
    this.enabled = true,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.inputFormatters,
    this.initialValue,
    this.showClearButton = false,
    this.autofocus = false,
    this.textInputAction,
  });

  @override
  State<SellerFormField> createState() => _SellerFormFieldState();
}

class _SellerFormFieldState extends State<SellerFormField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ??
        TextEditingController(text: widget.initialValue);

    _focusNode = widget.focusNode ?? FocusNode();

    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.removeListener(_onTextChange);

    // Ne pas disposer les controllers/nodes fournis par le parent
    if (widget.controller == null) _controller.dispose();
    if (widget.focusNode == null) _focusNode.dispose();

    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _onTextChange() {
    if (widget.showClearButton) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ============================================
        // LABEL
        // ============================================
        _buildLabel(),

        const SizedBox(height: 8),

        // ============================================
        // CHAMP
        // ============================================
        TextFormField(
          textInputAction: widget.textInputAction,
          controller: _controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          enabled: widget.enabled,
          validator: (value) {
            final error = widget.validator?.call(value);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _hasError = error != null;
                });
              }
            });
            return error;
          },
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          inputFormatters: widget.inputFormatters,
          autofocus: widget.autofocus,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: widget.enabled
                ? AppColors.textPrimary
                : AppColors.textTertiary,
          ),
          cursorColor: AppColors.warning,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textTertiary,
            ),
            helperText: widget.helperText,
            helperStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColors.textTertiary,
            ),
            errorStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.error,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 14, right: 10),
                    child: Icon(
                      widget.prefixIcon,
                      size: 18,
                      color: _isFocused
                          ? AppColors.warning
                          : AppColors.textTertiary,
                    ),
                  )
                : null,
            prefixIconConstraints: widget.prefixIcon != null
                ? const BoxConstraints(minWidth: 0, minHeight: 0)
                : null,
            suffixIcon: _buildSuffixIcon(),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            filled: true,
            fillColor: widget.enabled
                ? (_isFocused
                    ? AppColors.warning.withValues(alpha: 0.04)
                    : AppColors.surfaceAlt)
                : AppColors.surfaceAlt.withValues(alpha: 0.5),
            contentPadding: EdgeInsets.symmetric(
              horizontal: widget.prefixIcon != null ? 4 : 16,
              vertical: widget.maxLines > 1 ? 14 : 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _hasError ? AppColors.error : Colors.transparent,
                width: _hasError ? 1.2 : 0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _hasError ? AppColors.error : AppColors.warning,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1.2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1.5,
              ),
            ),
            counterStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: AppColors.textTertiary,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================
  // LABEL
  // ============================================

  Widget _buildLabel() {
    return Row(
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _hasError ? AppColors.error : AppColors.textPrimary,
          ),
        ),
        if (widget.isRequired) ...[
          const SizedBox(width: 2),
          const Text(
            '*',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }

  // ============================================
  // SUFFIX ICON
  // ============================================

  Widget? _buildSuffixIcon() {
    // Si un widget suffixe est fourni, on l'utilise
    if (widget.suffixWidget != null) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: widget.suffixWidget,
      );
    }

    // Bouton pour effacer le contenu
    if (widget.showClearButton && _controller.text.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: IconButton(
          icon: const Icon(
            Icons.clear_rounded,
            size: 18,
            color: AppColors.textTertiary,
          ),
          onPressed: () {
            _controller.clear();
            widget.onChanged?.call('');
          },
          splashRadius: 20,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      );
    }

    return null;
  }
}