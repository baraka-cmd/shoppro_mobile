// Widget d'historique de recherche
// Affiche les recherches récentes avec suppression

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

  // Charger l'historique
  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];
    setState(() {
      _history = history;
    });
  }

  // Ajouter une recherche à l'historique
  static Future<void> addToHistory(String query) async {
    if (query.trim().isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];

    // Supprimer si déjà présent
    history.removeWhere((item) => item.toLowerCase() == query.toLowerCase());

    // Ajouter au début
    history.insert(0, query);

    // Limiter à 10 éléments
    if (history.length > 10) {
      history.removeRange(10, history.length);
    }

    await prefs.setStringList(_historyKey, history);
  }

  // Supprimer une recherche
  Future<void> _removeFromHistory(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];
    history.removeWhere((item) => item == query);
    await prefs.setStringList(_historyKey, history);

    setState(() {
      _history = history;
    });
  }

  // Effacer tout l'historique
  Future<void> _clearAllHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);

    setState(() {
      _history = [];
    });

    widget.onClearAll?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_history.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre + Effacer tout
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

        // Liste de l'historique
        ..._history.map((query) {
          return ListTile(
            dense: true,
            leading: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.background,
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
            ),
            onTap: () {
              widget.onSearchSelected?.call(query);
            },
          );
        }),

        const SizedBox(height: 5),
      ],
    );
  }
}