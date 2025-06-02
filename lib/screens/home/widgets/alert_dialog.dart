// lib/screens/home/widgets/alert_dialog.dart
import 'package:flutter/material.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/themes.dart';
import '../../../services/alert_service.dart';
import '../controllers/alert_creation_controller.dart';

class AlertDialog extends StatefulWidget {
  final AlertType alertType;

  const AlertDialog({super.key, required this.alertType});

  @override
  State<AlertDialog> createState() => _AlertDialogState();
}

class _AlertDialogState extends State<AlertDialog> {
  late AlertCreationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AlertCreationController();
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: EdgeInsets.all(AppSizes.spacingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: AppSizes.spacingMedium),
            _buildMediaSection(),
            SizedBox(height: AppSizes.spacingMedium),
            _buildMessageSection(),
            SizedBox(height: AppSizes.spacingLarge),
            _buildSendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: RichText(
            text: TextSpan(
              text: 'Vérifiez la ou les ',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.text),
              children: const [
                TextSpan(text: 'médias', style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: ' que vous souhaitez envoyer aux '),
                TextSpan(text: 'secours', style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: '.'),
              ],
            ),
          ),
        ),
        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      ],
    );
  }

  Widget _buildMediaSection() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSizes.spacingMedium,
      crossAxisSpacing: AppSizes.spacingMedium,
      children: List.generate(3, (index) => _buildMediaSlot(index)),
    );
  }

  Widget _buildMediaSlot(int index) {
    final media = _controller.selectedMedia[index];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.primary),
      ),
      child: media == null ? _buildEmptyMediaSlot(index) : _buildFilledMediaSlot(index, media),
    );
  }

  Widget _buildEmptyMediaSlot(int index) {
    return InkWell(
      onTap:
          _controller.isLoading || _controller.isSubmitting ? null : () => _controller.showMediaPicker(context, index, setState),
      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_controller.isLoading)
            SizedBox(
              width: AppSizes.iconMedium,
              height: AppSizes.iconMedium,
              child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
            )
          else
            Icon(Icons.add_a_photo, color: AppColors.primary, size: AppSizes.iconMedium),
          SizedBox(height: AppSizes.spacingXSmall),
          Text('Ajouter', style: TextStyle(color: AppColors.primary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildFilledMediaSlot(int index, MediaFile media) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          child: GestureDetector(
            onTap: null,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child:
                  media.isVideo
                      ? _buildVideoPreview()
                      : Image.file(
                        media.file,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) => _buildErrorMedia(),
                      ),
            ),
          ),
        ),

        // Bouton supprimer
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _controller.removeMedia(index, setState),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),

        // Label vidéo (comme dans l'ancien projet)
        if (media.isVideo)
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
              child: const Text('10s', style: TextStyle(color: Colors.white, fontSize: 10)),
            ),
          ),
      ],
    );
  }

  Widget _buildVideoPreview() {
    return Container(
      color: Colors.black,
      child: const Center(child: Icon(Icons.play_circle_outline, color: Colors.white, size: 40)),
    );
  }

  Widget _buildErrorMedia() {
    return Container(
      color: Colors.grey[200],
      width: double.infinity,
      height: double.infinity,
      child: const Center(child: Icon(Icons.error_outline, color: Colors.grey)),
    );
  }

  Widget _buildMessageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Message (optionnel) ...', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        SizedBox(height: AppSizes.spacingSmall),
        Container(
          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(AppSizes.radiusSmall)),
          child: TextField(
            controller: _controller.descriptionController,
            maxLines: 3,
            minLines: 3,
            enabled: !_controller.isSubmitting,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12),
              hintText: 'Écrivez votre message ici...',
              hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSendButton() {
    final bool hasMedia = _controller.hasMedia;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: hasMedia ? AppColors.primary : Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSmall)),
        ),
        onPressed: !hasMedia || _controller.isSubmitting ? null : _handleSubmit,
        child:
            _controller.isSubmitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Envoyer', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }


  Future<void> _handleSubmit() async {
    final result = await _controller.submitAlert(widget.alertType, setState);

    if (mounted) {
      if (result['success']) {
        // Fermer le dialog et afficher un message de succès
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message']), backgroundColor: Colors.green));
      } else {
        // Afficher l'erreur (optionnel car le controller gère déjà)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message']), backgroundColor: Colors.red));
      }
    }
  }
}
