// Section Flash Sale avec compte à rebours
// Affiche les produits en vente flash avec timer

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/widgets/product_card.dart';
import '../../../products/presentation/widgets/shimmer_product_card.dart';

class FlashSaleSection extends StatefulWidget {
  final List<Product> products;
  final bool isLoading;
  final DateTime? endTime;
  final VoidCallback? onSeeAll;
  final ValueChanged<Product>? onProductTap;

  const FlashSaleSection({
    super.key,
    required this.products,
    this.isLoading = false,
    this.endTime,
    this.onSeeAll,
    this.onProductTap,
  });

  @override
  State<FlashSaleSection> createState() => _FlashSaleSectionState();
}

class _FlashSaleSectionState extends State<FlashSaleSection> {
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Démarrer le compte à rebours
  void _startCountdown() {
    final endTime = widget.endTime ?? DateTime.now().add(const Duration(hours: 2));

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      setState(() {
        _remainingTime = endTime.difference(DateTime.now());
      });

      if (_remainingTime.inSeconds > 0) {
        _startCountdown();
      }
    });
  }

  // Formater le temps restant
  String get _formattedTime {
    if (_remainingTime.inSeconds <= 0) return 'TERMINÉ';

    final hours = _remainingTime.inHours.toString().padLeft(2, '0');
    final minutes = (_remainingTime.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_remainingTime.inSeconds % 60).toString().padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête : Titre + Timer + Voir tout
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // Titre
              const Row(
                children: [
                  Icon(
                    Icons.bolt,
                    size: 18,
                    color: AppColors.error,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'FLASH SALE',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 10),

              // Timer
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.timer,
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formattedTime,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Voir tout
              GestureDetector(
                onTap: widget.onSeeAll,
                child: const Text(
                  'Voir tout',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Liste horizontale
        if (widget.isLoading)
          const ShimmerProductHorizontal(itemCount: 4)
        else if (widget.products.isEmpty)
          const SizedBox.shrink()
        else
          SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: widget.products.length,
              itemBuilder: (context, index) {
                final product = widget.products[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: SizedBox(
                    width: 150,
                    child: ProductCard(
                      product: product,
                      onTap: widget.onProductTap,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}