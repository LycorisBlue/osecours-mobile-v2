// lib/screens/centres_hospitaliers/index.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/sizes.dart';
import '../../core/constants/themes.dart';
import 'controller.dart';
import 'widgets/etablissement_item.dart';

class CentresHospitaliersScreen extends StatefulWidget {
  const CentresHospitaliersScreen({super.key});

  @override
  State<CentresHospitaliersScreen> createState() => _CentresHospitaliersScreenState();
}

class _CentresHospitaliersScreenState extends State<CentresHospitaliersScreen> {
  late CentresHospitaliersController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CentresHospitaliersController();
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
      title: Text('Centres hospitaliers', style: AppTextStyles.heading2.copyWith(color: AppColors.text)),
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

    if (_controller.etablissements.isEmpty) {
      return _buildEmptyWidget();
    }

    return RefreshIndicator(
      onRefresh: () => _controller.refresh(setState),
      color: AppColors.primary,
      child: Column(
        children: [
          // En-tête avec statistiques
          _buildStatsHeader(),

          // Liste des établissements
          Expanded(child: _buildEtablissementsList()),
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
            _controller.searchStatus.isNotEmpty ? _controller.searchStatus : 'Recherche des centres hospitaliers...',
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
            Icon(Icons.local_hospital_outlined, size: 64.r, color: AppColors.textLight),
            SizedBox(height: AppSizes.spacingLarge),
            Text('Aucun centre trouvé', style: AppTextStyles.heading3, textAlign: TextAlign.center),
            SizedBox(height: AppSizes.spacingMedium),
            Text(
              'Aucun établissement de santé n\'a été trouvé dans un rayon de 10km.',
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

  Widget _buildStatsHeader() {
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
                      _controller.searchStatus.isNotEmpty ? _controller.searchStatus : 'Centres hospitaliers trouvés',
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${_controller.totalEtablissements} établissement(s) dans ${_controller.totalCommunes} commune(s)',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textLight),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Statistiques par catégorie
          SizedBox(height: AppSizes.spacingMedium),
          Container(
            padding: EdgeInsets.all(AppSizes.spacingSmall),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(AppSizes.radiusSmall)),
            child: Row(
              children: [
                _buildStatCard(
                  icon: Icons.local_hospital,
                  count: _controller.totalHopitaux,
                  label: 'Hôpitaux',
                  color: AppColors.primary,
                ),
                SizedBox(width: AppSizes.spacingMedium),
                _buildStatCard(
                  icon: Icons.medical_services,
                  count: _controller.totalCliniques,
                  label: 'Cliniques',
                  color: Colors.blue,
                ),
                SizedBox(width: AppSizes.spacingMedium),
                _buildStatCard(icon: Icons.radar, count: _controller.currentRadius, label: 'Rayon (km)', color: Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({required IconData icon, required int count, required String label, required Color color}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppSizes.radiusSmall)),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20.r),
            SizedBox(height: 4.h),
            Text(count.toString(), style: AppTextStyles.heading3.copyWith(fontSize: 16.sp, color: color)),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight, fontSize: 11.sp),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEtablissementsList() {
    return ListView.builder(
      padding: EdgeInsets.all(AppSizes.spacingMedium),
      itemCount: _controller.etablissements.length,
      itemBuilder: (context, index) {
        final etablissement = _controller.etablissements[index];
        return EtablissementItem(etablissement: etablissement, onTap: () => _showEtablissementDetails(etablissement));
      },
    );
  }

  void _showEtablissementDetails(Map<String, dynamic> etablissement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildEtablissementDetailsModal(etablissement),
    );
  }

  Widget _buildEtablissementDetailsModal(Map<String, dynamic> etablissement) {
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

          // Nom et badge de catégorie
          Row(
            children: [
              Expanded(
                child: Text(
                  etablissement['nom']?.isNotEmpty == true ? etablissement['nom'] : 'Établissement de santé',
                  style: AppTextStyles.heading2,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingSmall, vertical: AppSizes.spacingXSmall),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Text(
                  etablissement['categorie'] ?? 'Établissement',
                  style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.spacingMedium),

          // Informations détaillées
          if (etablissement['quartier']?.isNotEmpty == true) _buildDetailRow(Icons.location_on, etablissement['quartier']),
          _buildDetailRow(Icons.location_city, etablissement['commune'] ?? 'Commune non disponible'),
          _buildDetailRow(Icons.near_me, '${(etablissement['distance'] ?? 0).toStringAsFixed(1)} km'),

          SizedBox(height: AppSizes.spacingLarge),

          // Bouton d'action
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.directions),
              label: Text('Obtenir l\'itinéraire'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white),
            ),
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
