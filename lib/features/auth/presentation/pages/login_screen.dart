// ============================================
// ÉCRAN DE CONNEXION - VERSION PROFESSIONNELLE
// ============================================
// Design moderne avec :
// - Logo officiel
// - Redirection centralisée par rôle
// - Vérification de connexion Internet
// - Mémorisation du dernier email
// - Messages d'erreur clairs
// ============================================

// ============================================
// IMPORTS
// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../routes/app_routes.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_textfield.dart';
import '../widgets/password_textfield.dart';
import '../widgets/social_button.dart';

// ============================================
// ÉCRAN PRINCIPAL
// ============================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// ============================================
// STATE
// ============================================

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _rememberMe = false;
  bool _isLoading = false;
  String? _errorMessage;

  // ============================================
  // INIT
  // ============================================

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
    _loadRememberMe();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================
  // CHARGEMENT DES PRÉFÉRENCES
  // ============================================

  /// Charge le dernier email sauvegardé
  Future<void> _loadSavedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('saved_email');
      if (savedEmail != null && savedEmail.isNotEmpty) {
        _emailController.text = savedEmail;
      }
    } catch (e) {
      debugPrint('Erreur chargement email: $e');
    }
  }

  /// Charge la préférence "Se souvenir de moi"
  Future<void> _loadRememberMe() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _rememberMe = prefs.getBool('remember_me') ?? false;
      });
    } catch (e) {
      debugPrint('Erreur chargement rememberMe: $e');
    }
  }

  // ============================================
  // SAUVEGARDE DES PRÉFÉRENCES
  // ============================================

  /// Sauvegarde l'email et la préférence
  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setString('saved_email', _emailController.text.trim());
        await prefs.setBool('remember_me', true);
      } else {
        await prefs.remove('saved_email');
        await prefs.setBool('remember_me', false);
      }
    } catch (e) {
      debugPrint('Erreur sauvegarde préférences: $e');
    }
  }

  // ============================================
  // GÉRER LA CONNEXION
  // ============================================

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      rememberMe: _rememberMe,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      await _savePreferences();
      _navigateToDashboard(authProvider);
    } else {
      setState(() {
        _errorMessage = authProvider.errorMessage ?? 'Erreur de connexion';
      });
    }
  }

  // ============================================
  // NAVIGATION APRÈS CONNEXION
  // ============================================

  void _navigateToDashboard(AuthProvider authProvider) {
  // 1. Récupérer la route de redirection
  final route = authProvider.getRedirectRoute();

  // 2. Capturer le ScaffoldMessenger avant la navigation
  final messenger = ScaffoldMessenger.of(context);

  // 3. Naviguer D'ABORD (sans attendre le SnackBar)
  Navigator.of(context).pushNamedAndRemoveUntil(
    route,
    (route) => false,
  );

  // 4. Afficher le SnackBar APRÈS la navigation
  // Le ScaffoldMessenger est global, donc il s'affichera sur le nouvel écran
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        'Bienvenue ${authProvider.user?.name ?? ""} !',
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          color: Colors.white,
        ),
      ),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(20),
      duration: const Duration(seconds: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ============================================
                // EN-TÊTE
                // ============================================
                Center(
                  child: Column(
                    children: [
                      // Logo (image ou fallback icône)
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.asset(
                            'assets/images/logo.jpg',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.shopping_bag,
                                size: 38,
                                color: Colors.white,
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        'Bon retour !',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.3,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Connectez-vous pour continuer',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                // ============================================
                // MESSAGE D'ERREUR
                // ============================================
                if (_errorMessage != null) ...[
                  _buildErrorBox(),
                  const SizedBox(height: 18),
                ],

                // ============================================
                // CHAMP EMAIL
                // ============================================
                AuthTextField(
                  controller: _emailController,
                  label: 'Adresse email',
                  hint: 'exemple@email.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  textCapitalization: TextCapitalization.none,
                  validator: Validators.validateEmail,
                ),

                // ============================================
                // CHAMP MOT DE PASSE
                // ============================================
                PasswordTextField(
                  controller: _passwordController,
                  label: 'Mot de passe',
                  hint: 'Entrez votre mot de passe',
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleLogin(),
                  validator: Validators.validatePassword,
                ),

                // ============================================
                // SE SOUVENIR + MOT DE PASSE OUBLIÉ
                // ============================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Se souvenir de moi
                    InkWell(
                      onTap: () {
                        setState(() {
                          _rememberMe = !_rememberMe;
                        });
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Row(
                        children: [
                          Icon(
                            _rememberMe
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            size: 20,
                            color: _rememberMe
                                ? AppColors.primary
                                : AppColors.textTertiary,
                          ),
                          const SizedBox(width: 7),
                          const Text(
                            'Se souvenir',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Mot de passe oublié
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.forgotPassword);
                      },
                      child: const Text(
                        'Mot de passe oublié ?',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ============================================
                // BOUTON CONNEXION
                // ============================================
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 3,
                    shadowColor: AppColors.primary.withValues(alpha: 0.3),
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'SE CONNECTER',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                ),

                const SizedBox(height: 25),

                // ============================================
                // SÉPARATEUR
                // ============================================
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: AppColors.borderColor,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'ou continuer avec',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: AppColors.borderColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ============================================
                // BOUTONS SOCIAUX
                // ============================================
                Row(
                  children: [
                    Expanded(
                      child: SocialButton.google(),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SocialButton.facebook(),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SocialButton.apple(),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // ============================================
                // LIEN INSCRIPTION
                // ============================================
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Pas de compte ? ',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacementNamed(AppRoutes.register);
                        },
                        child: const Text(
                          'S\'inscrire',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================
  // WIDGETS INTERNES
  // ============================================

  /// Boîte d'erreur élégante
  Widget _buildErrorBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.errorDark,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _errorMessage = null;
              });
            },
            child: const Icon(
              Icons.close,
              color: AppColors.error,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}