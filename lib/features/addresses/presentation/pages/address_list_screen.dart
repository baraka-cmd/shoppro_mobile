// Écran de liste des adresses
// Affiche toutes les adresses avec actions

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
    _loadAddresses();
  }

  // Charger les adresses
  Future<void> _loadAddresses() async {
    final provider = context.read<AddressProvider>();
    await provider.loadAddresses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
                        : () => _showDeleteDialog(provider, address.id),
                    onSetDefault: widget.isSelectable
                        ? null
                        : () => provider.setDefaultAddress(address.id),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Naviguer vers le formulaire
  void _navigateToForm({dynamic address}) {
    Navigator.of(context)
        .pushNamed(
          AppRoutes.addressForm,
          arguments: address != null ? {'address': address} : null,
        )
        .then((result) {
          if (result == true) {
            _loadAddresses();
          }
        });
  }

  // Dialog de suppression
  void _showDeleteDialog(AddressProvider provider, int addressId) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Supprimer l\'adresse ?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          content: const Text(
            'Cette action est irréversible.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Annuler',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await provider.removeAddress(addressId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Supprimer',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}