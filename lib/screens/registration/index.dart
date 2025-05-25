// lib/screens/registration/index.dart
import 'package:flutter/material.dart';
import 'package:osecours/screens/otp/index.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/sizes.dart';
import '../../core/constants/themes.dart';
import '../../services/auth_service.dart';
import '../../services/navigation_service.dart';
import 'controllers.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final RegistrationController _controller = RegistrationController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller.initFocusListeners(setState);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await _controller.showExitConfirmationDialog(context);
        return shouldExit ?? false;
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: AppEdgeInsets.screen,
              child: Form(
                key: _controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppSizes.spacingXXLarge),

                    // Header
                    Text('Bonjour 👋', style: AppTextStyles.heading1),
                    SizedBox(height: AppSizes.spacingSmall),
                    Text(
                      "Inscrivez-vous pour accéder à O'secours",
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
                    ),
                    SizedBox(height: AppSizes.spacingXLarge),

                    // Nom complet
                    Text('Nom complet', style: AppTextStyles.label),
                    SizedBox(height: AppSizes.spacingSmall),
                    Container(
                      height: AppSizes.inputHeight,
                      child: TextFormField(
                        controller: _controller.nameController,
                        focusNode: _controller.nameFocusNode,
                        style: AppTextStyles.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'Entrez votre nom complet',
                          hintStyle: AppTextStyles.hint,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSmall)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                            borderSide: const BorderSide(color: Colors.black54),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: AppSizes.spacingMedium,
                            vertical: AppSizes.spacingMedium,
                          ),
                          prefixIcon: Icon(
                            Icons.person,
                            color: _controller.isNameFocused ? AppColors.primary : Colors.grey,
                            size: AppSizes.iconMedium,
                          ),
                          suffixIcon:
                              _controller.nameController.text.isNotEmpty
                                  ? Icon(
                                    _controller.isNameValid ? Icons.check_circle : Icons.cancel,
                                    color: _controller.isNameValid ? Colors.green : AppColors.primary,
                                    size: AppSizes.iconMedium,
                                  )
                                  : null,
                        ),
                        validator: _controller.validateName,
                      ),
                    ),

                    SizedBox(height: AppSizes.spacingLarge),

                    // Numéro de téléphone
                    Text('Numéro de téléphone', style: AppTextStyles.label),
                    SizedBox(height: AppSizes.spacingSmall),
                    Container(
                      height: AppSizes.inputHeight,
                      child: TextFormField(
                        controller: _controller.phoneController,
                        focusNode: _controller.phoneFocusNode,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        style: AppTextStyles.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'Entrez votre numéro de téléphone',
                          hintStyle: AppTextStyles.hint,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSmall)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                            borderSide: const BorderSide(color: Colors.black54),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: AppSizes.spacingMedium,
                            vertical: AppSizes.spacingMedium,
                          ),
                          prefixIcon: Icon(
                            Icons.phone,
                            color: _controller.isPhoneFocused ? AppColors.primary : Colors.grey,
                            size: AppSizes.iconMedium,
                          ),
                          suffixIcon:
                              _controller.phoneController.text.isNotEmpty
                                  ? Icon(
                                    _controller.isPhoneValid ? Icons.check_circle : Icons.cancel,
                                    color: _controller.isPhoneValid ? Colors.green : AppColors.primary,
                                    size: AppSizes.iconMedium,
                                  )
                                  : null,
                          counterText: '', // Masquer le compteur de caractères
                        ),
                        validator: _controller.validatePhone,
                      ),
                    ),

                    SizedBox(height: AppSizes.spacingXLarge),

                    // Bouton S'inscrire
                    SizedBox(
                      width: double.infinity,
                      height: AppSizes.buttonHeight,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusButton)),
                          padding: AppEdgeInsets.button,
                        ),
                        child:
                            _isLoading
                                ? SizedBox(
                                  width: AppSizes.iconMedium,
                                  height: AppSizes.iconMedium,
                                  child: const CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                                )
                                : Text("S'inscrire", style: AppTextStyles.buttonText),
                      ),
                    ),

                    SizedBox(height: AppSizes.spacingXLarge),

                    // Section d'aide
                    Container(
                      padding: AppEdgeInsets.medium,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                        border: Border.all(color: AppColors.textLight.withOpacity(0.3), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: AppColors.primary, size: AppSizes.iconMedium),
                              SizedBox(width: AppSizes.spacingMedium),
                              Text(
                                'Informations importantes',
                                style: AppTextStyles.label.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          SizedBox(height: AppSizes.spacingSmall),
                          Text(
                            '• Votre numéro de téléphone sera vérifié par SMS\n'
                            '• Assurez-vous d\'avoir accès à ce numéro\n'
                            '• Les données sont sécurisées et confidentielles',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.text, height: 1.4),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppSizes.spacingLarge),

                    // Liens de navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            Routes.navigateTo(Routes.emergency);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingMedium, vertical: AppSizes.spacingSmall),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                              border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.emergency, color: Colors.red, size: AppSizes.iconSmall),
                                SizedBox(width: AppSizes.spacingXSmall),
                                Text(
                                  "Urgence",
                                  style: AppTextStyles.bodySmall.copyWith(color: Colors.red, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Routes.navigateTo(Routes.login);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingMedium, vertical: AppSizes.spacingSmall),
                            child: Text("Déjà un compte ? Se connecter", style: AppTextStyles.link),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSubmit() async {
    if (_controller.formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final authService = AuthService();

      try {
        // Étape 1 : Inscription de l'utilisateur
        final registrationResult = await authService.registerUser(
          fullName: _controller.nameController.text,
          phoneNumber: _controller.phoneController.text,
        );

        if (registrationResult['message'] == "Utilisateur enregistré avec succès") {
          // Étape 2 : Génération de l'OTP
          final otpResult = await authService.requestOtp(type: "create", phoneNumber: _controller.phoneController.text);

          setState(() => _isLoading = false);

          if (otpResult['message'] == "OTP créé avec succès et SMS envoyé avec succès.") {
            // Navigation vers OTP avec le numéro de téléphone
            if (mounted) {
              Routes.push(OtpScreen(phoneNumber: _controller.phoneController.text));
            }
          } else {
            // Affichage d'un message d'erreur
            if (mounted) {
              _showErrorSnackBar(otpResult['message'] ?? 'Erreur lors de la création de l\'OTP');
            }
          }
        } else {
          setState(() => _isLoading = false);
          // Affichage d'un message d'erreur
          if (mounted) {
            _showErrorSnackBar(registrationResult['message'] ?? 'Erreur lors de l\'inscription');
          }
        }
      } catch (e) {
        setState(() => _isLoading = false);

        if (mounted) {
          _showErrorSnackBar('Une erreur est survenue: ${e.toString()}');
        }
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: AppEdgeInsets.medium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSmall)),
        action: SnackBarAction(
          label: 'OK',
          textColor: AppColors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
