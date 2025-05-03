// lib/screens/otp/index.dart
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:osecours/core/constants/colors.dart';
import 'package:osecours/core/constants/sizes.dart';
import 'package:osecours/core/constants/texts.dart';
import 'package:osecours/services/navigation_service.dart';

import 'controllers.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late OtpController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OtpController(phoneNumber: widget.phoneNumber);
    _controller.startTimer(setState);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp(String otp) async {
    // Masquer le clavier
    FocusScope.of(context).unfocus();

    // Vérifier l'OTP
    final result = await _controller.verifyOtp(otp, setState);

    if (mounted) {
      // Afficher le message approprié
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message']), backgroundColor: result['success'] ? Colors.green : Colors.red));

      // Si succès, rediriger vers l'écran d'accueil
      if (result['success']) {
        Routes.navigateAndRemoveAll(Routes.home);
      } else {
        // Réinitialiser le champ OTP en cas d'erreur
        setState(() => _controller.otp = '');
      }
    }
  }

  void _handleResendCode() {
    // Afficher le popup avant de renvoyer le code
    _controller.showResendOtpDialog(context, setState, (result) {
      // Afficher le message de résultat
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message']), backgroundColor: result['success'] ? Colors.green : Colors.red));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(36),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: AppSizes.paddingXLarge),
                Text('Vérification', style: AppTextStyles.heading2, textAlign: TextAlign.center),
                SizedBox(height: AppSizes.paddingMedium),
                Text(
                  'Entrez le code à 5 chiffres envoyé au numéro ${widget.phoneNumber}',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSizes.paddingXLarge),
                OtpTextField(
                  numberOfFields: 5,
                  fieldWidth: 50,
                  borderColor: AppColors.primary,
                  focusedBorderColor: AppColors.primary,
                  showFieldAsBox: true,
                  enabled: !_controller.isLoading,
                  onCodeChanged: (String code) {
                    // Mise à jour du code lors de la saisie
                  },
                  onSubmit: (String verificationCode) {
                    _verifyOtp(verificationCode);
                  },
                ),
                SizedBox(height: AppSizes.paddingLarge),
                if (_controller.isLoading)
                  const CircularProgressIndicator(color: AppColors.primary)
                else ...[
                  if (!_controller.canResend)
                    Text('Renvoyer le code dans ${_controller.formatTime}', style: AppTextStyles.bodySmall),
                  if (_controller.canResend)
                    TextButton(
                      onPressed: _handleResendCode,
                      child: Text('Renvoyer le code', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary)),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
