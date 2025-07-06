// lib/screens/home/widgets/services_section_widget.dart
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/sizes.dart';
import '../../../services/navigation_service.dart';
import '../../chatbot/chatbot_screen.dart';

class ServicesSectionWidget extends StatelessWidget {
  const ServicesSectionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingMedium),
      child: Column(
        children: [
          _buildServiceItem(
            context,
            title: "PARLER À O'SECOURS AI",
            icon: Icons.chat_bubble_outline,
            iconColor: AppColors.primary,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatbotScreen()));
            },
          ),
          SizedBox(height: AppSizes.spacingMedium),
          _buildServiceItem(
            context,
            title: "LES PHARMACIES DE GARDE",
            icon: Icons.local_pharmacy_outlined,
            iconColor: AppColors.primary,
            onTap: () {
              Routes.navigateTo(Routes.pharmaciesGarde);
            },
          ),
          SizedBox(height: AppSizes.spacingMedium),
          _buildServiceItem(
            context,
            title: "LES CENTRES HOSPITALIERS",
            icon: Icons.local_hospital_outlined,
            iconColor: AppColors.primary,
            onTap: () {
              Routes.navigateTo(Routes.centresHospitaliers);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSizes.spacingMedium),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSizes.spacingSmall),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              child: Icon(icon, color: iconColor, size: AppSizes.iconMedium),
            ),
            SizedBox(width: AppSizes.spacingMedium),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: AppSizes.bodyMedium, fontWeight: FontWeight.w600, color: AppColors.text),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: AppColors.textLight, size: AppSizes.iconSmall),
          ],
        ),
      ),
    );
  }
}
