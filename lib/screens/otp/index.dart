// lib/screens/otp/index.dart
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:osecours/core/constants/colors.dart';
import 'package:osecours/core/constants/sizes.dart';
import 'package:osecours/core/constants/themes.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: AppEdgeInsets.medium,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSmall)),
        ),
      );

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: AppEdgeInsets.medium,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSmall)),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppEdgeInsets.screen,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: AppSizes.spacingXXLarge),

                // Titre
                Text('Vérification', style: AppTextStyles.heading1, textAlign: TextAlign.center),
                SizedBox(height: AppSizes.spacingMedium),

                // Description
                Text(
                  'Entrez le code à 5 chiffres envoyé au numéro ${widget.phoneNumber}',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSizes.spacingXXLarge),

                // Champs OTP
                OtpTextField(
                  numberOfFields: 5,
                  fieldWidth: AppSizes.buttonHeight, // Utilise la hauteur de bouton pour avoir des champs carrés
                  fieldHeight: AppSizes.buttonHeight,
                  borderColor: AppColors.textLight,
                  focusedBorderColor: AppColors.primary,
                  enabledBorderColor: AppColors.textLight,
                  disabledBorderColor: Colors.grey[300]!,
                  borderWidth: 2.0,
                  showFieldAsBox: true,
                  enabled: !_controller.isLoading,
                  textStyle: TextStyle(fontSize: AppSizes.h3, fontWeight: FontWeight.bold, color: AppColors.text),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  margin: EdgeInsets.symmetric(horizontal: AppSizes.spacingXSmall),
                  onCodeChanged: (String code) {
                    // Mise à jour du code lors de la saisie
                  },
                  onSubmit: (String verificationCode) {
                    _verifyOtp(verificationCode);
                  },
                ),
                SizedBox(height: AppSizes.spacingXLarge),

                // État de chargement ou actions
                if (_controller.isLoading)
                  Column(
                    children: [
                      SizedBox(
                        width: AppSizes.iconLarge,
                        height: AppSizes.iconLarge,
                        child: const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
                      ),
                      SizedBox(height: AppSizes.spacingMedium),
                      Text('Vérification en cours...', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight)),
                    ],
                  )
                else ...[
                  // Timer ou bouton de renvoi
                  if (!_controller.canResend)
                    Container(
                      padding: AppEdgeInsets.medium,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.timer, color: AppColors.primary, size: AppSizes.iconMedium),
                          SizedBox(height: AppSizes.spacingSmall),
                          Text('Renvoyer le code dans', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight)),
                          Text(
                            _controller.formatTime,
                            style: AppTextStyles.heading3.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),

                  if (_controller.canResend)
                    Column(
                      children: [
                        Icon(Icons.refresh, color: AppColors.primary, size: AppSizes.iconLarge),
                        SizedBox(height: AppSizes.spacingMedium),
                        SizedBox(
                          width: double.infinity,
                          height: AppSizes.buttonHeight,
                          child: ElevatedButton.icon(
                            onPressed: _handleResendCode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusButton)),
                              padding: AppEdgeInsets.button,
                            ),
                            icon: Icon(Icons.refresh, color: AppColors.white, size: AppSizes.iconMedium),
                            label: Text('Renvoyer le code', style: AppTextStyles.buttonText),
                          ),
                        ),
                      ],
                    ),
                ],

                SizedBox(height: AppSizes.spacingXXLarge),

                // Note d'aide
                Container(
                  padding: AppEdgeInsets.medium,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.primary, size: AppSizes.iconMedium),
                      SizedBox(width: AppSizes.spacingMedium),
                      Expanded(
                        child: Text(
                          'Si vous ne recevez pas le code, vérifiez vos SMS ou demandez un nouveau code.',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
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
