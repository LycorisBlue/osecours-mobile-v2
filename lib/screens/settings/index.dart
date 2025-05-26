// lib/screens/settings/index.dart
import 'package:flutter/material.dart';
import 'package:osecours/core/constants/colors.dart';
import 'package:osecours/core/constants/sizes.dart';
import 'package:osecours/core/constants/themes.dart';
import 'controller.dart';

/// Écran des paramètres avec liste continue
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SettingsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SettingsController();
    _controller.initialize(setState);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.text, size: AppSizes.iconMedium),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Paramètres', style: AppTextStyles.heading3),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section profil utilisateur en haut
            _buildUserProfileSection(),

            SizedBox(height: AppSizes.spacingMedium),

            // Section Général
            _buildGeneralSection(),

            SizedBox(height: AppSizes.spacingLarge),

            // Section Compte
            _buildAccountSection(),

            SizedBox(height: AppSizes.spacingLarge),
          ],
        ),
      ),
    );
  }

  /// Section profil utilisateur
  Widget _buildUserProfileSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.spacingLarge),
      child: Column(
        children: [
          // Avatar utilisateur
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
            ),
            child: ClipOval(
              child:
                  _controller.getProfilePhotoUrl() != null
                      ? Image.network(
                        _controller.getProfilePhotoUrl()!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultAvatar();
                        },
                      )
                      : _buildDefaultAvatar(),
            ),
          ),

          SizedBox(height: AppSizes.spacingMedium),

          // Nom utilisateur
          Text(
            _controller.userName.isNotEmpty ? _controller.userName : 'Utilisateur',
            style: AppTextStyles.heading3,
            textAlign: TextAlign.center,
          ),

          SizedBox(height: AppSizes.spacingSmall),

          // Numéro de téléphone
          Text(
            _controller.getFormattedPhone(),
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
            textAlign: TextAlign.center,
          ),

          // Email si disponible
          if (_controller.hasEmail) ...[
            SizedBox(height: AppSizes.spacingXSmall),
            Text(
              _controller.userEmail,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// Avatar par défaut avec initiales
  Widget _buildDefaultAvatar() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
      child: Center(
        child: Text(
          _controller.getUserInitials(),
          style: AppTextStyles.heading2.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// Section Général
  Widget _buildGeneralSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Général', style: AppTextStyles.heading3.copyWith(fontSize: AppSizes.h3 * 0.9)),

          SizedBox(height: AppSizes.spacingMedium),

          // Mon profil
          _buildSettingsItem(
            icon: Icons.person_outline,
            title: 'Mon profil',
            subtitle: 'Modifier vos informations personnelles',
            onTap: _controller.navigateToProfile,
          ),

          _buildDivider(),

          // Mes proches à contacter
          _buildSettingsItem(
            icon: Icons.contacts_outlined,
            title: 'Mes proches à contacter en cas d\'urgence',
            subtitle: 'Gérer vos contacts de confiance',
            onTap: _controller.navigateToSafeNumbers,
          ),

          _buildDivider(),

          // Mes lieux importants
          _buildSettingsItem(
            icon: Icons.location_on_outlined,
            title: 'Mes lieux importants',
            subtitle: 'Ajouter des adresses fréquentes',
            onTap: _controller.navigateToImportantPlaces,
          ),
        ],
      ),
    );
  }

  /// Section Compte
  Widget _buildAccountSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Compte', style: AppTextStyles.heading3.copyWith(fontSize: AppSizes.h3 * 0.9)),

          SizedBox(height: AppSizes.spacingMedium),

          // Déconnexion
          _buildSettingsItem(
            icon: Icons.logout_outlined,
            title: 'Se déconnecter',
            subtitle: 'Déconnexion de votre compte',
            onTap: () => _controller.showLogoutConfirmation(context),
            iconColor: Colors.red,
            titleColor: Colors.red,
          ),
        ],
      ),
    );
  }

  /// Widget pour un élément de paramètre
  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSizes.spacingMedium),
        child: Row(
          children: [
            // Icône
            Container(
              width: AppSizes.iconLarge,
              height: AppSizes.iconLarge,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              child: Icon(icon, color: iconColor ?? AppColors.primary, size: AppSizes.iconMedium),
            ),

            SizedBox(width: AppSizes.spacingMedium),

            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(color: titleColor ?? AppColors.text, fontWeight: FontWeight.w500),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: AppSizes.spacingXSmall),
                    Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight)),
                  ],
                ],
              ),
            ),

            // Chevron
            Icon(Icons.chevron_right, color: AppColors.textLight, size: AppSizes.iconMedium),
          ],
        ),
      ),
    );
  }

  /// Widget diviseur
  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.only(left: AppSizes.iconLarge + AppSizes.spacingMedium),
      child: Divider(height: 1, thickness: 1, color: AppColors.textLight.withOpacity(0.1)),
    );
  }
}
