// ============================================
// CARTE FAQ - VERSION PREMIUM
// ============================================
// Affiche une question avec réponse dépliable,
// compteurs et bouton utile. Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/faq.dart';

class FaqCard extends StatefulWidget {
  final Faq faq;
  final VoidCallback? onTap;
  final VoidCallback? onHelpful;

  const FaqCard({
    super.key,
    required this.faq,
    this.onTap,
    this.onHelpful,
  });

  @override
  State<FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<FaqCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.5),
        ),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================
          // QUESTION (TOUJOURS VISIBLE)
          // ============================================
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
              widget.onTap?.call();
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Badge populaire
                  if (widget.faq.isPopular)
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.star,
                        size: 14,
                        color: AppColors.warning,
                      ),
                    )
                  else
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.help_outline,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      widget.faq.question,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Chevron animé
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ============================================
          // RÉPONSE (DÉPLIABLE)
          // ============================================
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1, color: AppColors.borderColor),
                  const SizedBox(height: 12),
                  Text(
                    widget.faq.answer,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Compteurs + bouton utile
                  Row(
                    children: [
                      // Vues
                      Icon(
                        Icons.visibility_outlined,
                        size: 12,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        widget.faq.formattedViewsCount,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          color: AppColors.textLight,
                        ),
                      ),

                      const SizedBox(width: 10),

                      // Utile
                      Icon(
                        Icons.thumb_up_outlined,
                        size: 12,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        widget.faq.formattedHelpfulCount,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          color: AppColors.textLight,
                        ),
                      ),

                      const Spacer(),

                      // Bouton "Utile"
                      GestureDetector(
                        onTap: widget.onHelpful,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.thumb_up,
                                size: 12,
                                color: AppColors.success,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Utile',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}