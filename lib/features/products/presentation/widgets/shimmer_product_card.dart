// Carte produit avec animation Shimmer
// Affiche un placeholder animé pendant le chargement

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';

class ShimmerProductCard extends StatelessWidget {
  final double height;
  final double width;
  final bool isGrid;

  const ShimmerProductCard({
    super.key,
    this.height = 280,
    this.width = 180,
    this.isGrid = true,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.borderColor.withValues(alpha: 0.5),
      highlightColor: Colors.white,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: isGrid ? height * 0.5 : 100,
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
            ),

            // Informations
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom placeholder
                    Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: width * 0.7,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Prix placeholder
                    Container(
                      width: width * 0.5,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),

                    const Spacer(),

                    // Badge placeholder
                    Container(
                      width: width * 0.4,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bouton placeholder
            Container(
              height: 35,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Grille de shimmer
class ShimmerProductGrid extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;

  const ShimmerProductGrid({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.65,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const ShimmerProductCard(isGrid: true);
      },
    );
  }
}

// Liste de shimmer
class ShimmerProductList extends StatelessWidget {
  final int itemCount;

  const ShimmerProductList({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Shimmer.fromColors(
            baseColor: AppColors.borderColor.withValues(alpha: 0.5),
            highlightColor: Colors.white,
            period: const Duration(milliseconds: 1500),
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.borderColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  // Image
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(16),
                      ),
                    ),
                  ),
                  // Informations
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 150,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 80,
                            height: 14,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Section horizontale de shimmer
class ShimmerProductHorizontal extends StatelessWidget {
  final int itemCount;

  const ShimmerProductHorizontal({
    super.key,
    this.itemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.only(right: 12),
            child: ShimmerProductCard(
              width: 160,
              height: 250,
              isGrid: false,
            ),
          );
        },
      ),
    );
  }
}