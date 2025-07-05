// lib/screens/emergency/index.dart
import 'package:flutter/material.dart';
import 'package:osecours/core/constants/colors.dart';
import 'package:osecours/services/navigation_service.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/emergency_data.dart';

/// Écran affichant les numéros d'urgence que l'utilisateur peut appeler
class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Numéros d'urgences",
          style: TextStyle(fontFamily: 'Poppins', fontSize: 20.0, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.text), onPressed: () => Navigator.pop(context)),
        foregroundColor: AppColors.text,
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          // Si l'utilisateur glisse de gauche à droite (vitesse positive en x)
          if (details.primaryVelocity! > 0) {
            // Vérifier si nous pouvons retourner en arrière
            if (Navigator.of(context).canPop()) {
              Routes.goBack();
            }
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image d'en-tête
            ClipRRect(
              borderRadius: BorderRadius.zero,
              child: Image.asset(
                'assets/pictures/pexels-shvetsa-5965109.jpg', // Assurez-vous que cette image existe
                fit: BoxFit.cover,
                height: 200,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback si l'image n'existe pas
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey)),
                  );
                },
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                itemCount: EmergencyData.emergencyNumbers.length,
                separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
                itemBuilder: (context, index) {
                  final emergency = EmergencyData.emergencyNumbers[index];
                  return _buildEmergencyItem(context, emergency: emergency);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyItem(BuildContext context, {required EmergencyNumber emergency}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icône principale
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: emergency.color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: emergency.getIcon(size: 24),
          ),
          const SizedBox(width: 16),
          // Texte titre
          Expanded(
            child: Text(
              emergency.title,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 16.0, fontWeight: FontWeight.w600, color: AppColors.text),
            ),
          ),
          // Icône de téléphone
          IconButton(
            icon: const Icon(Icons.phone, color: AppColors.primary),
            onPressed: () {
              _makePhoneCall(emergency.number);
            },
          ),
          const SizedBox(width: 2),
          // Numéro de téléphone
          Text(
            emergency.number,
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 20.0, fontWeight: FontWeight.bold, color: AppColors.text),
          ),
        ],
      ),
    );
  }

  /// Lance un appel téléphonique vers le numéro spécifié
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);

    try {
      // Vérifie si le schéma 'tel:' peut être lancé
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);
      } else {
        debugPrint('Impossible de lancer l\'appel vers $phoneNumber');
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'appel: $e');
    }
  }
}
