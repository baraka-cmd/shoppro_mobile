// ============================================
// WIDGET D'HISTORIQUE DE RECHERCHE - PREMIUM
// ============================================
// Affiche les recherches récentes avec suppression
// individuelle animée et effacement global.
// Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';

class SearchHistory extends StatefulWidget {
  final ValueChanged<String>? onSearchSelected;
  final VoidCallback? onClearAll;

  const SearchHistory({
    super.key,
    this.onSearchSelected,
    this.onClearAll,
  });

  @override
  State<SearchHistory> createState() => _SearchHistoryState();
}

class _SearchHistoryState extends State<SearchHistory> {
  List<String> _history = [];
  static const String _historyKey = 'search_history';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // ============================================
  // CHARGEMENT
  // ============================================

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];
    if (mounted) {
      setState(() {
        _history = history;
      });
    }
  }

  // ============================================
  // AJOUTER À L'HISTORIQUE (statique)
  // ============================================

  static Future<void> addToHistory(String query) async {
    if (query.trim().isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];

    history.removeWhere((item) => item.toLowerCase() == query.toLowerCase());
    history.insert(0, query);

    if (history.length > 10) {
      history.removeRange(10, history.length);
    }

    await prefs.setStringList(_historyKey, history);
  }

  // ============================================
  // SUPPRESSION INDIVIDUELLE
  // ============================================

  Future<void> _removeFromHistory(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];
    history.removeWhere((item) => item == query);
    await prefs.setStringList(_historyKey, history);

    if (mounted) {
      setState(() {
        _history = history;
      });
    }
  }

  // ============================================
  // EFFACEMENT GLOBAL
  // ============================================

  Future<void> _clearAllHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);

    if (mounted) {
      setState(() {
        _history = [];
      });
    }

    widget.onClearAll?.call();
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    if (_history.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ============================================
        // EN-TÊTE
        // ============================================
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.history,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'RECHERCHES RÉCENTES',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _clearAllHistory,
                child: const Text(
                  'Effacer tout',
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

        const SizedBox(height: 10),

        // ============================================
        // LISTE DE L'HISTORIQUE (avec animations)
        // ============================================
        ..._history.asMap().entries.map((entry) {
          final index = entry.key;
          final query = entry.value;

          return AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: 1.0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 250),
              offset: Offset.zero,
              child: ListTile(
                dense: true,
                leading: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.history,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                title: Text(
                  query,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                trailing: IconButton(
                  onPressed: () => _removeFromHistory(query),
                  icon: const Icon(
                    Icons.close,
                    size: 14,
                    color: AppColors.textLight,
                  ),
                  tooltip: 'Supprimer',
                ),
                onTap: () {
                  widget.onSearchSelected?.call(query);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                hoverColor: AppColors.surface,
              ),
            ),
          );
        }),

        const SizedBox(height: 5),
      ],
    );
  }
}