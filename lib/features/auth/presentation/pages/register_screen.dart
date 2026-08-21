// Écran d'inscription complet
// Formulaire avec validation, indicateur de force, CGU et navigation

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../routes/app_routes.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_textfield.dart';
import '../widgets/password_textfield.dart';
import '../widgets/password_strength_indicator.dart';
import '../widgets/social_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _acceptTerms = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Gérer l'inscription
  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();

    // Valider le formulaire
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Vérifier les CGU
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez accepter les conditions générales d\'utilisation',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
            ),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(20),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
      phone: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : null,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      // Afficher le message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Compte créé avec succès ! Connectez-vous.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(20),
          duration: Duration(seconds: 3),
        ),
      );

      // Redirection vers login
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    } else {
      setState(() {
        _errorMessage = authProvider.errorMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête
                Center(
                  child: Column(
                    children: [
                      // Icône
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_add,
                          size: 35,
                          color: Colors.white,
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Titre
                      const Text(
                        'Créer un compte',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Sous-titre
                      const Text(
                        'Rejoignez ShopPro dès maintenant',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 35),
                
                // Message d'erreur
                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
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
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.error,
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
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                
                // Champ Nom complet
                AuthTextField(
                  controller: _nameController,
                  label: 'Nom complet',
                  hint: 'Ex : Jean Kamga',
                  icon: Icons.person_outline,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  validator: Validators.validateName,
                ),
                
                // Champ Email
                AuthTextField(
                  controller: _emailController,
                  label: 'Adresse email',
                  hint: 'exemple@email.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.validateEmail,
                ),
                
                // Champ Téléphone (optionnel)
                AuthTextField(
                  controller: _phoneController,
                  label: 'Téléphone (optionnel)',
                  hint: 'Ex : +237 6 00 00 00 00',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: Validators.validatePhone,
                ),
                
                // Champ Mot de passe
                PasswordTextField(
                  controller: _passwordController,
                  label: 'Mot de passe',
                  hint: 'Entrez votre mot de passe',
                  validator: Validators.validatePassword,
                  textInputAction: TextInputAction.next,
                  showStrengthIndicator: true,
                ),
                
                // Indicateur de force
                PasswordStrengthIndicator(
                  password: _passwordController.text,
                ),
                
                const SizedBox(height: 20),
                
                // Champ Confirmation
                PasswordTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirmer le mot de passe',
                  hint: 'Répétez votre mot de passe',
                  validator: (value) =>
                      Validators.validatePasswordConfirmation(
                    value,
                    _passwordController.text,
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (value) => _handleRegister(),
                ),
                
                const SizedBox(height: 15),
                
                // Checkbox CGU
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: _acceptTerms,
                        onChanged: (value) {
                          setState(() {
                            _acceptTerms = value ?? false;
                          });
                        },
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(text: 'J\'accepte les '),
                            TextSpan(
                              text: 'Conditions Générales d\'Utilisation',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(text: ' et la '),
                            TextSpan(
                              text: 'Politique de Confidentialité',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                // Bouton Créer mon compte
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'CRÉER MON COMPTE',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                ),
                
                const SizedBox(height: 30),
                
                // Séparateur
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: AppColors.borderColor,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        'ou continuer avec',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
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
                
                const SizedBox(height: 25),
                
                // Boutons sociaux
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SocialButton.google(
                        onPressed: () {
                          // TODO: Inscription Google
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SocialButton.facebook(
                        onPressed: () {
                          // TODO: Inscription Facebook
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SocialButton.apple(
                        onPressed: () {
                          // TODO: Inscription Apple
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                // Lien connexion
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Déjà un compte ? ',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                        },
                        child: const Text(
                          'Se connecter',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
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
}