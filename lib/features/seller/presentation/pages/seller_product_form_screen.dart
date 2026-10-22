// ============================================
// PAGE : SellerProductFormScreen
// ============================================
// Écran principal du formulaire de produit.
//
// Rôle :
//   - Orchestrer les 3 étapes du wizard
//   - Gérer la navigation (suivant / retour / annulation)
//   - Charger les catégories et marques
//   - Appeler le Provider à la fin pour créer/modifier
//   - Afficher un dialogue de confirmation avant sortie
//
// Structure :
//   - AppBar avec bouton fermer + titre dynamique
//   - Indicateur d'étapes cliquable
//   - PageView (3 pages : Info, Images, Pricing)
//   - Barre de navigation basse (Retour / Suivant / Créer)
// ============================================

// Flutter
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core
import '../../../../core/constants/app_colors.dart';

// Domain
import '../../domain/entities/seller_product.dart';

// Presentation
import '../providers/seller_product_provider.dart';
import '../widgets/seller_product_step_images.dart';
import '../widgets/seller_product_step_info.dart';
import '../widgets/seller_product_step_pricing.dart';
import 'seller_product_form_state.dart';

// ============================================
// PAGE PRINCIPALE
// ============================================

class SellerProductFormScreen extends StatefulWidget {
  /// Produit à modifier (null = création).
  final SellerProduct? product;

  const SellerProductFormScreen({super.key, this.product});

  @override
  State<SellerProductFormScreen> createState() =>
      _SellerProductFormScreenState();
}

class _SellerProductFormScreenState extends State<SellerProductFormScreen> {
  // ============================================
  // ÉTAT
  // ============================================

  late SellerProductFormState _formState;
  final PageController _pageController = PageController();

  // Métadonnées (catégories / marques)
  List<SellerProductCategory> _categories = [];
  List<SellerProductBrand> _brands = [];
  bool _isLoadingMetadata = true;

  // État de sauvegarde
  bool _isSaving = false;

  // ============================================
  // INIT
  // ============================================

