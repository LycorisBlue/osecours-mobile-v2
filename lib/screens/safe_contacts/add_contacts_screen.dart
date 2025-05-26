// lib/screens/safe_contacts/add_contacts_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../../core/constants/sizes.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/themes.dart';
import '../../data/models/safe_contact_models.dart';
import '../../services/safe_contacts_service.dart';

/// Page de sélection et ajout de contacts de sécurité
class AddContactsScreen extends StatefulWidget {
  final int remainingSlots;

  const AddContactsScreen({super.key, required this.remainingSlots});

  @override
  State<AddContactsScreen> createState() => _AddContactsScreenState();
}

class _AddContactsScreenState extends State<AddContactsScreen> {
  final SafeContactsService _service = SafeContactsService();
  final TextEditingController _searchController = TextEditingController();

  // État de la page
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;
  List<Contact> _allContacts = [];
  List<Contact> _filteredContacts = [];
  Map<Contact, ContactCategory> _selectedContacts = {};

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _searchController.addListener(_filterContacts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Charge les contacts du téléphone
  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (await FlutterContacts.requestPermission()) {
        final contacts = await FlutterContacts.getContacts(withProperties: true);

        // Filtrer et trier les contacts
        final validContacts =
            contacts.where((contact) {
              final name = contact.displayName.trim();
              final hasValidPhone = contact.phones.isNotEmpty && contact.phones.any((phone) => phone.number.isNotEmpty);
              return name.isNotEmpty && hasValidPhone;
            }).toList();

        validContacts.sort((a, b) => a.displayName.compareTo(b.displayName));

        setState(() {
          _allContacts = validContacts;
          _filteredContacts = validContacts;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Permission d\'accès aux contacts refusée';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur lors de la récupération des contacts: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Filtre les contacts selon la recherche
  void _filterContacts() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      if (query.isEmpty) {
        _filteredContacts = _allContacts;
      } else {
        _filteredContacts =
            _allContacts.where((contact) {
              return contact.displayName.toLowerCase().contains(query) ||
                  contact.phones.any((phone) => phone.number.contains(query));
            }).toList();
      }
    });
  }

  /// Sélectionne ou désélectionne un contact
  void _toggleContactSelection(Contact contact) {
    setState(() {
      if (_selectedContacts.containsKey(contact)) {
        _selectedContacts.remove(contact);
      } else if (_selectedContacts.length < widget.remainingSlots) {
        _selectedContacts[contact] = ContactCategory.autre; // Catégorie par défaut
      } else {
        _showErrorSnackBar(
          'Vous ne pouvez sélectionner que ${widget.remainingSlots} contact${widget.remainingSlots > 1 ? 's' : ''} supplémentaire${widget.remainingSlots > 1 ? 's' : ''}',
        );
      }
    });
  }

  /// Met à jour la catégorie d'un contact sélectionné
  void _updateContactCategory(Contact contact, ContactCategory category) {
    setState(() {
      _selectedContacts[contact] = category;
    });
  }

  /// Affiche le sélecteur de catégorie
  void _showCategorySelector(Contact contact) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(AppSizes.spacingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Catégorie pour ${contact.displayName}', style: AppTextStyles.heading3),
              SizedBox(height: AppSizes.spacingLarge),

              ...ContactCategory.values.map((category) {
                final isSelected = _selectedContacts[contact] == category;

                return Padding(
                  padding: EdgeInsets.only(bottom: AppSizes.spacingMedium),
                  child: InkWell(
                    onTap: () {
                      _updateContactCategory(contact, category);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(AppSizes.radiusCard),
                    child: Container(
                      padding: EdgeInsets.all(AppSizes.spacingMedium),
                      decoration: BoxDecoration(
                        color: isSelected ? category.lightColor : AppColors.background,
                        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
                        border: Border.all(
                          color: isSelected ? category.borderColor : AppColors.textLight.withOpacity(0.2),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(AppSizes.spacingSmall),
                            decoration: BoxDecoration(
                              color: category.lightColor,
                              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                              border: Border.all(color: category.borderColor),
                            ),
                            child: Icon(category.icon, color: category.color, size: AppSizes.iconMedium),
                          ),
                          SizedBox(width: AppSizes.spacingMedium),
                          Expanded(
                            child: Text(
                              category.label,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (isSelected) Icon(Icons.check, color: category.color, size: AppSizes.iconMedium),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  /// Soumet les contacts sélectionnés
  Future<void> _submitContacts() async {
    if (_selectedContacts.isEmpty) {
      _showErrorSnackBar('Veuillez sélectionner au moins un contact');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Préparer les données de contact
      final contactsData =
          _selectedContacts.entries.map((entry) {
            final contact = entry.key;
            final phone = contact.phones.first.number;

            return SafeContactData(number: phone, description: contact.displayName);
          }).toList();

      // Ajouter les contacts via le service
      final result = await _service.addSafeContacts(contactsData);

      if (result['success']) {
        // Créer les SafeContact avec les catégories locales
        final addedContacts =
            (result['data'] as List<SafeContact>).map((contact) {
              final matchingEntry = _selectedContacts.entries.firstWhere(
                (entry) => entry.key.displayName == contact.description,
                orElse: () => MapEntry(_selectedContacts.keys.first, ContactCategory.autre),
              );

              return contact.copyWith(category: matchingEntry.value);
            }).toList();

        // Retourner les contacts ajoutés
        if (mounted) {
          Navigator.pop(context, addedContacts);
        }
      } else {
        setState(() => _isSubmitting = false);
        _showErrorSnackBar(result['message']);
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      _showErrorSnackBar('Erreur lors de l\'ajout: ${e.toString()}');
    }
  }

  /// Affiche un message d'erreur
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: AppEdgeInsets.medium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSmall)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.text, size: AppSizes.iconMedium),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Ajouter des contacts', style: AppTextStyles.heading3),
        centerTitle: true,
        actions: [
          if (_selectedContacts.isNotEmpty)
            TextButton(
              onPressed: _isSubmitting ? null : _submitContacts,
              child:
                  _isSubmitting
                      ? SizedBox(
                        width: AppSizes.iconMedium,
                        height: AppSizes.iconMedium,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                      )
                      : Text(
                        'Ajouter (${_selectedContacts.length})',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    return Column(
      children: [
        // Barre de recherche
        _buildSearchBar(),

        // Section sélectionnés (si applicable)
        if (_selectedContacts.isNotEmpty) _buildSelectedSection(),

        // Liste des contacts
        Expanded(child: _buildContactsList()),
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
          Text('Chargement des contacts...', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight)),
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
            Text(_error!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight), textAlign: TextAlign.center),
            SizedBox(height: AppSizes.spacingLarge),
            ElevatedButton(
              onPressed: _loadContacts,
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

  /// Barre de recherche
  Widget _buildSearchBar() {
    return Container(
      padding: AppEdgeInsets.medium,
      color: AppColors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher un contact...',
          hintStyle: AppTextStyles.hint,
          prefixIcon: Icon(Icons.search, color: AppColors.textLight),
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusCard), borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.spacingMedium, vertical: AppSizes.spacingMedium),
        ),
      ),
    );
  }

  /// Section des contacts sélectionnés
  Widget _buildSelectedSection() {
    return Container(
      padding: AppEdgeInsets.medium,
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contacts sélectionnés (${_selectedContacts.length}/${widget.remainingSlots})',
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: AppSizes.spacingMedium),

          Wrap(
            spacing: AppSizes.spacingSmall,
            runSpacing: AppSizes.spacingSmall,
            children:
                _selectedContacts.entries.map((entry) {
                  final contact = entry.key;
                  final category = entry.value;

                  return GestureDetector(
                    onTap: () => _showCategorySelector(contact),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingMedium, vertical: AppSizes.spacingSmall),
                      decoration: BoxDecoration(
                        color: category.lightColor,
                        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
                        border: Border.all(color: category.borderColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(category.icon, size: AppSizes.iconSmall, color: category.color),
                          SizedBox(width: AppSizes.spacingXSmall),
                          Text(
                            contact.displayName,
                            style: AppTextStyles.caption.copyWith(color: category.color, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(width: AppSizes.spacingXSmall),
                          GestureDetector(
                            onTap: () => _toggleContactSelection(contact),
                            child: Icon(Icons.close, size: AppSizes.iconSmall, color: category.color),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  /// Liste des contacts
  Widget _buildContactsList() {
    if (_filteredContacts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: AppSizes.iconLarge, color: AppColors.textLight),
            SizedBox(height: AppSizes.spacingMedium),
            Text('Aucun contact trouvé', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: AppEdgeInsets.medium,
      itemCount: _filteredContacts.length,
      itemBuilder: (context, index) {
        final contact = _filteredContacts[index];
        final isSelected = _selectedContacts.containsKey(contact);
        final phone = contact.phones.isNotEmpty ? contact.phones.first.number : '';

        return Container(
          margin: EdgeInsets.only(bottom: AppSizes.spacingSmall),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusCard),
            border: Border.all(
              color: isSelected ? AppColors.primary.withOpacity(0.3) : AppColors.textLight.withOpacity(0.1),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(AppSizes.spacingMedium),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.background,
                borderRadius: BorderRadius.circular(AppSizes.radiusCard),
              ),
              child: Center(
                child: Text(
                  contact.displayName.isNotEmpty ? contact.displayName[0].toUpperCase() : '?',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.primary : AppColors.textLight,
                  ),
                ),
              ),
            ),
            title: Text(
              contact.displayName,
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal),
            ),
            subtitle: phone.isNotEmpty ? Text(phone, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight)) : null,
            trailing:
                isSelected
                    ? Icon(Icons.check_circle, color: AppColors.primary, size: AppSizes.iconMedium)
                    : Icon(Icons.circle_outlined, color: AppColors.textLight, size: AppSizes.iconMedium),
            onTap: () => _toggleContactSelection(contact),
          ),
        );
      },
    );
  }
}
