// ============================================
// ÉCRAN SUPPORT - VERSION PREMIUM
// ============================================
// Centre d'aide avec recherche, catégories,
// FAQs populaires et contact. Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../providers/support_provider.dart';
import '../widgets/support_option_card.dart';
import '../widgets/faq_card.dart';
import 'dart:async';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
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

  Future<void> _loadData() async {
    final provider = context.read<SupportProvider>();
    await provider.loadFaqs();
  }

  // ============================================
  // RECHERCHE AVEC DEBOUNCE
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
          'Aide & Support',
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

          return RefreshIndicator(
            onRefresh: provider.refreshFaqs,
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ============================================
                  // TITRE
                  // ============================================
                  const Text(
                    'Comment pouvons-nous vous aider ?',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ============================================
                  // BARRE DE RECHERCHE
                  // ============================================
                  Container(
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
                              hintText: 'Rechercher une question...',
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

                  const SizedBox(height: 25),

                  // ============================================
                  // CATÉGORIES D'AIDE
                  // ============================================
                  const Text(
                    'BESOIN D\'AIDE RAPIDEMENT ?',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                      letterSpacing: 1.5,
                    ),
                  ),

                  const SizedBox(height: 12),

                  SupportOptionCard(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Mes commandes',
                    subtitle: 'Suivre, annuler une commande',
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.orders);
                    },
                  ),

                  SupportOptionCard(
                    icon: Icons.credit_card_outlined,
                    title: 'Paiements',
                    subtitle: 'Mobile Money, remboursements',
                    color: AppColors.warning,
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.faq);
                    },
                  ),

                  SupportOptionCard(
                    icon: Icons.local_shipping_outlined,
                    title: 'Livraison',
                    subtitle: 'Délais, frais et zones',
                    color: AppColors.success,
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.faq);
                    },
                  ),

                  SupportOptionCard(
                    icon: Icons.person_outline,
                    title: 'Mon compte',
                    subtitle: 'Profil, sécurité, adresses',
                    color: AppColors.info,
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.profile);
                    },
                  ),

                  const SizedBox(height: 25),

                  // ============================================
                  // QUESTIONS FRÉQUENTES
                  // ============================================
                  if (provider.popularFaqs.isNotEmpty) ...[
                    const Text(
                      'QUESTIONS FRÉQUENTES',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        letterSpacing: 1.5,
                      ),
                    ),

                    const SizedBox(height: 10),

                    ...provider.popularFaqs.take(3).map((faq) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: FaqCard(
                          faq: faq,
                          onTap: () {
                            Navigator.of(context).pushNamed(AppRoutes.faq);
                          },
                        ),
                      );
                    }),

                    const SizedBox(height: 5),

                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(AppRoutes.faq);
                        },
                        child: const Text(
                          'VOIR TOUTES LES FAQ',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 15),

                  // ============================================
                  // CONTACT
                  // ============================================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Vous ne trouvez pas la réponse ?',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Notre équipe est là pour vous aider.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pushNamed(AppRoutes.contactUs);
                            },
                            icon: const Icon(Icons.chat_outlined, size: 18),
                            label: const Text(
                              'CONTACTER SHOPPRO',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}