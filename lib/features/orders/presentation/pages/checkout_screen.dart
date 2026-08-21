// Écran de paiement (checkout)
// Processus complet : adresse → livraison → paiement → confirmation

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../../orders/presentation/providers/order_provider.dart';
import '../../../orders/domain/entities/order_item.dart';
import '../widgets/address_selector.dart';
import '../widgets/shipping_selector.dart';
import '../widgets/payment_selector.dart';
import '../../../cart/presentation/widgets/cart_summary.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  AddressData? _selectedAddress;
  ShippingMethodData? _selectedShipping;
  PaymentMethodData? _selectedPayment;
  bool _isProcessing = false;

  // Adresses de démonstration
  final List<AddressData> _addresses = const [
    AddressData(
      id: 1,
      fullName: 'Jean Kamga',
      phone: '+237 6 51 11 11 11',
      addressLine1: 'Bonamoussadi, Rue 123',
      addressLine2: 'Près de la pharmacie',
      city: 'Douala',
      state: 'Littoral',
      country: 'Cameroun',
      type: 'home',
      isDefault: true,
    ),
  ];

  // Méthodes de livraison
  final List<ShippingMethodData> _shippingMethods = const [
    ShippingMethodData(
      id: 1,
      name: 'Livraison Standard',
      code: 'standard',
      cost: 2000,
      minDays: 3,
      maxDays: 7,
      icon: Icons.local_shipping,
    ),
    ShippingMethodData(
      id: 2,
      name: 'Livraison Express',
      code: 'express',
      cost: 5000,
      minDays: 1,
      maxDays: 2,
      icon: Icons.flash_on,
    ),
    ShippingMethodData(
      id: 3,
      name: 'Point Relais',
      code: 'pickup',
      cost: 1000,
      minDays: 2,
      maxDays: 5,
      icon: Icons.store,
    ),
  ];

  // Méthodes de paiement
  final List<PaymentMethodData> _paymentMethods = const [
    PaymentMethodData(
      id: 1,
      name: 'Paiement à la livraison',
      code: 'cash_on_delivery',
      description: 'Payez en espèces à la réception',
      icon: Icons.payments,
      color: AppColors.success,
    ),
    PaymentMethodData(
      id: 2,
      name: 'Mobile Money',
      code: 'mobile_money',
      description: 'MTN Mobile Money, Orange Money',
      icon: Icons.phone_android,
      color: AppColors.secondary,
    ),
    PaymentMethodData(
      id: 3,
      name: 'Carte bancaire',
      code: 'card',
      description: 'Visa, Mastercard',
      icon: Icons.credit_card,
      color: AppColors.primary,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

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
        title: const Text(
          'Commande',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Adresse de livraison
            AddressSelector(
              addresses: _addresses,
              selectedAddress: _selectedAddress,
              onAddressSelected: (address) {
                setState(() {
                  _selectedAddress = address;
                });
              },
              onAddAddress: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ajout d\'adresse à venir'),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.all(20),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
            const Divider(height: 1),

            const SizedBox(height: 15),

            // Mode de livraison
            ShippingSelector(
              methods: _shippingMethods,
              selectedMethod: _selectedShipping,
              onMethodSelected: (method) {
                setState(() {
                  _selectedShipping = method;
                });
              },
            ),

            const SizedBox(height: 20),
            const Divider(height: 1),

            const SizedBox(height: 15),

            // Mode de paiement
            PaymentSelector(
              methods: _paymentMethods,
              selectedMethod: _selectedPayment,
              onMethodSelected: (method) {
                setState(() {
                  _selectedPayment = method;
                });
              },
            ),

            const SizedBox(height: 20),
            const Divider(height: 1),

            const SizedBox(height: 15),

            // Récapitulatif
            CartSummary(cart: cartProvider.cart),

            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              // Total
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      cartProvider.cart.formattedTotal,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // Bouton confirmer
              ElevatedButton(
                onPressed: _isProcessing
                    ? null
                    : () => _confirmOrder(cartProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'CONFIRMER',
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
      ),
    );
  }

  // Confirmer la commande
  Future<void> _confirmOrder(CartProvider cartProvider) async {
    // Vérifier les sélections
    if (_selectedAddress == null) {
      _showError('Veuillez sélectionner une adresse de livraison');
      return;
    }

    if (_selectedShipping == null) {
      _showError('Veuillez sélectionner un mode de livraison');
      return;
    }

    if (_selectedPayment == null) {
      _showError('Veuillez sélectionner un mode de paiement');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final orderProvider = context.read<OrderProvider>();

      // Convertir les items du panier en items de commande
      final orderItems = cartProvider.cart.activeItems.map((cartItem) {
        return OrderItem(
          id: cartItem.id,
          productId: cartItem.productId,
          productName: cartItem.name,
          productImage: cartItem.imageUrl,
          productSku: cartItem.sku,
          unitPrice: cartItem.unitPrice,
          discountPrice: cartItem.discountPrice,
          quantity: cartItem.quantity,
          variantName: cartItem.variantName,
          variantColor: cartItem.variantColor,
          variantSize: cartItem.variantSize,
        );
      }).toList();

      // Créer la commande
      final order = await orderProvider.createOrder(
        items: orderItems,
        subtotal: cartProvider.cart.subtotal,
        total: cartProvider.cart.total,
        shippingFee: _selectedShipping!.cost,
        discount: cartProvider.cart.itemsDiscount,
        couponDiscount: cartProvider.cart.couponDiscount,
        tax: cartProvider.cart.taxes,
        couponCode: cartProvider.cart.couponCode,
        shippingMethod: _selectedShipping!.code,
        paymentMethod: _selectedPayment!.code,
      );

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      if (order != null) {
        // Vider le panier
        await cartProvider.clearCart();

        // Afficher le succès
        _showSuccess(order.orderNumber);
      } else {
        _showError(orderProvider.errorMessage ?? 'Erreur lors de la commande');
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showError(e.toString());
    }
  }

  // Afficher une erreur
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  // Afficher le succès
  void _showSuccess(String orderNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Column(
            children: [
              Icon(
                Icons.check_circle,
                size: 60,
                color: AppColors.success,
              ),
              SizedBox(height: 10),
              Text(
                'Commande réussie !',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Votre commande a été passée avec succès.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                orderNumber,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushReplacementNamed('/orders');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'VOIR MES COMMANDES',
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