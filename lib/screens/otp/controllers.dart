// lib/screens/otp/controllers.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../services/auth_service.dart';

/**
 * Contrôleur pour la gestion de l'écran OTP.
 * 
 * Cette classe gère:
 * - Le minuteur OTP
 * - La validation des codes OTP
 * - La vérification des OTP auprès du serveur
 * - La navigation après vérification réussie
 */
class OtpController {
  final TextEditingController otpController = TextEditingController();
  final AuthService _authService = AuthService();

  // Variables d'état
  bool isLoading = false;
  int timerSeconds = 120; // 2 minutes par défaut
  bool canResend = false;
  Timer? _timer;
  String otp = '';

  // Propriétés passées à l'initialisation
  final String phoneNumber;

  // Constructeur
  OtpController({required this.phoneNumber});

  /**
   * Démarre le minuteur pour l'expiration de l'OTP.
   * 
   * Met à jour timerSeconds et canResend selon le temps écoulé.
   * Nécessite une fonction de setState pour mettre à jour l'UI.
   */
  void startTimer(Function(void Function()) setState) {
    _timer?.cancel();
    setState(() {
      timerSeconds = 120;
      canResend = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timerSeconds > 0) {
          timerSeconds--;
        } else {
          canResend = true;
          timer.cancel();
        }
      });
    });
  }

  /**
   * Formate le temps restant en format mm:ss.
   * 
   * @return String Le temps formaté
   */
  String get formatTime {
    int minutes = timerSeconds ~/ 60;
    int seconds = timerSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /**
   * Vérifie le code OTP auprès du serveur.
   * 
   * @param otp Le code OTP à vérifier
   * @param setState Fonction pour mettre à jour l'état du widget
   * @param onSuccess Fonction à appeler en cas de succès
   * @param onError Fonction à appeler en cas d'erreur
   */
  Future<Map<String, dynamic>> verifyOtp(String otp, Function(void Function()) setState) async {
    setState(() => isLoading = true);

    try {
      final result = await _authService.verifyOtp(otp: otp, phoneNumber: phoneNumber);

      setState(() => isLoading = false);

      if (result['message'] == "OTP vérifié avec succès") {
        // Récupération des données utilisateur et du token
        final userData = result['data']['user'];
        final token = result['data']['token'];

        // Sauvegarde des données dans Hive
        final box = Hive.box('auth');
        await box.put('userId', userData['id']);
        await box.put('fullName', '${userData['firstName']} ${userData['lastName']}');
        await box.put('phoneNumber', userData['phoneNumber']);
        await box.put('photo', userData['photoUrl']);
        await box.put('role', userData['role']);
        await box.put('isActive', userData['isActive']);
        await box.put('token', token);
        await box.put('isLoggedIn', true);

        return {'success': true, 'message': result['message'] ?? 'OTP vérifié avec succès'};
      } else {
        return {'success': false, 'message': result['message'] ?? 'Code OTP invalide'};
      }
    } catch (e) {
      setState(() => isLoading = false);
      return {'success': false, 'message': 'Une erreur est survenue: ${e.toString()}'};
    }
  }

  /**
   * Demande un nouveau code OTP.
   * 
   * @param setState Fonction pour mettre à jour l'état du widget
   * @param onSuccess Fonction à appeler en cas de succès
   * @param onError Fonction à appeler en cas d'erreur
   */
  Future<Map<String, dynamic>> resendOtp(Function(void Function()) setState) async {
    setState(() => isLoading = true);

    try {
      final result = await _authService.requestOtp(type: "resend", phoneNumber: phoneNumber);

      setState(() => isLoading = false);

      if (result['message'] == "OTP régénéré et envoyé avec succès") {
        startTimer(setState);
        return {'success': true, 'message': result['message'] ?? 'Nouveau code OTP envoyé avec succès'};
      } else {
        return {'success': false, 'message': result['message'] ?? 'Erreur lors du renvoi de l\'OTP'};
      }
    } catch (e) {
      setState(() => isLoading = false);
      return {'success': false, 'message': 'Une erreur est survenue: ${e.toString()}'};
    }
  }

  /**
   * Affiche une boîte de dialogue pour confirmer le renvoi de l'OTP.
   */
  void showResendOtpDialog(BuildContext context, Function(void Function()) setState, Function(Map<String, dynamic>) onResult) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Redemander le code OTP'),
          content: Text(
            'Votre numéro de téléphone est $phoneNumber. Que souhaitez-vous faire ?',
            style: const TextStyle(fontFamily: 'Poppins'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Redemander un nouveau code'),
              onPressed: () async {
                Navigator.of(context).pop(); // Fermer le popup
                final result = await resendOtp(setState); // Envoyer la demande de renvoi
                onResult(result);
              },
            ),
            TextButton(
              child: const Text('Retour à l\'inscription'),
              onPressed: () {
                Navigator.of(context).pop(); // Fermer le popup
                Navigator.of(context).pop(); // Retourner à l'écran précédent
              },
            ),
          ],
        );
      },
    );
  }

  /**
   * Nettoyage des ressources en fin de vie du contrôleur
   */
  void dispose() {
    _timer?.cancel();
    otpController.dispose();
  }
}
