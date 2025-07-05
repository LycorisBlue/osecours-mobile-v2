// lib/screens/home/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/constants/colors.dart';
import '../../../services/navigation_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo en haut du Drawer (comme dans l'ancienne version)
          Padding(
            padding: const EdgeInsets.only(top: 100.0, bottom: 50.0),
            child: Center(child: Image.asset('assets/pictures/white-logo.png', height: 35)),
          ),
          const Divider(color: Colors.white54, thickness: .5, indent: 16, endIndent: 16),

          // Liste des options
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDrawerItem(
                    icon: Icons.person,
                    text: "Mon profil",
                    onTap: () {
                      Navigator.pop(context);
                      Routes.navigateTo(Routes.profile);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.notifications,
                    text: "Mes alertes",
                    onTap: () {
                      Navigator.pop(context);
                      Routes.navigateTo(Routes.alerts);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.water_drop,
                    text: "Alertes d'inondation",
                    onTap: () {
                      Navigator.pop(context);
                      Routes.navigateTo(Routes.floodAlerts);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.settings,
                    text: "Paramètres",
                    onTap: () {
                      Navigator.pop(context);
                      Routes.navigateTo(Routes.settings);
                    },
                  ),
                ],
              ),
            ),
          ),

          // Section de déconnexion tout en bas (comme dans l'ancienne version)
          GestureDetector(
            onTap: () async {
              Navigator.pop(context);
              _showLogoutConfirmation(context);
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.logout, color: Colors.white70, size: 18),
                  SizedBox(width: 12),
                  Text(
                    "Déconnexion",
                    style: TextStyle(fontFamily: "Poppins", color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget personnalisé pour les items du drawer (comme dans l'ancienne version)
  Widget _buildDrawerItem({required IconData icon, required String text, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.white24,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 20),
            Text(
              text,
              style: const TextStyle(fontFamily: "Poppins", color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  /// Affiche la boîte de dialogue de confirmation de déconnexion
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
          content: const Text('Voulez-vous vraiment vous déconnecter ?', style: TextStyle(fontFamily: 'Poppins')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler', style: TextStyle(color: Colors.grey, fontFamily: 'Poppins')),
            ),
            TextButton(
              onPressed: () async {
                // Nettoyer toutes les boîtes Hive
                await Hive.box('auth').clear();
                if (Hive.isBoxOpen('notifications')) {
                  await Hive.box('notifications').clear();
                }
                if (Hive.isBoxOpen('user')) {
                  await Hive.box('user').clear();
                }
                if (Hive.isBoxOpen('temp')) {
                  await Hive.box('temp').clear();
                }

                if (context.mounted) {
                  // Naviguer vers la page de connexion et effacer l'historique
                  Routes.navigateAndRemoveAll(Routes.login);
                }
              },
              child: const Text('Déconnexion', style: TextStyle(color: AppColors.primary, fontFamily: 'Poppins')),
            ),
          ],
        );
      },
    );
  }
}
