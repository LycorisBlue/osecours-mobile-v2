// lib/screens/login/index.dart
import 'package:flutter/material.dart';
import 'package:osecours/core/constants/colors.dart';
import 'package:osecours/core/constants/sizes.dart';
import 'package:osecours/core/constants/themes.dart';
import 'package:osecours/screens/login/controllers.dart';
import 'package:osecours/screens/otp/index.dart';
import 'package:osecours/services/navigation_service.dart';

import '../../services/auth_service.dart';

/// Écran de connexion permettant à l'utilisateur de s'authentifier avec un numéro de téléphone
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController _controller = LoginController();
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
                    Text("Connectez-vous à O'secours", style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight)),
                    SizedBox(height: AppSizes.spacingXLarge),

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

                    // Bouton Se connecter
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
                                : Text("Se connecter", style: AppTextStyles.buttonText),
                      ),
                    ),

                    SizedBox(height: AppSizes.spacingLarge),

                    // Liens supplémentaires
                    InkWell(
                      onTap: () {
                        Routes.navigateTo(Routes.emergency);
                      },
                      child: Text("Numéros d'urgence", style: AppTextStyles.link),
                    ),
                    SizedBox(height: AppSizes.spacingLarge),
                    InkWell(
                      onTap: () {
                        Routes.navigateTo(Routes.registration);
                      },
                      child: Text("S'inscrire", style: AppTextStyles.link),
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

  /// Gère la soumission du formulaire de connexion
  void _handleSubmit() async {
    if (_controller.formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final authService = AuthService();

      try {
        // Demander un OTP pour la connexion
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(otpResult['message'] ?? 'Erreur lors de l\'envoi de l\'OTP'),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
                margin: AppEdgeInsets.medium,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSmall)),
              ),
            );
          }
        }
      } catch (e) {
        setState(() => _isLoading = false);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Une erreur est survenue: ${e.toString()}'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              margin: AppEdgeInsets.medium,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSmall)),
            ),
          );
        }
      }
    }
  }
}
