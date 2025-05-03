// lib/screens/login/index.dart
import 'package:flutter/material.dart';
import 'package:osecours/core/constants/colors.dart';
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
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Form(
                key: _controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),

                    // Header
                    const Text('Bonjour 👋', style: TextStyle(fontFamily: 'Poppins', fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    const Text(
                      "Connectez-vous à O'secours",
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 30),

                    // Numéro de téléphone
                    const Text('Numéro de téléphone', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _controller.phoneController,
                      focusNode: _controller.phoneFocusNode,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: InputDecoration(
                        hintText: 'Entrez votre numéro de téléphone',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: Icon(Icons.phone, color: _controller.isPhoneFocused ? AppColors.primary : Colors.grey),
                        suffixIcon:
                            _controller.phoneController.text.isNotEmpty
                                ? Icon(
                                  _controller.isPhoneValid ? Icons.check_circle : Icons.cancel,
                                  color: _controller.isPhoneValid ? Colors.green : AppColors.primary,
                                )
                                : null,
                      ),
                      validator: _controller.validatePhone,
                    ),

                    const SizedBox(height: 30),

                    // Bouton Se connecter
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child:
                            _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                  "Se connecter",
                                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Liens supplémentaires
                    InkWell(
                      onTap: () {
                        Routes.navigateTo(Routes.emergency);
                      },
                      child: const Text(
                        "Numéros d'urgence",
                        style: TextStyle(color: AppColors.primary, decoration: TextDecoration.underline, fontFamily: 'Poppins'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () {
                        Routes.navigateTo(Routes.registration);
                      },
                      child: const Text(
                        "S'inscrire",
                        style: TextStyle(color: AppColors.primary, decoration: TextDecoration.underline, fontFamily: 'Poppins'),
                      ),
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
            // Utilisation du service de navigation pour rediriger vers l'écran OTP
            Routes.push(OtpScreen(phoneNumber: _controller.phoneController.text));
          }
        } else {
          // Affichage d'un message d'erreur
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(otpResult['message'] ?? 'Erreur lors de l\'envoi de l\'OTP'),
                backgroundColor: AppColors.primary,
              ),
            );
          }
        }
      } catch (e) {
        setState(() => _isLoading = false);

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Une erreur est survenue: ${e.toString()}'), backgroundColor: AppColors.primary));
        }
      }
    }
  }
}
