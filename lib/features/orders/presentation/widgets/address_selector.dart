// ============================================
// SÉLECTEUR D'ADRESSE DE LIVRAISON - PREMIUM
// ============================================
// Permet de choisir ou ajouter une adresse
// avec animations et états. Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AddressSelector extends StatefulWidget {
  final List<AddressData> addresses;
  final AddressData? selectedAddress;
  final ValueChanged<AddressData?>? onAddressSelected;
  final VoidCallback? onAddAddress;

  const AddressSelector({
    super.key,
    required this.addresses,
    this.selectedAddress,
    this.onAddressSelected,
    this.onAddAddress,
  });

  @override
  State<AddressSelector> createState() => _AddressSelectorState();
}

class _AddressSelectorState extends State<AddressSelector> {
  AddressData? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedAddress;
  }

  @override
  void didUpdateWidget(AddressSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedAddress != oldWidget.selectedAddress) {
      _selected = widget.selectedAddress;
    }
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre
        const Text(
          'ADRESSE DE LIVRAISON',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
            letterSpacing: 1.5,
          ),
        ),

        const SizedBox(height: 10),

        // Liste des adresses
        if (widget.addresses.isEmpty)
          _buildNoAddress()
        else
          ...widget.addresses.map((address) {
            final isSelected = _selected?.id == address.id;
            return _buildAddressCard(address, isSelected);
          }),

        const SizedBox(height: 10),

        // Bouton ajouter
        GestureDetector(
          onTap: widget.onAddAddress,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                style: BorderStyle.solid,
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_location_alt_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
                SizedBox(width: 6),
                Text(
                  'Ajouter une adresse',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================
  // PAS D'ADRESSE
  // ============================================

  Widget _buildNoAddress() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 20,
            color: AppColors.textLight,
          ),
          SizedBox(width: 10),
          Flexible(
            child: Text(
              'Aucune adresse enregistrée',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // CARTE D'ADRESSE
  // ============================================

  Widget _buildAddressCard(AddressData address, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selected = address;
        });
        widget.onAddressSelected?.call(address);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 6,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Radio
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textLight,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Container(
                      margin: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),

            const SizedBox(width: 10),

            // Icône
            Icon(
              address.type == 'work'
                  ? Icons.work_outline
                  : Icons.home_outlined,
              size: 18,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),

            const SizedBox(width: 10),

            // Informations
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.fullName,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    address.phone,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    address.fullAddress,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Badge par défaut
            if (address.isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Défaut',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// DONNÉES D'ADRESSE
// ============================================

class AddressData {
  final int id;
  final String fullName;
  final String phone;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String? state;
  final String country;
  final String type;
  final bool isDefault;

  const AddressData({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    this.state,
    this.country = 'RDC',
    this.type = 'home',
    this.isDefault = false,
  });

  /// Adresse complète
  String get fullAddress {
    final parts = <String>[];
    parts.add(addressLine1);
    if (addressLine2 != null) parts.add(addressLine2!);
    parts.add(city);
    if (state != null) parts.add(state!);
    parts.add(country);
    return parts.join(', ');
  }
}