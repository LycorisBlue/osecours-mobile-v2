// lib/screens/home/index.dart
import 'package:flutter/material.dart';
import 'package:osecours/core/constants/themes.dart';
import 'package:osecours/screens/home/widgets/app_drawer.dart';
import '../../core/constants/sizes.dart';
import '../../core/constants/colors.dart';
import '../../services/navigation_service.dart';
import 'controllers.dart';
import 'widgets/header_widget.dart';
import 'widgets/alert_grid_widget.dart';
import 'widgets/latest_alert_widget.dart';
import 'widgets/emergency_bottom_bar_widget.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController _homeController = HomeController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _initializeHome();
  }

  /// Initialise les données de la page d'accueil
  Future<void> _initializeHome() async {
    await _homeController.initialize(setState);
  }

  /// Rafraîchit toutes les données
  Future<void> _refreshData() async {
    await _homeController.refresh(setState);
  }

  /// Met à jour la localisation
  Future<void> _updateLocation() async {
    await _homeController.updateAddress(setState);
  }

  /// Navigue vers les notifications
  void _navigateToNotifications() {
    // TODO: Implémenter la navigation vers les notifications
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Navigation vers notifications - À implémenter')));
  }

  /// Navigue vers toutes les alertes
  void _navigateToAllAlerts() {
    // TODO: Implémenter la navigation vers toutes les alertes
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Navigation vers toutes les alertes - À implémenter')));
  }

  /// Navigue vers les détails d'une alerte
  void _navigateToAlertDetails(String alertId) {
    // TODO: Implémenter la navigation vers les détails d'alerte
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Navigation vers alerte $alertId - À implémenter')));
  }

  /// Navigue vers les numéros d'urgence
  void _navigateToEmergency() {
    Routes.navigateTo(Routes.emergency);
  }

  /// Ouvre le menu drawer
  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.white,
      drawer: AppDrawer(),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refreshData,
        child: SafeArea(
          child:
              _homeController.isLoading && _homeController.currentAddress == 'Chargement...'
                  ? _buildLoadingState()
                  : _buildContent(),
        ),
      ),
      bottomNavigationBar: EmergencyBottomBarWidget(onEmergencyTap: _navigateToEmergency),
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
          Text('Chargement...', style: TextStyle(fontSize: AppSizes.bodyMedium, color: AppColors.textLight)),
        ],
      ),
    );
  }

  /// Contenu principal de la page
  Widget _buildContent() {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec menu, logo, localisation et notifications
          HeaderWidget(
            currentAddress: _homeController.currentAddress,
            onRefreshLocation: _updateLocation,
            onMenuTap: _openDrawer,
            onNotificationTap: _navigateToNotifications,
          ),

          SizedBox(height: AppSizes.spacingLarge),

          // Grille des types d'alertes
          AlertGridWidget(),

          SizedBox(height: AppSizes.spacingXLarge),

          // Section des alertes récentes
          LatestAlertWidget(
            latestAlert: _homeController.latestAlert,
            onViewAllAlerts: _navigateToAllAlerts,
            onAlertTap: _navigateToAlertDetails,
          ),

          SizedBox(height: AppSizes.spacingXLarge),

          // Card de conseil (optionnel)
          _buildAdviceCard(),

          SizedBox(height: AppSizes.spacingXLarge),
        ],
      ),
    );
  }

  /// Card de conseil de la semaine
  Widget _buildAdviceCard() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.screenPaddingHorizontal),
      child: Card(
        elevation: AppSizes.elevationSmall,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.spacingMedium),
          child: Row(
            children: [
              // Image comme dans l'ancienne app
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  image: DecorationImage(image: AssetImage('assets/pictures/conseil.png'), fit: BoxFit.cover),
                ),
              ),
              SizedBox(width: AppSizes.spacingMedium),

              // Contenu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Conseil de la semaine",
                      style: AppTextStyles.heading3,
                    ),
                    SizedBox(height: AppSizes.spacingSmall),
                    Text(
                      "Ajouter des lieux importants dans vos paramètres pour mieux réagir en cas d'urgence.",
                      style: TextStyle(fontSize: AppSizes.bodyMedium, color: AppColors.text),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
