// ============================================
// STATE : SellerProductFormState
// ============================================
// Classe de gestion d'état pour le formulaire de produit.
//
// Responsabilités :
//   - Contenir tous les TextEditingController
//   - Contenir les données du formulaire (catégorie, images)
//   - Gérer la navigation entre les étapes du wizard
//   - Valider chaque étape
//   - Produire le payload API
//   - Nettoyer les ressources
//
// Sécurité :
//   - Aucune donnée sensible stockée
//   - Fichiers locaux temporaires supprimés en cas d'annulation
//
// Ce state est un ChangeNotifier pour notifier l'UI des changements
// (compteur d'images, validité des étapes, etc.).
// ============================================

// Flutter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Dart
import 'dart:io';

// Image picker
import 'package:image_picker/image_picker.dart';

// Domain
import '../../domain/entities/seller_product.dart';

// ============================================
// ENUM D'ÉTAT PAR ÉTAPE
// ============================================

enum FormStep {
  info('Infos'),
  images('Images'),
  pricing('Prix & Stock');

  final String label;

  const FormStep(this.label);

  // Utiliser .index natif de l'enum (0, 1, 2) 
  // au lieu de la propriété custom
}

// ============================================
// STATE PRINCIPAL
// ============================================

class SellerProductFormState extends ChangeNotifier {
  // ============================================
  // ÉTAPE COURANTE
  // ============================================

  FormStep _currentStep = FormStep.info;
  FormStep get currentStep => _currentStep;
  int get currentStepIndex => _currentStep.index;
  bool get isFirstStep => _currentStep == FormStep.info;
  bool get isLastStep => _currentStep == FormStep.pricing;

  // ============================================
  // MODE (création ou édition)
  // ============================================

  final SellerProduct? initialProduct;
  bool get isEditing => initialProduct != null;

  // ============================================
  // CONTRÔLEURS : INFOS
  // ============================================

  final TextEditingController nameController = TextEditingController();
  final TextEditingController shortDescriptionController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  int? selectedCategoryId;
  int? selectedBrandId;

  // ============================================
  // CONTRÔLEURS : PRIX
  // ============================================

  final TextEditingController priceController = TextEditingController();
  final TextEditingController discountPriceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController minStockController = TextEditingController();
  final TextEditingController skuController = TextEditingController();
  final TextEditingController barcodeController = TextEditingController();

  // ============================================
  // IMAGES
  // ============================================

  /// Images existantes (en mode édition, déjà sur le serveur).
  final List<SellerProductImage> existingImages = [];

  /// Nouvelles images locales à uploader.
  final List<XFile> newImages = [];

  /// Image picker.
  final ImagePicker _imagePicker = ImagePicker();

  /// Constante : nombre max d'images par produit.
  static const int maxImages = 10;

  // ============================================
  // FORM KEYS
  // ============================================

  final GlobalKey<FormState> infoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> pricingFormKey = GlobalKey<FormState>();

  // ============================================
  // ÉTAT DE VALIDATION
  // ============================================

  /// Erreurs par champ (pour affichage ciblé).
  final Map<String, String> _fieldErrors = {};
  Map<String, String> get fieldErrors => Map.unmodifiable(_fieldErrors);

  /// Le formulaire est-il globalement valide ?
  bool get isFormValid =>
      isInfoStepValid && isImagesStepValid && isPricingStepValid;

  bool get isInfoStepValid =>
      nameController.text.trim().isNotEmpty &&
      selectedCategoryId != null;

  bool get isImagesStepValid =>
      existingImages.isNotEmpty || newImages.isNotEmpty;

  bool get isPricingStepValid {
    final price = double.tryParse(priceController.text.trim());
    final stock = int.tryParse(stockController.text.trim());
    return price != null &&
        price > 0 &&
        stock != null &&
        stock >= 0 &&
        skuController.text.trim().isNotEmpty;
  }

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  SellerProductFormState({SellerProduct? product}) : initialProduct = product {
    if (product != null) {
      _prefillFromProduct(product);
    } else {
      // Valeurs par défaut
      minStockController.text = '5';
      stockController.text = '0';
      
      // ✅ Générer un SKU unique au chargement
      skuController.text = _generateUniqueSku();
    }

    _attachListeners();
  }

