// lib/core/utils/media_viewer_popup.dart
import 'package:flutter/material.dart';
import 'dart:io';
import '../constants/sizes.dart';
import '../constants/colors.dart';
import '../constants/themes.dart';

class MediaViewerPopup extends StatelessWidget {
  final String mediaPath;
  final bool isVideo;
  final String? fileName;
  final bool isNetworkImage;

  const MediaViewerPopup({super.key, required this.mediaPath, required this.isVideo, this.fileName, this.isNetworkImage = false});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black.withOpacity(0.9),
        child: Column(
          children: [
            // En-tête avec bouton fermer
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(AppSizes.spacingMedium),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Nom du fichier si disponible
                    if (fileName != null)
                      Expanded(
                        child: Text(
                          fileName!,
                          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    else
                      const Spacer(),

                    // Bouton fermer
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: Colors.white, size: AppSizes.iconLarge),
                    ),
                  ],
                ),
              ),
            ),

            // Contenu principal
            Expanded(child: Center(child: _buildContent(screenSize))),

            // Actions en bas
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(AppSizes.spacingLarge),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: Size(120, AppSizes.buttonHeight),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusButton)),
                      ),
                      child: Text('Fermer', style: AppTextStyles.buttonText),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Size screenSize) {
    if (isVideo) {
      return _buildVideoPreview(screenSize);
    } else {
      return _buildImageViewer(screenSize);
    }
  }

  Widget _buildVideoPreview(Size screenSize) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxHeight: screenSize.height * 0.6),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Fond noir pour la vidéo
          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              border: Border.all(color: Colors.white24, width: 1),
            ),
          ),

          // Icône play au centre
          Container(
            padding: EdgeInsets.all(AppSizes.spacingLarge),
            decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
            child: Icon(Icons.play_arrow, color: Colors.white, size: AppSizes.iconLarge * 2),
          ),

          // Label vidéo en bas à droite
          Positioned(
            bottom: AppSizes.spacingMedium,
            right: AppSizes.spacingMedium,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingSmall, vertical: AppSizes.spacingXSmall),
              decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(AppSizes.radiusSmall)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam, color: Colors.white, size: AppSizes.iconSmall),
                  SizedBox(width: AppSizes.spacingXSmall),
                  Text('Vidéo', style: AppTextStyles.caption.copyWith(color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageViewer(Size screenSize) {
    return InteractiveViewer(
      maxScale: 3.0,
      minScale: 0.5,
      child: Container(
        constraints: BoxConstraints(maxHeight: screenSize.height * 0.7, maxWidth: screenSize.width * 0.9),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          child:
              isNetworkImage
                  ? Image.network(
                    mediaPath,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(
                            value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
                  )
                  : Image.file(
                    File(mediaPath),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
                  ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, color: Colors.red, size: AppSizes.iconLarge),
          SizedBox(height: AppSizes.spacingMedium),
          Text('Erreur de chargement du média', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}

/// Fonction utilitaire pour afficher rapidement le popup
void showMediaViewer(
  BuildContext context, {
  required String mediaPath,
  required bool isVideo,
  String? fileName,
  bool isNetworkImage = false,
}) {
  showDialog(
    context: context,
    builder:
        (context) => MediaViewerPopup(mediaPath: mediaPath, isVideo: isVideo, fileName: fileName, isNetworkImage: isNetworkImage),
  );
}
