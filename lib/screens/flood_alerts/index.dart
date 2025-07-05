// lib/screens/flood_alerts/index.dart
import 'package:flutter/material.dart';
import 'package:osecours/services/navigation_service.dart';
import '../../core/constants/sizes.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/themes.dart';
import '../../data/models/flood_alert_models.dart';
import 'controller.dart';
import 'widgets/flood_alert_card.dart';
import 'flood_map_screen.dart';
import 'widgets/flood_alert_detail_bottom_sheet.dart';

/// Écran principal pour afficher les alertes d'inondation
class FloodAlertsScreen extends StatefulWidget {
  const FloodAlertsScreen({super.key});

  @override
  State<FloodAlertsScreen> createState() => _FloodAlertsScreenState();
}

class _FloodAlertsScreenState extends State<FloodAlertsScreen> {
  late FloodAlertsController _controller;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _controller = FloodAlertsController();
    _controller.initialize(setState);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Rafraîchit les alertes
  Future<void> _handleRefresh() async {
    await _controller.refreshAlerts(setState);
  }

  /// Affiche les détails d'une alerte
  void _showAlertDetails(FloodAlert alert) {
    if (_controller.userPosition != null) {
      FloodAlertDetailBottomSheet.show(context, alert: alert, userPosition: _controller.userPosition!);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Position utilisateur non disponible'), backgroundColor: Colors.red));
    }
  }

  /// Navigue vers la carte
  void _navigateToMap() {
    if (_controller.hasAlerts && _controller.userPosition != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => FloodMapScreen(
                alerts: _controller.floodAlerts,
                userPosition: _controller.userPosition!,
                globalMessage: _controller.globalMessage,
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          title: Text('Alertes d\'inondation', style: AppTextStyles.heading3),
          centerTitle: true,
          actions: [
            if (!_controller.isLoading && _controller.error == null && _controller.hasAlerts && _controller.userPosition != null)
              IconButton(
                icon: Icon(Icons.map, color: AppColors.text, size: AppSizes.iconMedium),
                onPressed: _navigateToMap,
                tooltip: 'Voir sur la carte',
              ),
          ],
        ),
        body: RefreshIndicator(key: _refreshIndicatorKey, onRefresh: _handleRefresh, color: AppColors.primary, child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return _buildLoadingState();
    }

    if (_controller.error != null) {
      return _buildErrorState();
    }

    return Column(
      children: [
        // Message global si présent
        if (_controller.globalMessage.isNotEmpty) _buildGlobalMessage(),

        // Liste des alertes
        Expanded(child: _controller.isEmpty ? _buildEmptyState() : _buildAlertsList()),
      ],
    );
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
        padding: AppEdgeInsets.large,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: AppSizes.iconLarge * 2, color: AppColors.error),
            SizedBox(height: AppSizes.spacingMedium),
            Text('Erreur', style: AppTextStyles.heading3.copyWith(color: AppColors.error)),
            SizedBox(height: AppSizes.spacingSmall),
            Text(
              _controller.error!,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.spacingLarge),
            ElevatedButton(
              onPressed: () => _controller.fetchFloodAlerts(setState),
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

  /// État vide
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: AppEdgeInsets.large,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.water_drop_outlined, size: AppSizes.iconLarge * 2, color: AppColors.textLight),
            SizedBox(height: AppSizes.spacingMedium),
            Text('Aucune alerte', style: AppTextStyles.heading3.copyWith(color: AppColors.textLight)),
            SizedBox(height: AppSizes.spacingSmall),
            Text(
              'Aucune alerte d\'inondation à proximité',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Message global
  Widget _buildGlobalMessage() {
    return Container(
      padding: EdgeInsets.all(AppSizes.spacingMedium),
      margin: EdgeInsets.all(AppSizes.spacingMedium),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: Colors.blue),
      ),
      child: Text(_controller.globalMessage, style: AppTextStyles.bodyMedium.copyWith(color: Colors.blue)),
    );
  }

  /// Liste des alertes
  Widget _buildAlertsList() {
    return ListView.builder(
      padding: EdgeInsets.all(AppSizes.spacingLarge),
      itemCount: _controller.floodAlerts.length,
      itemBuilder: (context, index) {
        final alert = _controller.floodAlerts[index];
        return FloodAlertCard(alert: alert, onTap: () => _showAlertDetails(alert));
      },
    );
  }
}