  // ============================================
// GÉNÉRATION DE SKU UNIQUE
// ============================================

/// Génère un SKU unique basé sur un timestamp.
/// Format : PROD-{timestamp en ms base36}
String _generateUniqueSku() {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final random = (timestamp % 99999).toString().padLeft(5, '0');
  return 'PROD-$random';
}

/// Regénère un nouveau SKU unique (bouton "Regénérer").
void regenerateSku() {
  skuController.text = _generateUniqueSku();
  _fieldErrors.remove('sku');
  notifyListeners();
}

  // ============================================
  // PRÉ-REMPLISSAGE (édition)
  // ============================================

  void _prefillFromProduct(SellerProduct product) {
    nameController.text = product.name;
    shortDescriptionController.text = product.shortDescription ?? '';
    descriptionController.text = product.description ?? '';
    selectedCategoryId = product.categoryId;
    selectedBrandId = product.brandId;
    priceController.text = product.price.toStringAsFixed(0);
    if (product.discountPrice != null && product.discountPrice! > 0) {
      discountPriceController.text = product.discountPrice!.toStringAsFixed(0);
    }
    stockController.text = product.stock.toString();
    minStockController.text = product.minStock.toString();
    skuController.text = product.sku;
    barcodeController.text = product.barcode ?? '';
    existingImages.addAll(product.images);
  }

  // ============================================
  // LISTENERS
  // ============================================

  void _attachListeners() {
    nameController.addListener(_onFieldChanged);
    priceController.addListener(_onFieldChanged);
    stockController.addListener(_onFieldChanged);
    skuController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    notifyListeners();
  }

  // ============================================
  // NAVIGATION ENTRE ÉTAPES
  // ============================================

  /// Passe à l'étape suivante si la validation actuelle est OK.
  bool goToNextStep() {
    if (!_validateCurrentStep()) return false;

    switch (_currentStep) {
      case FormStep.info:
        _currentStep = FormStep.images;
        break;
      case FormStep.images:
        _currentStep = FormStep.pricing;
        break;
      case FormStep.pricing:
        return true; // Déjà sur la dernière étape
    }

    notifyListeners();
    return true;
  }

  /// Revient à l'étape précédente.
  bool goToPreviousStep() {
    switch (_currentStep) {
      case FormStep.pricing:
        _currentStep = FormStep.images;
        break;
      case FormStep.images:
        _currentStep = FormStep.info;
        break;
      case FormStep.info:
        return false; // Déjà sur la première étape
    }

    notifyListeners();
    return true;
  }

  /// Va à une étape spécifique (via l'indicateur d'étapes).
///
/// Retourne `true` si la navigation a réussi, `false` sinon.
bool goToStep(FormStep step) {
  // Empêcher d'aller trop loin sans validation
  if (step.index > _currentStep.index) {
    // Valider les étapes intermédiaires
    for (int i = _currentStep.index; i < step.index; i++) {
      _currentStep = FormStep.values[i];
      if (!_validateCurrentStep()) {
        notifyListeners();
        return false;
      }
    }
  }

  _currentStep = step;
  notifyListeners();
  return true;
}

  // ============================================
  // VALIDATION PAR ÉTAPE
  // ============================================

  bool _validateCurrentStep() {
    _fieldErrors.clear();

    switch (_currentStep) {
      case FormStep.info:
        return _validateInfoStep();
      case FormStep.images:
        return _validateImagesStep();
      case FormStep.pricing:
        return _validatePricingStep();
    }
  }

  bool _validateInfoStep() {
    bool isValid = true;

    if (nameController.text.trim().isEmpty) {
      _fieldErrors['name'] = 'Le nom est obligatoire';
      isValid = false;
    } else if (nameController.text.trim().length < 3) {
      _fieldErrors['name'] = 'Le nom doit contenir au moins 3 caractères';
      isValid = false;
    }

    if (selectedCategoryId == null) {
      _fieldErrors['category_id'] = 'Veuillez sélectionner une catégorie';
      isValid = false;
    }

    if (!isValid) notifyListeners();
    return isValid;
  }

  bool _validateImagesStep() {
    if (existingImages.isEmpty && newImages.isEmpty) {
      _fieldErrors['images'] = 'Veuillez ajouter au moins une image';
      notifyListeners();
      return false;
    }
    return true;
  }

