// ============================================
// BARRE DE RECHERCHE PERSONNALISÉE - PREMIUM
// ============================================
// Avec auto-focus, effacement, debounce,
// micro-interactions ET recherche vocale.
// Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/voice_service.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final VoidCallback? onBack;
  final bool autoFocus;
  final Duration debounceDuration;
  final String hintText;
  final bool enableVoice; // 👈 NOUVEAU

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
    this.enableVoice = true, // 👈 NOUVEAU
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar>
    with SingleTickerProviderStateMixin {
  Timer? _debounce;
  bool _hasText = false;
  bool _isFocused = false;

  // ─────────────────────────────────────────────
  // VOCAL
  // ─────────────────────────────────────────────
  final VoiceService _voice = VoiceService();
  bool _isListening = false;
  bool _voiceAvailable = true;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _hasText = widget.controller.text.isNotEmpty;

    // Animation de pulsation du micro
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Préparer le service vocal
    _initVoice();
  }

  Future<void> _initVoice() async {
    final ok = await _voice.initialize();
    if (mounted) {
      setState(() => _voiceAvailable = ok);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.controller.removeListener(_onTextChanged);
    _voice.stopListening();
    _pulseController.dispose();
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
  // VOCAL — DÉMARRER / ARRÊTER
  // ============================================
  Future<void> _toggleVoice() async {
    if (_isListening) {
      await _voice.stopListening();
      if (mounted) {
        setState(() => _isListening = false);
      }
      return;
    }

    // Vérifier la disponibilité
    if (!_voiceAvailable) {
      final ok = await _voice.initialize();
      if (!ok) {
        _showSnack('Reconnaissance vocale non disponible');
        return;
      }
    }

    // Brancher les callbacks
    _voice.onResult = (words) {
      if (mounted && words.isNotEmpty) {
        widget.controller.text = words;
        widget.controller.selection = TextSelection.fromPosition(
          TextPosition(offset: words.length),
        );
      }
    };

    _voice.onDone = () {
      if (mounted) {
        setState(() => _isListening = false);
        // Lancer la recherche avec le texte final
        final finalText = widget.controller.text.trim();
        if (finalText.isNotEmpty) {
          widget.onSubmitted?.call(finalText);
        }
      }
    };

    _voice.onError = (error) {
      if (mounted) {
        setState(() => _isListening = false);
        _showSnack(error);
      }
    };

    final started = await _voice.startListening(
      localeId: 'fr_FR',
      listenFor: const Duration(seconds: 15),
      pauseFor: const Duration(seconds: 3),
    );

    if (mounted) {
      setState(() => _isListening = started);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
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
          color: _isListening
              ? AppColors.error
              : (_isFocused ? AppColors.primary : AppColors.borderColor),
          width: _isFocused || _isListening ? 2 : 1.5,
        ),
        boxShadow: _isFocused || _isListening
            ? [
                BoxShadow(
                  color: (_isListening ? AppColors.error : AppColors.primary)
                      .withValues(alpha: 0.15),
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
          Icon(
            Icons.search,
            size: 20,
            color: _isListening ? AppColors.error : AppColors.textSecondary,
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
                  hintText: _isListening
                      ? 'Parlez maintenant...'
                      : widget.hintText,
                  hintStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: _isListening
                        ? AppColors.error
                        : AppColors.textLight,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ),

          // ============================================
          // BOUTON MICRO (NOUVEAU)
          // ============================================
          if (widget.enableVoice && _voiceAvailable) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: _toggleVoice,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isListening ? _pulseAnimation.value : 1.0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _isListening
                            ? AppColors.error.withValues(alpha: 0.15)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        size: 18,
                        color: _isListening
                            ? AppColors.error
                            : AppColors.textSecondary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

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
                      margin: const EdgeInsets.only(left: 4),
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