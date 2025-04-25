// lib/screens/login/controllers.dart

import 'package:flutter/material.dart';
import 'package:osecours/services/auth_service.dart';

/// Controller pour gérer la logique de la page de connexion
class LoginController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  final FocusNode phoneFocusNode = FocusNode();

  final AuthService _authService = AuthService();

  // État du formulaire
  bool isLoading = false;
  bool isPhoneValid = false;
  bool isPhoneFocused = false;

  /// Initialise les écouteurs de focus et de validation
  void initFocusListeners(Function setState) {
    // Écouteur de focus
    phoneFocusNode.addListener(() {
      setState(() => isPhoneFocused = phoneFocusNode.hasFocus);
    });

    // Écouteur de validation du numéro
    phoneController.addListener(() {
      setState(() {
        isPhoneValid = RegExp(r'^\+?[0-9]{10,}$').hasMatch(phoneController.text);
      });
    });
  }

  /// Valide le numéro de téléphone saisi
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

  /// Gère la soumission du formulaire de connexion
  Future<Map<String, dynamic>> handleSubmit() async {
    if (!formKey.currentState!.validate()) {
      return {'success': false, 'message': 'Veuillez corriger les erreurs du formulaire'};
    }

    try {
      // Demande d'un code OTP pour le numéro fourni
      final otpResult = await _authService.requestOtp(type: "login", phoneNumber: phoneController.text);

      if (otpResult['message'] == "OTP créé avec succès et SMS envoyé avec succès.") {
        return {'success': true, 'message': 'Code envoyé avec succès', 'phoneNumber': phoneController.text};
      } else {
        return {'success': false, 'message': otpResult['message'] ?? 'Erreur lors de l\'envoi du code OTP'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Une erreur s\'est produite: $e'};
    }
  }

  /// Affiche la boîte de dialogue de confirmation pour quitter l'application
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

  /// Libère les ressources
  void dispose() {
    phoneController.dispose();
    phoneFocusNode.dispose();
  }
}