  bool _validatePricingStep() {
    bool isValid = true;

    final price = double.tryParse(priceController.text.trim());
    if (price == null || price <= 0) {
      _fieldErrors['price'] = 'Le prix doit être supérieur à 0';
      isValid = false;
    }

    if (discountPriceController.text.trim().isNotEmpty) {
      final discount = double.tryParse(discountPriceController.text.trim());
      if (discount == null || discount < 0) {
        _fieldErrors['discount_price'] = 'Prix réduit invalide';
        isValid = false;
      } else if (price != null && discount >= price) {
        _fieldErrors['discount_price'] =
            'Le prix réduit doit être inférieur au prix normal';
        isValid = false;
      }
    }

    final stock = int.tryParse(stockController.text.trim());
    if (stock == null || stock < 0) {
      _fieldErrors['stock'] = 'Le stock doit être supérieur ou égal à 0';
      isValid = false;
    }

    if (skuController.text.trim().isEmpty) {
      _fieldErrors['sku'] = 'Le SKU est obligatoire';
      isValid = false;
    } else if (skuController.text.trim().length < 3) {
      _fieldErrors['sku'] = 'Le SKU doit contenir au moins 3 caractères';
      isValid = false;
    }

    if (!isValid) notifyListeners();
    return isValid;
  }

  // ============================================
  // GESTION DES IMAGES
  // ============================================

  /// Ouvre le sélecteur d'images multiples.
  Future<int> pickImages() async {
    final remaining = maxImages - existingImages.length - newImages.length;

    if (remaining <= 0) {
      _fieldErrors['images'] = 'Vous ne pouvez pas dépasser $maxImages images';
      notifyListeners();
      return 0;
    }

    try {
      final picked = await _imagePicker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (picked.isEmpty) return 0;

      // Limiter au quota restant
      final toAdd = picked.take(remaining).toList();
      newImages.addAll(toAdd);

      _fieldErrors.remove('images');
      notifyListeners();
      return toAdd.length;
    } catch (e) {
      debugPrint('❌ Erreur pickImages: $e');
      _fieldErrors['images'] = 'Impossible de sélectionner les images';
      notifyListeners();
      return 0;
    }
  }