  @override
  void initState() {
    super.initState();
    _formState = SellerProductFormState(product: widget.product);
    _formState.addListener(_onFormStateChanged);

    // Charger les métadonnées + produits du provider au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMetadata();
    });
  }

  @override
  void dispose() {
    _formState.removeListener(_onFormStateChanged);
    _formState.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // ============================================
  // LISTENERS
  // ============================================

  void _onFormStateChanged() {
    if (mounted) setState(() {});
  }

  // ============================================
  // CHARGEMENT DES MÉTADONNÉES
  // ============================================

  Future<void> _loadMetadata() async {
    setState(() => _isLoadingMetadata = true);

    try {
      final provider = context.read<SellerProductProvider>();

      // Utiliser le provider ou une API de catégories
      final categories = await provider.loadCategories();
      final brands = await provider.loadBrands();

      if (!mounted) return;

      setState(() {
        _categories = categories;
        _brands = brands;
        _isLoadingMetadata = false;
      });
    } catch (e) {
      debugPrint('❌ Erreur chargement métadonnées: $e');
      if (mounted) {
        setState(() => _isLoadingMetadata = false);
      }
    }
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleExit();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildStepIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  // Déjà géré par le form state
                },
                children: [
                  _buildStepInfo(),
                  _buildStepImages(),
                  _buildStepPricing(),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  // ============================================
  // APPBAR
  // ============================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      leading: IconButton(
        icon: const Icon(
          Icons.close_rounded,
          size: 24,
          color: AppColors.textPrimary,
        ),
        onPressed: _handleExit,
        tooltip: 'Fermer',
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formState.isEditing ? 'Modifier le produit' : 'Nouveau produit',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            'Étape ${_formState.currentStepIndex + 1} sur 3',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
      actions: [
        if (_isSaving)
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.warning,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ============================================
  // INDICATEUR D'ÉTAPES
  // ============================================

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: AppColors.background,
      child: Row(
        children: [
          _buildStepDot(FormStep.info),
          _buildStepLine(FormStep.info),
          _buildStepDot(FormStep.images),
          _buildStepLine(FormStep.images),
          _buildStepDot(FormStep.pricing),
        ],
      ),
    );
  }

  Widget _buildStepDot(FormStep step) {
    final isActive = _formState.currentStep == step;
    final isCompleted = _formState.currentStep.index > step.index;

    return GestureDetector(
      onTap: () => _onStepTap(step),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive || isCompleted
                  ? AppColors.warning
                  : AppColors.surfaceAlt,
              shape: BoxShape.circle,
              border: isActive
                  ? Border.all(
                      color: AppColors.warning.withValues(alpha: 0.3),
                      width: 3,
                    )
                  : null,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    )
                  : Text(
                      '${step.index + 1}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: isActive
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            step.label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10.5,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive ? AppColors.warning : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(FormStep step) {
    final isCompleted = _formState.currentStep.index > step.index;
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 2,
        margin: const EdgeInsets.only(bottom: 24, left: 6, right: 6),
        decoration: BoxDecoration(
          color: isCompleted ? AppColors.warning : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  // ============================================
  // PAGES (ÉTAPES)
  // ============================================

  Widget _buildStepInfo() {
    return SellerProductStepInfo(
      formState: _formState,
      categories: _categories,
      brands: _brands,
      isLoadingMetadata: _isLoadingMetadata,
      onCategoryChanged: (id) {
        _formState.selectedCategoryId = id;
        setState(() {});
      },
      onBrandChanged: (id) {
        _formState.selectedBrandId = id;
        setState(() {});
      },
      onReloadMetadata: _loadMetadata,
    );
  }

  Widget _buildStepImages() {
    return SellerProductStepImages(
      formState: _formState,
      onPickImages: _handlePickImages,
      onPickCamera: _handlePickCamera,
      onRemoveExistingImage: (index) {
        setState(() => _formState.removeExistingImage(index));
      },
      onRemoveNewImage: (index) {
        setState(() => _formState.removeNewImage(index));
      },
    );
  }

  Widget _buildStepPricing() {
    return SellerProductStepPricing(formState: _formState);
  }

  // ============================================
  // BARRE DE NAVIGATION BASSE
  // ============================================

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Bouton Retour
            if (!_formState.isFirstStep)
              Expanded(
                flex: 1,
                child: OutlinedButton.icon(
                  onPressed: _isSaving ? null : _handlePrevious,
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    size: 18,
                  ),
                  label: const Text(
                    'Retour',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: BorderSide(
                      color: AppColors.borderColor,
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

            if (!_formState.isFirstStep) const SizedBox(width: 12),

            // Bouton Suivant / Créer
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _handleNext,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        _formState.isLastStep
                            ? Icons.check_rounded
                            : Icons.arrow_forward_rounded,
                        size: 18,
                      ),
                label: Text(
                  _isSaving
                      ? 'Enregistrement...'
                      : _formState.isLastStep
                          ? (_formState.isEditing
                              ? 'Enregistrer'
                              : 'Créer le produit')
                          : 'Suivant',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AppColors.warning.withValues(alpha: 0.5),
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
    );
  }

  // ============================================
  // ACTIONS
  // ============================================

  void _onStepTap(FormStep step) {
    if (step == _formState.currentStep) return;

    final success = _formState.goToStep(step);
    if (success) {
      _pageController.animateToPage(
        step.index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _showError(_formState.fieldErrors.values.firstOrNull ??
          'Veuillez compléter l\'étape en cours.');
    }
  }

  void _handleNext() {
    if (_formState.isLastStep) {
      _handleSubmit();
      return;
    }

    final success = _formState.goToNextStep();
    if (success) {
      _pageController.animateToPage(
        _formState.currentStepIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _showError(_formState.fieldErrors.values.firstOrNull ??
          'Veuillez compléter les champs obligatoires.');
    }
  }

  void _handlePrevious() {
    final success = _formState.goToPreviousStep();
    if (success) {
      _pageController.animateToPage(
        _formState.currentStepIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _handlePickImages() async {
    final count = await _formState.pickImages();
    if (count > 0) {
      setState(() {});
      _showSuccess('$count image${count > 1 ? 's' : ''} ajoutée${count > 1 ? 's' : ''}');
    } else if (mounted && _formState.fieldErrors.containsKey('images')) {
      _showError(_formState.fieldErrors['images']!);
    }
  }

  Future<void> _handlePickCamera() async {
    final success = await _formState.pickImageFromCamera();
    if (success) {
      setState(() {});
      _showSuccess('Photo prise');
    }
  }

  Future<void> _handleSubmit() async {
    // Validation finale
    if (!_formState.isFormValid) {
      _showError(_formState.fieldErrors.values.firstOrNull ??
          'Veuillez compléter tous les champs obligatoires.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final provider = context.read<SellerProductProvider>();
      final payload = _formState.buildPayload();

      SellerProduct? result;

      if (_formState.isEditing && widget.product != null) {
        // 1. Mettre à jour le produit
        result = await provider.updateProduct(widget.product!.id, payload);

        if (result != null) {
          // 2. Supprimer les images retirées (côté serveur)
          final originalImageIds =
              widget.product!.images.map((img) => img.id).toSet();
          final remainingImageIds =
              _formState.existingImages.map((img) => img.id).toSet();

          final removedImageIds =
              originalImageIds.difference(remainingImageIds);

          for (final imageId in removedImageIds) {
            await provider.deleteImage(result.id, imageId);
          }

          // 3. Uploader les nouvelles images
          if (_formState.newImages.isNotEmpty) {
            final updated = await provider.uploadImages(
              result.id,
              _formState.newImagePaths,
            );
            if (updated != null) result = updated;
          }
        }
      } else {
        // Création
        result = await provider.createProduct(payload);

        if (result != null && _formState.newImages.isNotEmpty) {
          final updated = await provider.uploadImages(
            result.id,
            _formState.newImagePaths,
          );
          if (updated != null) result = updated;
        }
      }

        if (!mounted) return;

          if (result != null) {
            _showSuccess(_formState.isEditing
                ? 'Produit modifié avec succès'
                : 'Produit créé avec succès');
            await Future.delayed(const Duration(milliseconds: 500));
            if (mounted) Navigator.of(context).pop(result);
          } else {
            // ✅ Afficher l'erreur exacte du backend
            final errorMessage = _extractErrorFromProvider(provider);
            _showError(errorMessage);
            setState(() => _isSaving = false);
          }

    } catch (e) {
      debugPrint('❌ Erreur submit: $e');
      if (mounted) {
        _showError('Impossible de sauvegarder le produit.');
        setState(() => _isSaving = false);
      }
    }
  }

  // ============================================
  // SORTIE
  // ============================================

  Future<void> _handleExit() async {
    if (_isSaving) return;

    final hasData = _formState.nameController.text.trim().isNotEmpty ||
        _formState.totalImagesCount > 0 ||
        _formState.priceController.text.trim().isNotEmpty;

    if (!hasData) {
      Navigator.of(context).pop();
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Annuler la saisie ?',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Les informations saisies seront perdues.',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(
              'Continuer',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Quitter',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  // ============================================
  // HELPERS UI
  // ============================================

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// Extrait le message d'erreur le plus précis du provider.
  String _extractErrorFromProvider(SellerProductProvider provider) {
    final error = provider.actionError;
    if (error == null || error.isEmpty) {
      return 'Impossible de sauvegarder le produit.';
    }
    return error;
  }
}