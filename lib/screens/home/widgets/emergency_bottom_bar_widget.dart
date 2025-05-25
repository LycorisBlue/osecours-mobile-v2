// lib/screens/home/widgets/emergency_bottom_bar_widget.dart
import 'package:flutter/material.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/constants/colors.dart';

class EmergencyBottomBarWidget extends StatelessWidget {
  final VoidCallback onEmergencyTap;

  EmergencyBottomBarWidget({super.key, required this.onEmergencyTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEmergencyTap,
      child: Container(
        padding: EdgeInsets.all(AppSizes.spacingMedium),
        color: AppColors.primary,
        child: SafeArea(
          child: Row(
            children: [
              Icon(Icons.phone, color: AppColors.white, size: AppSizes.iconMedium),
              SizedBox(width: AppSizes.spacingSmall),
              Text(
                "Numéros d'urgence",
                style: TextStyle(fontSize: AppSizes.buttonText, fontWeight: FontWeight.w600, color: AppColors.white),
              ),
              Spacer(),
              Icon(Icons.arrow_forward_ios, color: AppColors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
