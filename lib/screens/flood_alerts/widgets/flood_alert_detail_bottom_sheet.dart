// lib/screens/flood_alerts/widgets/flood_alert_detail_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/themes.dart';
import '../../../data/models/flood_alert_models.dart';

/// Bottom sheet pour afficher les détails d'une alerte d'inondation
class FloodAlertDetailBottomSheet extends StatelessWidget {
  final FloodAlert alert;
  final Position userPosition;

  const FloodAlertDetailBottomSheet({super.key, required this.alert, required this.userPosition});

  /// Affiche le bottom sheet
  static void show(BuildContext context, {required FloodAlert alert, required Position userPosition}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FloodAlertDetailBottomSheet(alert: alert, userPosition: userPosition),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.75,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLarge)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec poignée de glissement
          _buildHeader(),

          // Titre et statut
          _buildTitleSection(),

          // Carte
          _buildMapSection(),

          // Informations détaillées
          Expanded(child: _buildDetailsSection()),

          // Bouton d'action
          _buildActionButton(context),
        ],
      ),
    );
  }

  /// Header avec poignée
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: AppSizes.spacingMedium),
      child: Container(
        width: 40,
        height: 5,
        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(3)),
      ),
    );
  }

  /// Section titre et statut
  Widget _buildTitleSection() {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSizes.spacingMedium, 0, AppSizes.spacingMedium, AppSizes.spacingMedium),
      child: Row(
        children: [
          const Icon(Icons.water_drop, color: Colors.blue, size: 24),
          SizedBox(width: AppSizes.spacingSmall),
          Expanded(child: Text('Alerte d\'inondation', style: AppTextStyles.heading3)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingSmall, vertical: AppSizes.spacingXSmall),
            decoration: BoxDecoration(color: alert.getStatusColor().withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(
              alert.getStatusText(),
              style: TextStyle(color: alert.getStatusColor(), fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// Section carte
  Widget _buildMapSection() {
    return Container(
      height: 200,
      margin: EdgeInsets.symmetric(horizontal: AppSizes.spacingMedium),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        child: FlutterMap(
          options: MapOptions(initialCenter: LatLng(alert.location.lat, alert.location.lng), initialZoom: 13),
          children: [
            TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.app'),
            MarkerLayer(
              markers: [
                // Marqueur pour l'alerte
                Marker(
                  width: 40,
                  height: 40,
                  point: LatLng(alert.location.lat, alert.location.lng),
                  child: const Icon(Icons.water_drop, color: Colors.blue, size: 30),
                ),
                // Marqueur pour l'utilisateur
                Marker(
                  width: 40,
                  height: 40,
                  point: LatLng(userPosition.latitude, userPosition.longitude),
                  child: Container(
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.8), shape: BoxShape.circle),
                    child: const Icon(Icons.person_pin_circle, color: Colors.white, size: 30),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Section détails
  Widget _buildDetailsSection() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSizes.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Message d'avertissement
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.spacingMedium),
            margin: EdgeInsets.only(bottom: AppSizes.spacingMedium),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(color: Colors.blue),
            ),
            child: Text(alert.warningMessage, style: AppTextStyles.bodyMedium.copyWith(color: Colors.blue)),
          ),

          // Adresse
          _buildInfoRow(title: 'Adresse', content: alert.address, icon: Icons.location_on),

          // Description
          _buildInfoRow(title: 'Description', content: alert.description, icon: Icons.description),

          // Distance
          _buildInfoRow(
            title: 'Distance',
            content: '${alert.distance.toStringAsFixed(1)} km de votre position',
            icon: Icons.directions,
          ),
        ],
      ),
    );
  }

  /// Widget pour une ligne d'information
  Widget _buildInfoRow({required String title, required String content, required IconData icon}) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.spacingMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          SizedBox(width: AppSizes.spacingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                SizedBox(height: AppSizes.spacingXSmall),
                Text(content, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Bouton d'action
  Widget _buildActionButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSizes.spacingMedium),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: EdgeInsets.symmetric(vertical: AppSizes.spacingMedium),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusButton)),
          ),
          child: Text('Fermer', style: AppTextStyles.buttonText),
        ),
      ),
    );
  }
}
