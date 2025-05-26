// lib/screens/profile/widgets/profile_photo_widget.dart
import 'package:flutter/material.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/themes.dart';

/// Widget réutilisable pour la photo de profil avec gestion des états
class ProfilePhotoWidget extends StatelessWidget {
  final String? photoUrl;
  final String userInitials;
  final bool isUploading;
  final VoidCallback onTap;
  final double size;

  const ProfilePhotoWidget({
    super.key,
    this.photoUrl,
    required this.userInitials,
    this.isUploading = false,
    required this.onTap,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUploading ? null : onTap,
      child: Stack(
        children: [
          // Photo de profil principale
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 3),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: ClipOval(child: _buildPhotoContent()),
          ),

          // Indicateur de chargement
          if (isUploading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(0.5)),
                child: Center(child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 3)),
              ),
            ),

          // Bouton d'édition
          if (!isUploading)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: AppSizes.iconLarge,
                height: AppSizes.iconLarge,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: Icon(Icons.camera_alt, size: AppSizes.iconMedium, color: AppColors.white),
              ),
            ),
        ],
      ),
    );
  }

  /// Construit le contenu de la photo selon l'état
  Widget _buildPhotoContent() {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return Image.network(
        photoUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value:
                  loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
              color: AppColors.primary,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
      );
    } else {
      return _buildDefaultAvatar();
    }
  }

  /// Avatar par défaut avec initiales
  Widget _buildDefaultAvatar() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
      child: Center(
        child: Text(
          userInitials,
          style: AppTextStyles.heading1.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.3, // Taille proportionnelle
          ),
        ),
      ),
    );
  }
}
