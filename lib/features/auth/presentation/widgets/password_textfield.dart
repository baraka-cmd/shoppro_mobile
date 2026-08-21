// Champ de mot de passe personnalisé
// Avec toggle de visibilité animé et indicateur de force

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final bool showStrengthIndicator;
  final ValueChanged<String>? onSubmitted;

  const PasswordTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.validator,
    this.textInputAction = TextInputAction.done,
    this.showStrengthIndicator = false,
    this.onSubmitted,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _isObscured = true;
  bool _isFocused = false;
  String _passwordStrength = '';
  Color _strengthColor = AppColors.textLight;

  // Vérifier la force du mot de passe
  void _checkPasswordStrength(String password) {
    if (password.isEmpty) {
      _passwordStrength = '';
      _strengthColor = AppColors.textLight;
      return;
    }

    if (password.length < 6) {
      _passwordStrength = 'Faible';
      _strengthColor = AppColors.error;
    } else if (password.length < 10) {
      _passwordStrength = 'Moyen';
      _strengthColor = AppColors.warning;
    } else {
      _passwordStrength = 'Fort';
      _strengthColor = AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(
            widget.label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Champ de mot de passe
          Focus(
            onFocusChange: (focused) {
              setState(() {
                _isFocused = focused;
              });
            },
            child: TextFormField(
              controller: widget.controller,
              obscureText: _isObscured,
              textInputAction: widget.textInputAction,
              validator: widget.validator,
              onChanged: (value) {
                if (widget.showStrengthIndicator) {
                  setState(() {
                    _checkPasswordStrength(value);
                  });
                }
              },
              onFieldSubmitted: widget.onSubmitted,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                letterSpacing: 1.5,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textLight,
                  letterSpacing: 0,
                ),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isFocused
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.lock,
                    size: 20,
                    color: _isFocused
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      return RotationTransition(
                        turns: animation,
                        child: child,
                      );
                    },
                    child: Icon(
                      _isObscured
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      key: ValueKey<bool>(_isObscured),
                      size: 20,
                      color: _isFocused
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.borderColor,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.borderColor,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.error,
                    width: 1.5,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.error,
                    width: 2,
                  ),
                ),
                errorStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.error,
                ),
              ),
            ),
          ),
          
          // Indicateur de force (optionnel)
          if (widget.showStrengthIndicator && widget.controller.text.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                // Barres de force
                Expanded(
                  child: Row(
                    children: List.generate(3, (index) {
                      final isActive = _getActiveBars(index);
                      return Expanded(
                        child: Container(
                          height: 4,
                          margin: const EdgeInsets.only(right: 5),
                          decoration: BoxDecoration(
                            color: isActive
                                ? _strengthColor
                                : AppColors.borderColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(width: 10),
                // Texte de force
                Text(
                  _passwordStrength,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _strengthColor,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Déterminer combien de barres sont actives
  bool _getActiveBars(int index) {
    if (_passwordStrength == 'Faible') return index == 0;
    if (_passwordStrength == 'Moyen') return index <= 1;
    if (_passwordStrength == 'Fort') return true;
    return false;
  }
}