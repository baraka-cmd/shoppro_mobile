// Widget de suggestions de recherche
// Affiche les suggestions pendant la frappe

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../products/domain/entities/product.dart';

class SearchSuggestions extends StatelessWidget {
  final List<Product> products;
  final List<String> categories;
  final ValueChanged<String>? onSuggestionTap;
  final bool isLoading;

  const SearchSuggestions({
    super.key,
    required this.products,
    required this.categories,
    this.onSuggestionTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (products.isEmpty && categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Suggestions de produits
        if (products.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              'PRODUITS SUGGÉRÉS',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 1,
              ),
            ),
          ),
          ...products.take(5).map((product) {
            return ListTile(
              dense: true,
              leading: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.search,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              title: Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: Text(
                product.formattedCurrentPrice,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_upward,
                size: 14,
                color: AppColors.textLight,
              ),
              onTap: () => onSuggestionTap?.call(product.name),
            );
          }),
        ],

        // Suggestions de catégories
        if (categories.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              'CATÉGORIES SUGGÉRÉES',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 1,
              ),
            ),
          ),
          ...categories.take(3).map((category) {
            return ListTile(
              dense: true,
              leading: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.category,
                  size: 16,
                  color: AppColors.warning,
                ),
              ),
              title: Text(
                category,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                size: 16,
                color: AppColors.textLight,
              ),
              onTap: () => onSuggestionTap?.call(category),
            );
          }),
        ],

        const SizedBox(height: 10),
      ],
    );
  }

  // État de chargement
  Widget _buildLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(4, (index) {
        return Container(
          height: 45,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 100,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}