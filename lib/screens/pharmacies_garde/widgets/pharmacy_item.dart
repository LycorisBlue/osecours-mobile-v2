// lib/screens/pharmacies_garde/widgets/pharmacy_item.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/themes.dart';

class PharmacyItem extends StatelessWidget {
  final Map<String, dynamic> pharmacy;
  final VoidCallback? onTap;

  const PharmacyItem({super.key, required this.pharmacy, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.spacingSmall),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        border: Border.all(color: AppColors.textLight.withOpacity(0.1), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
          child: Padding(
            padding: EdgeInsets.all(AppSizes.spacingMedium),
            child: Row(
              children: [
                // Icône de pharmacie
                Container(
                  padding: EdgeInsets.all(AppSizes.spacingSmall),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                  child: Icon(Icons.local_pharmacy, size: AppSizes.iconMedium, color: AppColors.primary),
                ),
                SizedBox(width: AppSizes.spacingMedium),

                // Contenu principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nom de la pharmacie
                      Text(
                        pharmacy['name'] ?? 'Pharmacie',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.text, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppSizes.spacingXSmall),

                      // Adresse
                      Text(
                        pharmacy['address'] ?? 'Adresse non disponible',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textLight, fontWeight: FontWeight.w500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Badges de statut
                      SizedBox(height: AppSizes.spacingSmall),
                      Row(
                        children: [
                          // Badge de garde
                          if (pharmacy['is_on_duty'] == true) _buildBadge('De garde', AppColors.primary),
                          if (pharmacy['is_on_duty'] == true && pharmacy['is_active'] == true)
                            SizedBox(width: AppSizes.spacingSmall),

                          // Badge ouvert/fermé
                          _buildBadge(
                            pharmacy['is_active'] == true ? 'Ouvert' : 'Fermé',
                            pharmacy['is_active'] == true ? Colors.green : Colors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions à droite
                Column(
                  children: [
                    // Distance
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingSmall, vertical: AppSizes.spacingXSmall),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                        border: Border.all(color: AppColors.lightGrey),
                      ),
                      child: Text(
                        '${(pharmacy['distance'] ?? 0).toStringAsFixed(1)} km',
                        style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600, color: AppColors.text),
                      ),
                    ),
                    SizedBox(height: AppSizes.spacingSmall),

                    // Boutons d'action
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Bouton appeler
                        if (pharmacy['phone'] != null && pharmacy['phone'].toString().isNotEmpty)
                          GestureDetector(
                            onTap: () => _callPharmacy(pharmacy['phone']),
                            child: Container(
                              padding: EdgeInsets.all(AppSizes.spacingSmall),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                              ),
                              child: Icon(Icons.phone, size: AppSizes.iconSmall, color: AppColors.white),
                            ),
                          ),
                        if (pharmacy['phone'] != null && pharmacy['phone'].toString().isNotEmpty)
                          SizedBox(width: AppSizes.spacingSmall),

                        // Bouton directions
                        GestureDetector(
                          onTap: () => _openDirections(pharmacy),
                          child: Container(
                            padding: EdgeInsets.all(AppSizes.spacingSmall),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                              border: Border.all(color: AppColors.lightGrey),
                            ),
                            child: Icon(Icons.directions, size: AppSizes.iconSmall, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingSmall, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(text, style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w600, fontSize: 11)),
    );
  }

  void _callPharmacy(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openDirections(Map<String, dynamic> pharmacy) async {
    final lat = pharmacy['latitude'];
    final lng = pharmacy['longitude'];
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
