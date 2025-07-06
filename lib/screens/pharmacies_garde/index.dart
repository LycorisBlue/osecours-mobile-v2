// lib/screens/pharmacies_garde/index.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:osecours/core/constants/themes.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/sizes.dart';
import 'controller.dart';
import 'widgets/pharmacy_item.dart';

class PharmaciesGardeScreen extends StatefulWidget {
  const PharmaciesGardeScreen({super.key});

  @override
  State<PharmaciesGardeScreen> createState() => _PharmaciesGardeScreenState();
}

class _PharmaciesGardeScreenState extends State<PharmaciesGardeScreen> {
  late PharmaciesGardeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PharmaciesGardeController();
    _controller.initialize(setState);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppColors.background, appBar: _buildAppBar(), body: _buildBody());
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      title: Text('Pharmacies de garde', style: AppTextStyles.heading2.copyWith(color: AppColors.text)),
      leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: AppColors.text), onPressed: () => Navigator.of(context).pop()),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: AppColors.text),
          onPressed: _controller.isLoading ? null : () => _controller.refresh(setState),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return _buildLoadingWidget();
    }

    if (_controller.error != null) {
      return _buildErrorWidget();
    }

    if (_controller.pharmacies.isEmpty) {
      return _buildEmptyWidget();
    }

    return RefreshIndicator(
      onRefresh: () => _controller.refresh(setState),
      color: AppColors.primary,
      child: Column(
        children: [
          // En-tête avec statut de recherche
          _buildSearchStatusHeader(),

          // Liste des pharmacies
          Expanded(child: _buildPharmaciesList()),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: AppSizes.spacingLarge),
          Text(
            _controller.searchStatus.isNotEmpty ? _controller.searchStatus : 'Recherche des pharmacies...',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSizes.spacingMedium),
          Text(
            'Localisation en cours...',
            style: AppTextStyles.caption.copyWith(color: AppColors.textLight),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.spacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.r, color: AppColors.error),
            SizedBox(height: AppSizes.spacingLarge),
            Text('Erreur de recherche', style: AppTextStyles.heading3, textAlign: TextAlign.center),
            SizedBox(height: AppSizes.spacingMedium),
            Text(
              _controller.error ?? 'Une erreur est survenue',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.spacingLarge),
            ElevatedButton(
              onPressed: () => _controller.refresh(setState),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingXLarge, vertical: AppSizes.spacingMedium),
              ),
              child: Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.spacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_pharmacy_outlined, size: 64.r, color: AppColors.textLight),
            SizedBox(height: AppSizes.spacingLarge),
            Text('Aucune pharmacie trouvée', style: AppTextStyles.heading3, textAlign: TextAlign.center),
            SizedBox(height: AppSizes.spacingMedium),
            Text(
              'Aucune pharmacie de garde n\'a été trouvée dans un rayon de 10km.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.spacingLarge),
            ElevatedButton(
              onPressed: () => _controller.refresh(setState),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingXLarge, vertical: AppSizes.spacingMedium),
              ),
              child: Text('Rechercher à nouveau'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchStatusHeader() {
    return Container(
      width: double.infinity,
      color: AppColors.white,
      padding: EdgeInsets.all(AppSizes.spacingMedium),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSizes.spacingSmall),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: Icon(Icons.my_location, color: AppColors.primary, size: AppSizes.iconMedium),
              ),
              SizedBox(width: AppSizes.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _controller.searchStatus.isNotEmpty ? _controller.searchStatus : 'Pharmacies trouvées',
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${_controller.totalPharmacies} pharmacie(s) de garde',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textLight),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Indicateur de rayon de recherche
          if (_controller.currentRadius > 0) ...[
            SizedBox(height: AppSizes.spacingMedium),
            Container(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingMedium, vertical: AppSizes.spacingSmall),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                border: Border.all(color: AppColors.lightGrey),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.radar, size: AppSizes.iconSmall, color: AppColors.primary),
                  SizedBox(width: AppSizes.spacingSmall),
                  Text(
                    'Rayon de recherche: ${_controller.currentRadius}km',
                    style: AppTextStyles.caption.copyWith(color: AppColors.text, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPharmaciesList() {
    return ListView.builder(
      padding: EdgeInsets.all(AppSizes.spacingMedium),
      itemCount: _controller.pharmacies.length,
      itemBuilder: (context, index) {
        final pharmacy = _controller.pharmacies[index];
        return PharmacyItem(pharmacy: pharmacy, onTap: () => _showPharmacyDetails(pharmacy));
      },
    );
  }

  void _showPharmacyDetails(Map<String, dynamic> pharmacy) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPharmacyDetailsModal(pharmacy),
    );
  }

  Widget _buildPharmacyDetailsModal(Map<String, dynamic> pharmacy) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radiusLarge),
          topRight: Radius.circular(AppSizes.radiusLarge),
        ),
      ),
      padding: EdgeInsets.all(AppSizes.spacingLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 50.w,
              height: 4.h,
              decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(2.r)),
            ),
          ),
          SizedBox(height: AppSizes.spacingLarge),

          // Nom et badge de garde
          Row(
            children: [
              Expanded(child: Text(pharmacy['name'] ?? 'Pharmacie', style: AppTextStyles.heading2)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingSmall, vertical: AppSizes.spacingXSmall),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Text(
                  'De garde',
                  style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.spacingMedium),

          // Informations détaillées
          _buildDetailRow(Icons.location_on, pharmacy['address'] ?? 'Adresse non disponible'),
          _buildDetailRow(Icons.location_city, pharmacy['commune'] ?? 'Commune non disponible'),
          _buildDetailRow(Icons.near_me, '${(pharmacy['distance'] ?? 0).toStringAsFixed(1)} km'),
          if (pharmacy['phone'] != null && pharmacy['phone'].toString().isNotEmpty)
            _buildDetailRow(Icons.phone, pharmacy['phone']),

          SizedBox(height: AppSizes.spacingLarge),

          // Boutons d'action
          Row(
            children: [
              if (pharmacy['phone'] != null && pharmacy['phone'].toString().isNotEmpty)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.phone),
                    label: Text('Appeler'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white),
                  ),
                ),
              if (pharmacy['phone'] != null && pharmacy['phone'].toString().isNotEmpty) SizedBox(width: AppSizes.spacingMedium),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.directions),
                  label: Text('Itinéraire'),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: BorderSide(color: AppColors.primary)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.spacingSmall),
      child: Row(
        children: [
          Icon(icon, size: AppSizes.iconSmall, color: AppColors.textLight),
          SizedBox(width: AppSizes.spacingMedium),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.text))),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
