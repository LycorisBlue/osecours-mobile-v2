import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RegistrationController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final FocusNode nameFocusNode = FocusNode();
  final FocusNode phoneFocusNode = FocusNode();

  final AuthService _authService = AuthService();

  bool isLoading = false;
  bool isNameValid = false;
  bool isPhoneValid = false;

  // Pour la gestion du focus
  bool isNameFocused = false;
  bool isPhoneFocused = false;

  // Initialise les écouteurs de focus
  void initFocusListeners(Function setState) {
    nameFocusNode.addListener(() {
      setState(() => isNameFocused = nameFocusNode.hasFocus);
    });

    phoneFocusNode.addListener(() {
      setState(() => isPhoneFocused = phoneFocusNode.hasFocus);
    });

    nameController.addListener(() {
      setState(() => isNameValid = nameController.text.isNotEmpty);
    });

    phoneController.addListener(() {
      setState(() => isPhoneValid = RegExp(r'^\+?[0-9]{10,}$').hasMatch(phoneController.text));
    });
  }

  // Validation du numéro de téléphone
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre numéro';
    }
    if (!RegExp(r'^\d{10,}$').hasMatch(value)) {
      return 'Numéro de téléphone invalide';
    }
    if (!RegExp(r'^(01|05|07)').hasMatch(value)) {
      return 'Le numéro doit commencer par 01, 05 ou 07';
    }
    return null;
  }

  // Validation du nom
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre nom complet';
    }
    return null;
  }

  // Soumission du formulaire
  Future<Map<String, dynamic>> handleSubmit() async {
    if (!formKey.currentState!.validate()) {
      return {'success': false, 'message': 'Veuillez corriger les erreurs du formulaire'};
    }

    try {
      // Inscription de l'utilisateur
      final registrationResult = await _authService.registerUser(
        fullName: nameController.text,
        phoneNumber: phoneController.text,
      );

      if (registrationResult['message'] == "Utilisateur enregistré avec succès") {
        // Génération de l'OTP
        final otpResult = await _authService.requestOtp(type: "create", phoneNumber: phoneController.text);

        if (otpResult['message'] == "OTP créé avec succès et SMS envoyé avec succès.") {
          return {'success': true, 'message': 'Inscription réussie', 'phoneNumber': phoneController.text};
        } else {
          return {'success': false, 'message': otpResult['message'] ?? 'Erreur lors de la création de l\'OTP'};
        }
      } else {
        return {'success': false, 'message': registrationResult['message'] ?? 'Erreur lors de l\'inscription'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Une erreur s\'est produite: $e'};
    }
  }

  // Affiche la boîte de dialogue de confirmation de sortie
  Future<bool?> showExitConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quitter l\'application'),
          content: const Text('Êtes-vous sûr de vouloir quitter l\'application ?'),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Quitter')),
          ],
        );
      },
    );
  }

  // Nettoyage des ressources à la destruction
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    nameFocusNode.dispose();
    phoneFocusNode.dispose();
  }
}
