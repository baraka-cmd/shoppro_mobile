// ============================================
// ENTITÉ : SellerPayout
// ============================================
// Représente un versement (payout) du point de vue vendeur.
//
// Responsabilités :
//   - Contenir toutes les infos d'un payout
//   - Exposer les getters métier (isPending, isCancellable, etc.)
//   - Servir de contrat entre le backend et l'UI
//
// ⚠️ Sécurité :
//   - Le compte destinataire est MASQUÉ (`accountMasked`)
//   - La note admin n'est JAMAIS exposée
//
// Aucune dépendance Flutter : entité PURE Dart.
// ============================================

// ============================================
// ENUM : SellerPayoutStatus
// ============================================

enum SellerPayoutStatus {
  pending('pending', 'En attente', 0xFFF59E0B),       // warning
  processing('processing', 'En cours', 0xFF3B82F6),   // info
  completed('completed', 'Complété', 0xFF10B981),     // success
  failed('failed', 'Échoué', 0xFFEF4444),             // error
  cancelled('cancelled', 'Annulé', 0xFF6B7280);       // gray

  final String code;
  final String displayName;
  final int colorHex;

  const SellerPayoutStatus(this.code, this.displayName, this.colorHex);

  static SellerPayoutStatus fromCode(String? code) {
    return SellerPayoutStatus.values.firstWhere(
      (status) => status.code == code,
      orElse: () => SellerPayoutStatus.pending,
    );
  }
}

// ============================================
// ENUM : SellerPayoutMethod
// ============================================

enum SellerPayoutMethod {
  mobileMoney('mobile_money', 'Mobile Money'),
  bankTransfer('bank_transfer', 'Virement bancaire'),
  paypal('paypal', 'PayPal');

  final String code;
  final String displayName;

  const SellerPayoutMethod(this.code, this.displayName);

  static SellerPayoutMethod fromCode(String? code) {
    return SellerPayoutMethod.values.firstWhere(
      (method) => method.code == code,
      orElse: () => SellerPayoutMethod.mobileMoney,
    );
  }
}

// ============================================
// ENTITÉ PRINCIPALE : SellerPayout
// ============================================

class SellerPayout {
  // ============================================
  // IDENTIFIANTS
  // ============================================
  final int id;
  final String reference;

  // ============================================
  // MONTANTS
  // ============================================
  final double amount;
  final String amountFormatted;
  final double fee;
  final String feeFormatted;
  final double netAmount;
  final String netAmountFormatted;
  final String currency;

  // ============================================
  // MÉTHODE DE PAIEMENT
  // ============================================
  final SellerPayoutMethod method;
  final String methodLabel;
  final String methodIcon;
  final String? accountMasked;

  // ============================================
  // STATUT
  // ============================================
  final SellerPayoutStatus status;
  final String statusLabel;
  final int statusColorHex;

  // ============================================
  // ACTIONS POSSIBLES (pré-calculées)
  // ============================================
  final bool isPending;
  final bool isProcessing;
  final bool isCompleted;
  final bool isFailed;
  final bool isCancelled;
  final bool isCancellable;

  // ============================================
  // DATES
  // ============================================
  final DateTime? requestedAt;
  final String? requestedAtHuman;
  final DateTime? processedAt;
  final String? processedAtHuman;
  final DateTime? completedAt;
  final String? completedAtHuman;
  final DateTime? failedAt;
  final DateTime? cancelledAt;

  // ============================================
  // MÉTADONNÉES
  // ============================================
  final String? note;
  final String? externalReference;
  final String? externalProvider;
  final String? failureReason;

  const SellerPayout({
    required this.id,
    required this.reference,
    required this.amount,
    required this.amountFormatted,
    required this.fee,
    required this.feeFormatted,
    required this.netAmount,
    required this.netAmountFormatted,
    this.currency = 'FCFA',
    required this.method,
    required this.methodLabel,
    required this.methodIcon,
    this.accountMasked,
    required this.status,
    required this.statusLabel,
    required this.statusColorHex,
    this.isPending = false,
    this.isProcessing = false,
    this.isCompleted = false,
    this.isFailed = false,
    this.isCancelled = false,
    this.isCancellable = false,
    this.requestedAt,
    this.requestedAtHuman,
    this.processedAt,
    this.processedAtHuman,
    this.completedAt,
    this.completedAtHuman,
    this.failedAt,
    this.cancelledAt,
    this.note,
    this.externalReference,
    this.externalProvider,
    this.failureReason,
  });

  // ============================================
  // GETTERS MÉTIER
  // ============================================

  /// Le payout est-il actif (pending ou processing) ?
  bool get isActive => isPending || isProcessing;

  /// Le payout est-il finalisé (completed, failed, cancelled) ?
  bool get isFinalized => isCompleted || isFailed || isCancelled;

  /// A-t-il des frais ?
  bool get hasFee => fee > 0;

  /// A-t-il une référence externe (paiement effectué) ?
  bool get hasExternalReference =>
      externalReference != null && externalReference!.isNotEmpty;

  /// A-t-il une raison d'échec ?
  bool get hasFailureReason =>
      failureReason != null && failureReason!.isNotEmpty;

  /// A-t-il une note ?
  bool get hasNote => note != null && note!.isNotEmpty;



