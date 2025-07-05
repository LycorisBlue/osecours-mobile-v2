// lib/screens/profile/index.dart
import 'package:flutter/material.dart';
import 'package:osecours/services/navigation_service.dart';
import '../../core/constants/sizes.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/themes.dart';
import 'controller.dart';
import 'widgets/profile_photo_widget.dart';
import 'widgets/profile_info_item.dart';

/// Page principale du profil utilisateur
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileController _controller;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _controller = ProfileController();
    _controller.initialize(setState);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Rafraîchit les données du profil
  Future<void> _handleRefresh() async {
    await _controller.refreshProfile(setState);
  }

  /// Gère les messages d'erreur
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: AppEdgeInsets.medium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSmall)),
        action: SnackBarAction(
          label: 'OK',
          textColor: AppColors.white,
          onPressed: () {
            _controller.clearError(setState);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Afficher l'erreur si elle existe
    if (_controller.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar(_controller.error!);
      });
    }

    return GestureDetector(
            onHorizontalDragEnd: (details) {
        // Si l'utilisateur glisse de gauche à droite (vitesse positive en x)
        if (details.primaryVelocity! > 0) {
          // Vérifier si nous pouvons retourner en arrière
          if (Navigator.of(context).canPop()) {
            Routes.goBack();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.text, size: AppSizes.iconMedium),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Mon profil', style: AppTextStyles.heading3),
          centerTitle: true,
          actions: [
            // Bouton de rafraîchissement
            IconButton(
              icon: Icon(Icons.refresh, color: AppColors.text, size: AppSizes.iconMedium),
              onPressed: _controller.isLoading ? null : _handleRefresh,
            ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading && _controller.fullName.isEmpty) {
      return _buildLoadingState();
    }

    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _handleRefresh,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: AppEdgeInsets.screen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: AppSizes.spacingLarge),

              // Section photo de profil
              _buildProfilePhotoSection(),

              SizedBox(height: AppSizes.spacingXLarge),

              // Section informations personnelles
              _buildPersonalInfoSection(),

              SizedBox(height: AppSizes.spacingLarge),

              // Section contact
              _buildContactSection(),

              SizedBox(height: AppSizes.spacingLarge),

              // Section compte
              _buildAccountSection(),

              SizedBox(height: AppSizes.spacingXLarge),
            ],
          ),
        ),
      ),
    );
  }

  /// État de chargement initial
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: AppSizes.spacingMedium),
          Text('Chargement du profil...', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight)),
        ],
      ),
    );
  }

  /// Section photo de profil
  Widget _buildProfilePhotoSection() {
    return Column(
      children: [
        ProfilePhotoWidget(
          photoUrl: _controller.fullPhotoUrl,
          userInitials: _controller.userInitials,
          isUploading: _controller.isUploadingImage,
          onTap: () => _controller.showImageSourceSelector(context, setState),
          size: 120,
        ),
        SizedBox(height: AppSizes.spacingMedium),
        Text(
          _controller.fullName.isNotEmpty ? _controller.fullName : 'Utilisateur',
          style: AppTextStyles.heading2,
          textAlign: TextAlign.center,
        ),
        if (_controller.role.isNotEmpty) ...[
          SizedBox(height: AppSizes.spacingSmall),
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingMedium, vertical: AppSizes.spacingXSmall),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
            ),
            child: Text(
              _formatRole(_controller.role),
              style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ],
    );
  }

  /// Section informations personnelles
  Widget _buildPersonalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: AppSizes.spacingSmall),
          child: Text('Informations personnelles', style: AppTextStyles.heading3.copyWith(fontSize: AppSizes.h3 * 0.9)),
        ),
        SizedBox(height: AppSizes.spacingMedium),

        // Nom complet
        ReadOnlyProfileInfoItem(
          text: _controller.fullName.isNotEmpty ? _controller.fullName : 'Non renseigné',
          label: 'Nom complet',
          icon: Icons.person_outline,
        ),
      ],
    );
  }

  /// Section contact
  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: AppSizes.spacingSmall),
          child: Text('Contact', style: AppTextStyles.heading3.copyWith(fontSize: AppSizes.h3 * 0.9)),
        ),
        SizedBox(height: AppSizes.spacingMedium),

        // Numéro de téléphone
        ReadOnlyProfileInfoItem(
          text: _controller.formattedPhoneNumber,
          label: 'Numéro de téléphone',
          icon: Icons.phone_outlined,
          customLeading: Container(
            width: AppSizes.iconMedium,
            height: AppSizes.iconMedium,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: AppColors.textLight.withOpacity(0.3)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Image.asset(
                'assets/pictures/ci_flag.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.background,
                    child: Icon(Icons.flag, size: AppSizes.iconSmall, color: AppColors.textLight),
                  );
                },
              ),
            ),
          ),
        ),

        // Email
        EditableProfileInfoItem(
          text: _controller.hasEmail ? _controller.email : 'Ajouter votre email',
          label: 'Adresse email',
          icon: Icons.email_outlined,
          onTap: () => _controller.showEmailDialog(context, setState),
          isLoading: _controller.isAddingEmail,
          isEmpty: !_controller.hasEmail,
        ),
      ],
    );
  }

  /// Section compte
  Widget _buildAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: AppSizes.spacingSmall),
          child: Text('Compte', style: AppTextStyles.heading3.copyWith(fontSize: AppSizes.h3 * 0.9)),
        ),
        SizedBox(height: AppSizes.spacingMedium),

        // ID utilisateur
        ReadOnlyProfileInfoItem(text: 'ID: ${_controller.userId}', label: 'Identifiant', icon: Icons.badge_outlined),

        // Statut du compte
        ProfileInfoItem(
          text: _controller.isActive ? 'Compte actif' : 'Compte inactif',
          label: 'Statut',
          leadingIcon: Icons.verified_user_outlined,
          trailingWidget: Container(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingSmall, vertical: AppSizes.spacingXSmall),
            decoration: BoxDecoration(
              color: (_controller.isActive ? Colors.green : Colors.orange).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(color: (_controller.isActive ? Colors.green : Colors.orange).withOpacity(0.3), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _controller.isActive ? Icons.check_circle : Icons.warning,
                  size: AppSizes.iconSmall,
                  color: _controller.isActive ? Colors.green : Colors.orange,
                ),
                SizedBox(width: AppSizes.spacingXSmall),
                Text(
                  _controller.isActive ? 'Actif' : 'Inactif',
                  style: AppTextStyles.caption.copyWith(
                    color: _controller.isActive ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Formate le rôle pour l'affichage
  String _formatRole(String role) {
    switch (role.toUpperCase()) {
      case 'CITIZEN':
        return 'Citoyen';
      case 'ADMIN':
        return 'Administrateur';
      case 'RESCUE_MEMBER':
        return 'Secouriste';
      default:
        return role;
    }
  }
}
