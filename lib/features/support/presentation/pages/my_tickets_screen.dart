// ============================================
// ÉCRAN MES TICKETS - VERSION PREMIUM
// ============================================
// Affiche les tickets de support de l'utilisateur
// avec filtres et actions. Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../providers/support_provider.dart';
import '../widgets/ticket_card.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTickets();
    });
  }

  // ============================================
  // CHARGEMENT
  // ============================================

  Future<void> _loadTickets() async {
    final provider = context.read<SupportProvider>();
    await provider.loadTickets();
  }

  // ============================================
  // FILTRAGE
  // ============================================

  List<dynamic> _getFilteredTickets(SupportProvider provider) {
    switch (_selectedFilter) {
      case 'active':
        return provider.activeTickets;
      case 'resolved':
        return provider.resolvedTickets;
      case 'closed':
        return provider.closedTickets;
      default:
        return provider.tickets;
    }
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
          'Mes demandes',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.contactUs);
            },
            icon: const Icon(
              Icons.add,
              color: AppColors.primary,
              size: 24,
            ),
            tooltip: 'Nouvelle demande',
          ),
        ],
      ),
      body: Consumer<SupportProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.tickets.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (provider.tickets.isEmpty) {
            return _buildEmptyState();
          }

          final filteredTickets = _getFilteredTickets(provider);

          return Column(
            children: [
              // ============================================
              // CHIPS DE FILTRES
              // ============================================
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  children: [
                    _buildFilterChip(
                      label: 'Toutes',
                      count: provider.ticketsCount,
                      isSelected: _selectedFilter == 'all',
                      onTap: () {
                        setState(() {
                          _selectedFilter = 'all';
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Actives',
                      count: provider.activeTickets.length,
                      isSelected: _selectedFilter == 'active',
                      color: AppColors.primary,
                      onTap: () {
                        setState(() {
                          _selectedFilter = 'active';
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Résolues',
                      count: provider.resolvedTickets.length,
                      isSelected: _selectedFilter == 'resolved',
                      color: AppColors.success,
                      onTap: () {
                        setState(() {
                          _selectedFilter = 'resolved';
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Fermées',
                      count: provider.closedTickets.length,
                      isSelected: _selectedFilter == 'closed',
                      color: AppColors.textSecondary,
                      onTap: () {
                        setState(() {
                          _selectedFilter = 'closed';
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ============================================
              // LISTE DES TICKETS
              // ============================================
              Expanded(
                child: filteredTickets.isEmpty
                    ? _buildEmptyFilteredState()
                    : RefreshIndicator(
                        onRefresh: _loadTickets,
                        color: AppColors.primary,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: filteredTickets.length,
                          itemBuilder: (context, index) {
                            final ticket = filteredTickets[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: TicketCard(
                                ticket: ticket,
                                onTap: () {
                                  // TODO: Navigation vers détail du ticket
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Ticket ${ticket.ticketNumber}',
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 13,
                                        ),
                                      ),
                                      backgroundColor: AppColors.textPrimary,
                                      behavior: SnackBarBehavior.floating,
                                      margin: const EdgeInsets.all(20),
                                      duration: const Duration(seconds: 2),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(12)),
                                      ),
                                    ),
                                  );
                                },
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
  // CHIP DE FILTRE
  // ============================================

  Widget _buildFilterChip({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    Color color = AppColors.primary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppColors.borderColor,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.3)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================
  // ÉTAT VIDE (AUCUN TICKET)
  // ============================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.support_agent_outlined,
                size: 45,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aucune demande',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vous n\'avez encore créé aucune demande\nde support.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.contactUs);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'CRÉER UNE DEMANDE',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // ÉTAT VIDE (FILTRE SANS RÉSULTAT)
  // ============================================

  Widget _buildEmptyFilteredState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 50,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 15),
          const Text(
            'Aucune demande dans cette catégorie',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}