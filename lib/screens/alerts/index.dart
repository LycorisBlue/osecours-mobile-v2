// lib/screens/alerts/index.dart
import 'package:flutter/material.dart';
import 'package:osecours/core/constants/colors.dart';
import 'package:osecours/core/constants/sizes.dart';
import 'package:osecours/core/constants/themes.dart';
import 'controller.dart';
import 'widgets/alert_card.dart';
import 'widgets/alert_detail_bottom_sheet.dart';

/// Écran principal pour afficher toutes les alertes de l'utilisateur
class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  late AlertsController _controller;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _controller = AlertsController();
    _controller.initialize(setState);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Rafraîchit les données
  Future<void> _handleRefresh() async {
    await _controller.refreshAlerts(setState);
  }

  /// Affiche les détails d'une alerte dans un bottom sheet
  void _showAlertDetails(Map<String, dynamic> alert) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AlertDetailBottomSheet(alert: alert),
    );
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
        title: Text('Mes alertes', style: AppTextStyles.heading3),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return _buildLoadingState();
    }

    if (_controller.error != null) {
      return _buildErrorState();
    }

    if (_controller.isEmpty) {
      return _buildEmptyState();
    }

    return _buildAlertsList();
  }

  /// État de chargement
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: AppSizes.spacingMedium),
          Text('Chargement des alertes...', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight)),
        ],
      ),
    );
  }

  /// État d'erreur
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.spacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: AppSizes.iconLarge * 2, color: AppColors.error),
            SizedBox(height: AppSizes.spacingMedium),
            Text('Erreur', style: AppTextStyles.heading3.copyWith(color: AppColors.error)),
            SizedBox(height: AppSizes.spacingSmall),
            Text(
              _controller.error ?? 'Une erreur est survenue',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.spacingLarge),
            ElevatedButton(
              onPressed: () => _controller.loadAlerts(setState),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusButton)),
              ),
              child: Text('Réessayer', style: AppTextStyles.buttonText),
            ),
          ],
        ),
      ),
    );
  }

  /// État liste vide
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.spacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notification_add_outlined, size: AppSizes.iconLarge * 2, color: AppColors.textLight),
            SizedBox(height: AppSizes.spacingMedium),
            Text('Aucune alerte', style: AppTextStyles.heading3.copyWith(color: AppColors.textLight)),
            SizedBox(height: AppSizes.spacingSmall),
            Text(
              'Vous n\'avez envoyé aucune alerte pour le moment.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.spacingLarge),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusButton)),
              ),
              child: Text('Retour à l\'accueil', style: AppTextStyles.buttonText),
            ),
          ],
        ),
      ),
    );
  }

  /// Liste des alertes avec pull-to-refresh
  Widget _buildAlertsList() {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _handleRefresh,
      color: AppColors.primary,
      child: Column(
        children: [
          // Statistiques en haut
          _buildStatsHeader(),

          // Liste des alertes
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.screenPaddingHorizontal, vertical: AppSizes.spacingMedium),
              itemCount: _controller.alerts.length,
              itemBuilder: (context, index) {
                final alert = _controller.alerts[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: AppSizes.spacingMedium),
                  child: AlertCard(alert: alert, onTap: () => _showAlertDetails(alert)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// En-tête avec statistiques
  Widget _buildStatsHeader() {
    final stats = _controller.getAlertsStats();

    return Container(
      margin: EdgeInsets.all(AppSizes.screenPaddingHorizontal),
      padding: EdgeInsets.all(AppSizes.spacingMedium),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Résumé de vos alertes', style: AppTextStyles.label),
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingSmall, vertical: AppSizes.spacingXSmall),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppSizes.radiusSmall)),
                child: Text(
                  '${stats['total']} total',
                  style: AppTextStyles.caption.copyWith(color: AppColors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.spacingSmall),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('En attente', stats['en_attente'] ?? 0, Colors.orange),
              _buildStatItem('Acceptées', stats['acceptee'] ?? 0, Colors.blue),
              _buildStatItem('En cours', stats['en_cours'] ?? 0, Colors.green),
              _buildStatItem('Résolues', stats['resolue'] ?? 0, Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  /// Widget pour un élément de statistique
  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          width: AppSizes.iconLarge,
          height: AppSizes.iconLarge,
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Center(
            child: Text(count.toString(), style: AppTextStyles.label.copyWith(color: color, fontWeight: FontWeight.bold)),
          ),
        ),
        SizedBox(height: AppSizes.spacingXSmall),
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textLight), textAlign: TextAlign.center),
      ],
    );
  }
}
