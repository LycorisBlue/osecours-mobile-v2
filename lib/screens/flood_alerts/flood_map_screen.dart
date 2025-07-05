// lib/screens/flood_alerts/flood_map_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/themes.dart';
import '../../data/models/flood_alert_models.dart';
import 'dart:math' as math;




/// Écran de carte pour visualiser les alertes d'inondation
class FloodMapScreen extends StatefulWidget {
  final List<FloodAlert> alerts;
  final Position userPosition;
  final String globalMessage;

  const FloodMapScreen({
    super.key,
    required this.alerts,
    required this.userPosition,
    required this.globalMessage,
  });

  @override
  State<FloodMapScreen> createState() => _FloodMapScreenState();
}

class _FloodMapScreenState extends State<FloodMapScreen> {
  late MapController _mapController;
  FloodAlert? _selectedAlert;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  /// Centre la carte sur la position de l'utilisateur
  void _centerOnUser() {
    _mapController.move(
      LatLng(widget.userPosition.latitude, widget.userPosition.longitude),
      13.0,
    );
  }

  /// Centre la carte pour afficher toutes les alertes
  void _centerOnAll() {
    if (widget.alerts.isEmpty) {
      _centerOnUser();
      return;
    }

    // Calculer les limites de la carte
    double minLat = widget.userPosition.latitude;
    double maxLat = widget.userPosition.latitude;
    double minLng = widget.userPosition.longitude;
    double maxLng = widget.userPosition.longitude;

    for (var alert in widget.alerts) {
      if (alert.location.lat < minLat) minLat = alert.location.lat;
      if (alert.location.lat > maxLat) maxLat = alert.location.lat;
      if (alert.location.lng < minLng) minLng = alert.location.lng;
      if (alert.location.lng > maxLng) maxLng = alert.location.lng;
    }

    // Ajouter une marge
    final latDiff = (maxLat - minLat) * 0.1;
    final lngDiff = (maxLng - minLng) * 0.1;

    minLat -= latDiff;
    maxLat += latDiff;
    minLng -= lngDiff;
    maxLng += lngDiff;

    // Calculer le centre
    final centerLat = (minLat + maxLat) / 2;
    final centerLng = (minLng + maxLng) / 2;

    // Calculer le niveau de zoom
    final latZoom = 360 / (maxLat - minLat);
    final lngZoom = 360 / (maxLng - minLng);
    final zoom = (_log(_min(latZoom, lngZoom)) / _log(2)) - 1;

    // Déplacer la carte
    _mapController.move(LatLng(centerLat, centerLng), zoom.toDouble());
  }

  // Fonction utilitaire pour le calcul du zoom
  double _min(double a, double b) => a < b ? a : b;
  double _log(double x) => (x.log()) / (2.0.log());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carte des inondations', style: AppTextStyles.heading3),
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.text),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _centerOnUser,
            tooltip: 'Centrer sur ma position',
          ),
          IconButton(
            icon: const Icon(Icons.fit_screen),
            onPressed: _centerOnAll,
            tooltip: 'Afficher toutes les alertes',
          ),
        ],
      ),
      body: Column(
        children: [
          // Message global / Légende
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.blue.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.globalMessage,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  children: [
                    _buildLegendItem(AppColors.primary, 'Votre position'),
                    _buildLegendItem(Colors.blue, 'Acceptée'),
                    _buildLegendItem(Colors.orange, 'En cours'),
                    _buildLegendItem(Colors.green, 'Résolue'),
                  ],
                ),
              ],
            ),
          ),

          // Carte
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(
                  widget.userPosition.latitude,
                  widget.userPosition.longitude,
                ),
                initialZoom: 12,
                onTap: (_, point) {
                  // Désélectionner l'alerte actuelle au tap sur la carte
                  setState(() {
                    _selectedAlert = null;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: [
                    // Marqueur pour l'utilisateur
                    Marker(
                      width: 40,
                      height: 40,
                      point: LatLng(
                        widget.userPosition.latitude,
                        widget.userPosition.longitude,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_pin_circle,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    // Marqueurs pour toutes les alertes
                    for (var alert in widget.alerts)
                      Marker(
                        width: 40,
                        height: 40,
                        point: LatLng(alert.location.lat, alert.location.lng),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedAlert = alert;
                            });
                          },
                          child: Icon(
                            Icons.water_drop,
                            color: alert.getStatusColor(),
                            size: 30,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Info-bulle pour l'alerte sélectionnée
          if (_selectedAlert != null) _buildSelectedAlertInfo(),
        ],
      ),
    );
  }

  /// Widget pour les éléments de légende
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }

  /// Info-bulle pour l'alerte sélectionnée
  Widget _buildSelectedAlertInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.water_drop,
                color: _selectedAlert!.getStatusColor(),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _selectedAlert!.address,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _selectedAlert!.getStatusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _selectedAlert!.getStatusText(),
                  style: TextStyle(
                    color: _selectedAlert!.getStatusColor(),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _selectedAlert!.description,
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 8),
          Text(
            "À ${_selectedAlert!.distance.toStringAsFixed(1)} km de votre position",
            style: AppTextStyles.bodySmall.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}



/// Import pour les fonctions mathématiques
extension MathExtensions on double {
  double log() => math.log(this);
}
