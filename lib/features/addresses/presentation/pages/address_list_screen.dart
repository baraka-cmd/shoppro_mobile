// ============================================
// ÉCRAN DE LISTE DES ADRESSES - VERSION PREMIUM
// ============================================
// Affiche toutes les adresses avec actions,
// sélection et suppression avec annulation.
// Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../providers/address_provider.dart';
import '../widgets/address_card.dart';
import '../widgets/empty_addresses.dart';

class AddressListScreen extends StatefulWidget {
  final bool isSelectable;
  final ValueChanged<int>? onAddressSelected;

  const AddressListScreen({
    super.key,
    this.isSelectable = false,
    this.onAddressSelected,
  });

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  int? _selectedAddressId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAddresses();
    });
  }

  // ============================================
  // CHARGEMENT
  // ============================================

  Future<void> _loadAddresses() async {
    final provider = context.read<AddressProvider>();
    await provider.loadAddresses();
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
        title: Consumer<AddressProvider>(
          builder: (context, provider, child) {
            return Text(
              provider.isEmpty
                  ? 'Mes Adresses'
                  : 'Mes Adresses (${provider.addressesCount})',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () => _navigateToForm(),
            icon: const Icon(
              Icons.add,
              color: AppColors.primary,
              size: 24,
            ),
            tooltip: 'Ajouter une adresse',
          ),
        ],
      ),
      body: Consumer<AddressProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (provider.isEmpty) {
            return EmptyAddresses(
              onAddAddress: _navigateToForm,
            );
          }

          return RefreshIndicator(
            onRefresh: _loadAddresses,
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: provider.addresses.length,
              itemBuilder: (context, index) {
                final address = provider.addresses[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AddressCard(
                    address: address,
                    isSelectable: widget.isSelectable,
                    isSelected: _selectedAddressId == address.id,
                    onTap: widget.isSelectable
                        ? () {
                            setState(() {
                              _selectedAddressId = address.id;
                            });
                            widget.onAddressSelected?.call(address.id);
                            Navigator.of(context).pop();
                          }
                        : null,
                    onEdit: widget.isSelectable
                        ? null
                        : () => _navigateToForm(address: address),
                    onDelete: widget.isSelectable
                        ? null
                        : () => _handleDelete(provider, address.id),
                    onSetDefault: widget.isSelectable
                        ? null
                        : () => _handleSetDefault(provider, address.id),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: widget.isSelectable
          ? null
          : FloatingActionButton(
              onPressed: () => _navigateToForm(),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            ),
    );
  }

  // ============================================
  // NAVIGATION
  // ============================================

  void _navigateToForm({dynamic address}) {
    Navigator.of(context)
        .pushNamed(
          AppRoutes.addressForm,
          arguments: address != null ? {'address': address} : null,
        )
        .then((result) {
          if (result == true && mounted) {
            _loadAddresses();
          }
        });
  }

  // ============================================
  // SUPPRESSION AVEC ANNULATION
  // ============================================

  Future<void> _handleDelete(AddressProvider provider, int addressId) async {
    final success = await provider.removeAddress(addressId);

    if (!mounted || !success) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Adresse supprimée',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        action: SnackBarAction(
          label: 'ANNULER',
          textColor: AppColors.error,
          onPressed: () {
            provider.undoLastAction();
          },
        ),
      ),
    );
  }

  // ============================================
  // DÉFINIR COMME DÉFAUT
  // ============================================

  Future<void> _handleSetDefault(AddressProvider provider, int addressId) async {
    final success = await provider.setDefaultAddress(addressId);

    if (!mounted || !success) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Adresse définie comme défaut',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(20),
        duration: Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}