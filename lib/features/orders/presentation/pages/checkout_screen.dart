// ============================================
// ÉCRAN DE PAIEMENT (CHECKOUT) - VERSION PREMIUM
// ============================================
// Processus complet : adresse → livraison → paiement → confirmation.
// Design conforme à la vision ShopPro.
// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../orders/presentation/providers/order_provider.dart';
import '../../../orders/domain/entities/order_item.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../../../notifications/domain/entities/app_notification.dart';
import '../../../addresses/presentation/providers/address_provider.dart';
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

  List<AddressData> _addresses = const [];

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
      color: AppColors.warning,
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAddresses();
    });
  }

  // ============================================
  // CHARGEMENT DES ADRESSES
  // ============================================

  Future<void> _loadAddresses() async {
    final addressProvider = context.read<AddressProvider>();
    await addressProvider.loadAddresses();

    if (mounted) {
      setState(() {
        _addresses = addressProvider.addresses.map((a) {
          return AddressData(
            id: a.id,
            fullName: a.fullName,
            phone: a.phone,
            addressLine1: a.addressLine1,
            addressLine2: a.addressLine2,
            city: a.city,
            state: a.state,
            country: a.country,
            type: a.type,
            isDefault: a.isDefault,
          );
        }).toList();

        if (_selectedAddress == null && _addresses.isNotEmpty) {
          _selectedAddress = _addresses.firstWhere(
            (a) => a.isDefault,
            orElse: () => _addresses.first,
          );
        }
      });
    }
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

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
            // ============================================
            // ADRESSE
            // ============================================
            AddressSelector(
              addresses: _addresses,
              selectedAddress: _selectedAddress,
              onAddressSelected: (address) {
                setState(() {
                  _selectedAddress = address;
                });
              },
              onAddAddress: () {
                Navigator.of(context)
                    .pushNamed(AppRoutes.addressForm)
                    .then((result) {
                  if (result == true && mounted) {
                    _loadAddresses();
                  }
                });
              },
            ),

            const SizedBox(height: 20),
            const Divider(height: 1),

            const SizedBox(height: 15),

            // ============================================
            // LIVRAISON
            // ============================================
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

            // ============================================
            // PAIEMENT
            // ============================================
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

            // ============================================
            // RÉSUMÉ
            // ============================================
            CartSummary(cart: cartProvider.cart),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
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
              ElevatedButton(
                onPressed: _isProcessing
                    ? null
                    : () => _showConfirmationDialog(cartProvider),
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
                  shadowColor: AppColors.primary.withValues(alpha: 0.3),
                  disabledBackgroundColor: AppColors.borderColor,
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

  // ============================================
  // DIALOG DE CONFIRMATION
  // ============================================

  void _showConfirmationDialog(CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Confirmer la commande ?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${cartProvider.totalItems} article${cartProvider.totalItems > 1 ? 's' : ''}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Total : ${cartProvider.cart.formattedTotal}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Livraison : ${_selectedShipping?.name ?? 'Non sélectionnée'}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Modifier',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _confirmOrder(cartProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'CONFIRMER',
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

  // ============================================
  // CONFIRMATION DE LA COMMANDE
  // ============================================

  Future<void> _confirmOrder(CartProvider cartProvider) async {
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
        final notificationProvider = context.read<NotificationProvider>();
        await notificationProvider.addNotification(
          AppNotification(
            id: DateTime.now().millisecondsSinceEpoch,
            title: 'Commande confirmée !',
            body: 'Votre commande ${order.orderNumber} a été enregistrée avec succès.',
            type: 'order',
            createdAt: DateTime.now(),
          ),
        );

        // Vider le panier
        await cartProvider.clearCart();

        // Naviguer vers le paiement
        if (mounted) {
          Navigator.of(context).pushNamed(
            AppRoutes.payment,
            arguments: {'order': order},
          );
        }
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

  // ============================================
  // AFFICHER UNE ERREUR
  // ============================================

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
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}