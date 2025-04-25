import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
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

  Future<void> _handleSubmit() async {
    setState(() => _isLoading = true);

    final result = await _controller.handleSubmit();

    setState(() => _isLoading = false);

    if (result['success']) {
      // Navigation vers l'écran OTP avec les paramètres
      if (mounted) {
        Routes.navigateTo(Routes.emergency);
      }
    } else {
      // Affichage du message d'erreur
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result['message']), backgroundColor: AppColors.primary));
      }
    }
  }
}
