// ============================================
// ÉCRAN FAQ - VERSION PREMIUM
// ============================================
// Affiche les questions fréquentes avec filtres
// par catégorie et recherche. Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/support_provider.dart';
import '../widgets/faq_card.dart';
import '../widgets/support_option_card.dart';
import 'dart:async';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFaqs();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // ============================================
  // CHARGEMENT
  // ============================================

  Future<void> _loadFaqs() async {
    final provider = context.read<SupportProvider>();
    await provider.loadFaqs();
  }

  // ============================================
  // RECHERCHE
  // ============================================

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      final provider = context.read<SupportProvider>();
      if (query.trim().isNotEmpty) {
        provider.searchFaqs(query);
      } else {
        provider.clearSearch();
        provider.loadFaqs();
      }
    });
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
        title: const Text(
          'FAQ',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Consumer<SupportProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.faqs.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============================================
              // BARRE DE RECHERCHE
              // ============================================
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          decoration: const InputDecoration(
                            hintText: 'Rechercher dans les questions...',
                            hintStyle: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              color: AppColors.textLight,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            provider.clearSearch();
                            provider.loadFaqs();
                          },
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: AppColors.textLight,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ============================================
              // CHIPS DE CATÉGORIES
              // ============================================
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildCategoryChip(
                      label: 'Toutes',
                      isSelected: provider.currentFaqFilter == 'all',
                      onTap: () {
                        provider.clearFaqFilter();
                      },
                    ),
                    ...provider.faqCategories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _buildCategoryChip(
                          label: category.name,
                          isSelected: provider.currentFaqFilter == category.id.toString(),
                          onTap: () {
                            provider.setFaqFilter(category.id.toString());
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // ============================================
              // LISTE DES FAQS
              // ============================================
              Expanded(
                child: provider.filteredFaqs.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: provider.refreshFaqs,
                        color: AppColors.primary,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: provider.filteredFaqs.length,
                          itemBuilder: (context, index) {
                            final faq = provider.filteredFaqs[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: FaqCard(
                                faq: faq,
                                onHelpful: () => provider.markFaqHelpful(faq.id),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================
  // CHIP DE CATÉGORIE
  // ============================================

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderColor,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  // ============================================
  // ÉTAT VIDE
  // ============================================

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.help_outline,
              size: 40,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Aucune question trouvée',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Essayez avec d\'autres mots-clés',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}