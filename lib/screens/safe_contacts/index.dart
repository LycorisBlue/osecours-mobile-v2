// lib/screens/safe_contacts/index.dart
import 'package:flutter/material.dart';
import '../../core/constants/sizes.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/themes.dart';
import '../../data/models/safe_contact_models.dart';
import '../../services/navigation_service.dart';
import 'controller.dart';
import 'widgets/safe_contact_card.dart';
import 'widgets/location_sharing_widget.dart';
import 'add_contacts_screen.dart';

/// Page principale des contacts de sécurité
class SafeContactsScreen extends StatefulWidget {
  const SafeContactsScreen({super.key});

  @override
  State<SafeContactsScreen> createState() => _SafeContactsScreenState();
}

class _SafeContactsScreenState extends State<SafeContactsScreen> {
  late SafeContactsController _controller;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _controller = SafeContactsController();
    _controller.initialize(setState);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Rafraîchit les données
  Future<void> _handleRefresh() async {
    await _controller.refreshData(setState);
  }

  /// Navigue vers l'ajout de contacts
  void _navigateToAddContacts() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddContactsScreen(remainingSlots: _controller.remainingSlots)),
    );

    // Si des contacts ont été ajoutés, les intégrer
    if (result != null && result is List<SafeContact>) {
      _controller.onContactsAdded(result, setState);
    }
  }

  /// Affiche les messages d'erreur ou de succès
  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: AppEdgeInsets.medium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSmall)),
        action: SnackBarAction(
          label: 'OK',
          textColor: AppColors.white,
          onPressed: () {
            if (isError) {
              _controller.clearError(setState);
            } else {
              _controller.clearSuccessMessage(setState);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Gestion des messages
    if (_controller.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showMessage(_controller.error!, isError: true);
      });
    }

    if (_controller.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showMessage(_controller.successMessage!);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.text, size: AppSizes.iconMedium),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Contacts de sécurité', style: AppTextStyles.heading3),
        centerTitle: true,
        actions: [
          if (_controller.canAddMore)
            IconButton(
              icon: Icon(Icons.add, color: AppColors.primary, size: AppSizes.iconMedium),
              onPressed: _navigateToAddContacts,
              tooltip: 'Ajouter un contact',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading && _controller.contacts.isEmpty) {
      return _buildLoadingState();
    }

    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _handleRefresh,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppSizes.spacingMedium),

            // Section statistiques et état
            _buildHeaderSection(),

            SizedBox(height: AppSizes.spacingLarge),

            // Section partage de localisation
            LocationSharingWidget(
              config: _controller.locationConfig,
              onToggle: (enabled) => _controller.updateLocationSharing(enabled, setState),
              onModeSelect: () => _controller.showLocationSharingModeSelector(context, setState),
              isUpdating: _controller.isUpdatingLocationSharing,
            ),

            SizedBox(height: AppSizes.spacingLarge),

            // Section liste des contacts
            _buildContactsSection(),

            SizedBox(height: AppSizes.spacingXLarge),
          ],
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
          Text('Chargement des contacts...', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight)),
        ],
      ),
    );
  }

  /// Section d'en-tête avec statistiques
  Widget _buildHeaderSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.screenPaddingHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre de section et statut
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mes contacts (${_controller.contacts.length}/5)',
                style: AppTextStyles.heading3.copyWith(fontSize: AppSizes.h3 * 0.9),
              ),
              if (_controller.hasContacts)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingMedium, vertical: AppSizes.spacingXSmall),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
                  ),
                  child: Text(
                    '${_controller.remainingSlots} ${_controller.remainingSlots == 1 ? 'place' : 'places'} restante${_controller.remainingSlots == 1 ? '' : 's'}',
                    style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),

          SizedBox(height: AppSizes.spacingMedium),

          // Statistiques par catégorie (si on a des contacts)
          if (_controller.hasContacts) _buildCategoryStats(),

          // Description
          SizedBox(height: AppSizes.spacingMedium),
          Container(
            padding: EdgeInsets.all(AppSizes.spacingMedium),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusCard),
              border: Border.all(color: Colors.blue.withOpacity(0.2), width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: AppSizes.iconMedium),
                SizedBox(width: AppSizes.spacingMedium),
                Expanded(
                  child: Text(
                    'Ces contacts recevront un message vous informant que vous êtes en sécurité. Maximum 5 contacts.',
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.blue.shade700, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Statistiques par catégorie
  Widget _buildCategoryStats() {
    final stats = _controller.contactsByCategory;
    final activeCategories = stats.entries.where((entry) => entry.value > 0).toList();

    if (activeCategories.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: AppSizes.spacingSmall,
      runSpacing: AppSizes.spacingSmall,
      children:
          activeCategories.map((entry) {
            final category = entry.key;
            final count = entry.value;

            return Container(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingMedium, vertical: AppSizes.spacingXSmall),
              decoration: BoxDecoration(
                color: category.lightColor,
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                border: Border.all(color: category.borderColor, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(category.icon, size: AppSizes.iconSmall, color: category.color),
                  SizedBox(width: AppSizes.spacingXSmall),
                  Text(
                    '${category.label} ($count)',
                    style: AppTextStyles.caption.copyWith(color: category.color, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  /// Section liste des contacts
  Widget _buildContactsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.screenPaddingHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_controller.isEmpty)
            _buildEmptyState()
          else ...[
            // Liste des contacts existants
            ..._controller.contacts.map(
              (contact) => SafeContactCard(
                contact: contact,
                onDelete: () => _controller.showDeleteConfirmation(context, contact, setState),
                onCategoryTap: () => _controller.showCategorySelector(context, contact, setState),
                onTestMessage: () => _controller.sendTestMessage(contact, setState),
                isDeleting: _controller.isDeletingContact,
                isTesting: _controller.isTestingMessage,
              ),
            ),

            // Carte d'ajout si on peut encore ajouter
            if (_controller.canAddMore)
              EmptySafeContactCard(onTap: _navigateToAddContacts, remainingSlots: _controller.remainingSlots),
          ],
        ],
      ),
    );
  }

  /// État liste vide
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.spacingXLarge),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        border: Border.all(color: AppColors.textLight.withOpacity(0.2), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.contacts_outlined, size: AppSizes.iconLarge, color: AppColors.primary),
          ),

          SizedBox(height: AppSizes.spacingLarge),

          Text('Aucun contact de sécurité', style: AppTextStyles.heading3.copyWith(color: AppColors.textLight)),

          SizedBox(height: AppSizes.spacingSmall),

          Text(
            'Ajoutez jusqu\'à 5 contacts qui seront prévenus en cas d\'urgence.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: AppSizes.spacingLarge),

          ElevatedButton.icon(
            onPressed: _navigateToAddContacts,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingLarge, vertical: AppSizes.spacingMedium),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusButton)),
            ),
            icon: Icon(Icons.add, size: AppSizes.iconMedium),
            label: Text('Ajouter des contacts', style: AppTextStyles.buttonText),
          ),
        ],
      ),
    );
  }
}
