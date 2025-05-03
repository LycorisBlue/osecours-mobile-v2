import 'package:flutter/material.dart';
import 'package:osecours/screens/otp/index.dart';
import '../../core/constants/colors.dart';
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
                      "Inscrivez-vous pour accéder à O'secours",
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 30),

                    // Nom complet
                    const Text('Nom complet', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _controller.nameController,
                      focusNode: _controller.nameFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Entrez votre nom complet',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: Icon(Icons.person, color: _controller.isNameFocused ? AppColors.primary : Colors.grey),
                        suffixIcon:
                            _controller.nameController.text.isNotEmpty
                                ? Icon(
                                  _controller.isNameValid ? Icons.check_circle : Icons.cancel,
                                  color: _controller.isNameValid ? Colors.green : AppColors.primary,
                                )
                                : null,
                      ),
                      validator: _controller.validateName,
                    ),

                    const SizedBox(height: 20),

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

                    // Bouton S'inscrire
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
                                  "S'inscrire",
                                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () {
                        Routes.navigateTo(Routes.emergency);
                      },
                      child: const Text(
                        "Numéros d'urgence",
                        style: TextStyle(color: AppColors.primary, decoration: TextDecoration.underline),
                      ),
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () {
                        Routes.navigateTo(Routes.login);
                      },
                      child: const Text(
                        "Se connecter",
                        style: TextStyle(color: AppColors.primary, decoration: TextDecoration.underline),
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
              // Utilisation du service de navigation pour rediriger vers l'écran OTP
              Routes.push(OtpScreen(phoneNumber: _controller.phoneController.text));
            }
          } else {
            // Affichage d'un message d'erreur
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(otpResult['message'] ?? 'Erreur lors de la création de l\'OTP'),
                  backgroundColor: AppColors.primary,
                ),
              );
            }
          }
        } else {
          setState(() => _isLoading = false);

          // Affichage d'un message d'erreur
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(registrationResult['message'] ?? 'Erreur lors de l\'inscription'),
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