  @override
  String toString() {
    return 'SellerPayout(id: $id, ref: $reference, '
        'amount: $amountFormatted, status: ${status.displayName})';
  }
}

// ============================================
// ENTITÉ : SellerBalance
// ============================================
// Représente le solde du vendeur.
// ============================================

class SellerBalance {
  // ============================================
  // SOLDES
  // ============================================
  final double available;
  final String availableFormatted;
  final double pending;
  final String pendingFormatted;
  final double total;
  final String totalFormatted;

  // ============================================
  // DISPONIBILITÉ
  // ============================================
  final bool canRequestPayout;
  final double minPayoutAmount;
  final String minPayoutAmountFormatted;

  // ============================================
  // PAYOUT EN COURS (si existe)
  // ============================================
  final SellerPayoutActiveInfo? activePayout;

  // ============================================
  // CONFIGURATION
  // ============================================
  final String? payoutMethod;
  final String? payoutAccountMasked;
  final bool hasPayoutMethod;
  final double commissionRate;

  // ============================================
  // STATISTIQUES
  // ============================================
  final SellerPayoutStats stats;

  const SellerBalance({
    this.available = 0,
    this.availableFormatted = '0 FCFA',
    this.pending = 0,
    this.pendingFormatted = '0 FCFA',
    this.total = 0,
    this.totalFormatted = '0 FCFA',
    this.canRequestPayout = false,
    this.minPayoutAmount = 1000,
    this.minPayoutAmountFormatted = '1 000 FCFA',
    this.activePayout,
    this.payoutMethod,
    this.payoutAccountMasked,
    this.hasPayoutMethod = false,
    this.commissionRate = 10,
    this.stats = const SellerPayoutStats.empty(),
  });

  const SellerBalance.empty()
      : available = 0,
        availableFormatted = '0 FCFA',
        pending = 0,
        pendingFormatted = '0 FCFA',
        total = 0,
        totalFormatted = '0 FCFA',
        canRequestPayout = false,
        minPayoutAmount = 1000,
        minPayoutAmountFormatted = '1 000 FCFA',
        activePayout = null,
        payoutMethod = null,
        payoutAccountMasked = null,
        hasPayoutMethod = false,
        commissionRate = 10,
        stats = const SellerPayoutStats.empty();

  // ============================================
  // GETTERS
  // ============================================

  /// Le vendeur a-t-il un solde disponible ?
  bool get hasAvailable => available > 0;

  /// Le vendeur a-t-il un payout en cours ?
  bool get hasActivePayout => activePayout != null;

  /// Le vendeur peut-il demander un payout maintenant ?
  bool get isEligibleForPayout =>
      canRequestPayout && !hasActivePayout && hasAvailable;

  @override
  String toString() {
    return 'SellerBalance(available: $availableFormatted, '
        'pending: $pendingFormatted)';
  }
}

// ============================================
// SOUS-ENTITÉ : SellerPayoutActiveInfo
// ============================================
// Info d'un payout en cours (pour le bloc "payout en cours").
// ============================================

class SellerPayoutActiveInfo {
  final int id;
  final String reference;
  final double amount;
  final String amountFormatted;
  final String status;
  final DateTime? requestedAt;
  final String? requestedAtHuman;

  const SellerPayoutActiveInfo({
    required this.id,
    required this.reference,
    required this.amount,
    required this.amountFormatted,
    required this.status,
    this.requestedAt,
    this.requestedAtHuman,
  });

  @override
  String toString() {
    return 'SellerPayoutActiveInfo(id: $id, ref: $reference, status: $status)';
  }
}

// ============================================
// ENTITÉ : SellerPayoutStats
// ============================================
// Statistiques globales des payouts.
// ============================================

class SellerPayoutStats {
  final int totalPayouts;
  final int completedCount;
  final int pendingCount;
  final int processingCount;
  final double totalWithdrawn;
  final String totalWithdrawnFormatted;
  final double totalCancelled;
  final String totalCancelledFormatted;

  const SellerPayoutStats({
    this.totalPayouts = 0,
    this.completedCount = 0,
    this.pendingCount = 0,
    this.processingCount = 0,
    this.totalWithdrawn = 0,
    this.totalWithdrawnFormatted = '0 FCFA',
    this.totalCancelled = 0,
    this.totalCancelledFormatted = '0 FCFA',
  });

  const SellerPayoutStats.empty()
      : totalPayouts = 0,
        completedCount = 0,
        pendingCount = 0,
        processingCount = 0,
        totalWithdrawn = 0,
        totalWithdrawnFormatted = '0 FCFA',
        totalCancelled = 0,
        totalCancelledFormatted = '0 FCFA';

  bool get hasPayouts => totalPayouts > 0;

  @override
  String toString() {
    return 'SellerPayoutStats(total: $totalPayouts, '
        'completed: $completedCount, withdrawn: $totalWithdrawnFormatted)';
  }
}

// ============================================
// ENUM : PayoutFilter
// ============================================

enum SellerPayoutFilter {
  all('all', 'Tous'),
  pending('pending', 'En attente'),
  processing('processing', 'En cours'),
  completed('completed', 'Complétés'),
  failed('failed', 'Échoués');

  final String code;
  final String label;

  const SellerPayoutFilter(this.code, this.label);
}