  /// Prend une photo avec la caméra.
  Future<bool> pickImageFromCamera() async {
    final remaining = maxImages - existingImages.length - newImages.length;

    if (remaining <= 0) {
      _fieldErrors['images'] = 'Vous ne pouvez pas dépasser $maxImages images';
      notifyListeners();
      return false;
    }

    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (picked == null) return false;

      newImages.add(picked);
      _fieldErrors.remove('images');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Erreur pickImageFromCamera: $e');
      return false;
    }
  }

  /// Supprime une nouvelle image locale.
  void removeNewImage(int index) {
    if (index < 0 || index >= newImages.length) return;
    newImages.removeAt(index);
    notifyListeners();
  }

  /// Supprime une image existante (à supprimer côté serveur).
  ///
  /// Note : la suppression effective sera faite à la sauvegarde.
  void removeExistingImage(int index) {
    if (index < 0 || index >= existingImages.length) return;
    existingImages.removeAt(index);
    notifyListeners();
  }

  /// Le formulaire a-t-il des images au total ?
  int get totalImagesCount => existingImages.length + newImages.length;

  /// Peut-on encore ajouter des images ?
  bool get canAddMoreImages => totalImagesCount < maxImages;

  // ============================================
  // CONSTRUCTION DU PAYLOAD API
  // ============================================

  /// Construit le payload pour l'API.
  ///
  /// En mode édition, on n'envoie QUE les champs modifiés.
  Map<String, dynamic> buildPayload() {
    final payload = <String, dynamic>{
      'name': nameController.text.trim(),
      'price': double.tryParse(priceController.text.trim()) ?? 0.0,
      'stock': int.tryParse(stockController.text.trim()) ?? 0,
      'sku': skuController.text.trim().toUpperCase(),
      'category_id': selectedCategoryId,
    };

    // Champs optionnels
    if (shortDescriptionController.text.trim().isNotEmpty) {
      payload['short_description'] = shortDescriptionController.text.trim();
    }

    if (descriptionController.text.trim().isNotEmpty) {
      payload['description'] = descriptionController.text.trim();
    }

    if (discountPriceController.text.trim().isNotEmpty) {
      final discount = double.tryParse(discountPriceController.text.trim());
      if (discount != null && discount > 0) {
        payload['discount_price'] = discount;
      }
    }

    if (minStockController.text.trim().isNotEmpty) {
      final minStock = int.tryParse(minStockController.text.trim());
      if (minStock != null && minStock >= 0) {
        payload['min_stock'] = minStock;
      }
    }

    if (barcodeController.text.trim().isNotEmpty) {
      payload['barcode'] = barcodeController.text.trim();
    }

    if (selectedBrandId != null) {
      payload['brand_id'] = selectedBrandId;
    }

    return payload;
  }

  /// Retourne les chemins des nouvelles images à uploader.
  List<String> get newImagePaths =>
      newImages.map((xfile) => xfile.path).toList();

  // ============================================
  // VALIDATION CÔTÉ FORMULAIRE (inline)
  // ============================================

  /// Validator pour le champ "nom".
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le nom est obligatoire';
    }
    if (value.trim().length < 3) {
      return 'Le nom doit contenir au moins 3 caractères';
    }
    return null;
  }

  /// Validator pour le champ "SKU".
  String? validateSku(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le SKU est obligatoire';
    }
    if (value.trim().length < 3) {
      return 'Le SKU doit contenir au moins 3 caractères';
    }
    if (!RegExp(r'^[A-Z0-9\-_]+$').hasMatch(value.trim().toUpperCase())) {
      return 'Le SKU ne peut contenir que des lettres, chiffres, tirets et underscores';
    }
    return null;
  }

  /// Validator pour le champ "prix".
  String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le prix est obligatoire';
    }
    final price = double.tryParse(value.trim());
    if (price == null) {
      return 'Prix invalide';
    }
    if (price <= 0) {
      return 'Le prix doit être supérieur à 0';
    }
    return null;
  }

  /// Validator pour le champ "prix réduit".
  String? validateDiscountPrice(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final discount = double.tryParse(value.trim());
    if (discount == null) {
      return 'Prix réduit invalide';
    }
    if (discount < 0) {
      return 'Le prix ne peut pas être négatif';
    }

    final price = double.tryParse(priceController.text.trim());
    if (price != null && discount >= price) {
      return 'Le prix réduit doit être inférieur au prix normal';
    }

    return null;
  }

  /// Validator pour le champ "stock".
  String? validateStock(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le stock est obligatoire';
    }
    final stock = int.tryParse(value.trim());
    if (stock == null) {
      return 'Stock invalide';
    }
    if (stock < 0) {
      return 'Le stock ne peut pas être négatif';
    }
    return null;
  }

  /// Validator pour le champ "stock minimum".
  String? validateMinStock(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final minStock = int.tryParse(value.trim());
    if (minStock == null || minStock < 0) {
      return 'Stock minimum invalide';
    }
    return null;
  }

  // ============================================
  // FORMATEURS D'ENTRÉE
  // ============================================

  /// Formatteur pour les champs numériques (prix, stock).
  static final List<TextInputFormatter> numberInputFormatters = [
    FilteringTextInputFormatter.digitsOnly,
  ];

  /// Formatteur pour le prix (chiffres uniquement, pas de décimales).
  static final List<TextInputFormatter> priceInputFormatters = [
    FilteringTextInputFormatter.digitsOnly,
  ];

  /// Formatteur pour le SKU (majuscules auto, pas d'espaces).
  static final List<TextInputFormatter> skuInputFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\-_]')),
    _UpperCaseTextFormatter(),
  ];

  // ============================================
  // RESET
  // ============================================

  /// Efface tous les champs.
  void reset() {
    nameController.clear();
    shortDescriptionController.clear();
    descriptionController.clear();
    priceController.clear();
    discountPriceController.clear();
    stockController.text = '0';
    minStockController.text = '5';
    skuController.clear();
    barcodeController.clear();
    selectedCategoryId = null;
    selectedBrandId = null;
    existingImages.clear();
    newImages.clear();
    _fieldErrors.clear();
    _currentStep = FormStep.info;
    notifyListeners();
  }

  // ============================================
  // DISPOSE
  // ============================================

  @override
  void dispose() {
    nameController.dispose();
    shortDescriptionController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    discountPriceController.dispose();
    stockController.dispose();
    minStockController.dispose();
    skuController.dispose();
    barcodeController.dispose();

    // Supprimer les fichiers temporaires des nouvelles images
    for (var image in newImages) {
      try {
        final file = File(image.path);
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (e) {
        debugPrint('⚠️ Impossible de supprimer ${image.path}: $e');
      }
    }
    newImages.clear();

    super.dispose();
  }
}

// ============================================
// FORMATTER : Texte en majuscules
// ============================================

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
    );
  }
}