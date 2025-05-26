// lib/screens/safe_contacts/index.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:osecours/core/constants/colors.dart';
import '../../data/models/safe_contact_models.dart';
import 'controller.dart';
import 'add_contacts_screen.dart';

class SafeContactsScreen extends StatefulWidget {
  const SafeContactsScreen({Key? key}) : super(key: key);

  @override
  State<SafeContactsScreen> createState() => _SafeContactsScreenState();
}

class _SafeContactsScreenState extends State<SafeContactsScreen> {
  late SafeContactsController _controller;
  bool _shareLocation = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _controller = SafeContactsController();
    _controller.initialize(setState);
    _shareLocation = _controller.locationConfig.isEnabled;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _deleteSafeContact(SafeContact contact) async {
    setState(() => _isDeleting = true);

    await _controller.deleteContact(contact, setState);

    if (mounted) {
      setState(() => _isDeleting = false);
    }
  }

  String formatPhoneNumber(String phoneNumber) {
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanNumber.startsWith('225')) {
      cleanNumber = cleanNumber.substring(3);
    }
    if (cleanNumber.length != 10) {
      return phoneNumber;
    }
    String formattedNumber = '+225 ${cleanNumber.replaceAllMapped(RegExp(r'.{2}'), (match) => '${match.group(0)} ').trim()}';
    return formattedNumber;
  }

  Widget _buildSafeContactTile(SafeContact contact) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1))),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(20)),
            child: Center(
              child: Text(
                contact.description[0].toUpperCase(),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "Poppins"),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.description,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: "Poppins"),
                ),
                const SizedBox(height: 4),
                Text(
                  formatPhoneNumber(contact.number),
                  style: TextStyle(fontSize: 12, fontFamily: "Poppins", color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            icon:
                _isDeleting
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                    : const Icon(Icons.delete_outline, color: AppColors.primary),
            onPressed:
                _isDeleting
                    ? null
                    : () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text(
                              'Confirmer la suppression',
                              style: TextStyle(fontFamily: "Poppins", fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            content: const Text(
                              'Voulez-vous vraiment supprimer ce numéro de confiance ?',
                              style: TextStyle(fontFamily: "Poppins"),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Annuler', style: TextStyle(color: Colors.grey, fontFamily: "Poppins")),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              TextButton(
                                child: const Text('Supprimer', style: TextStyle(color: Colors.red, fontFamily: "Poppins")),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _deleteSafeContact(contact);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
          ),
        ],
      ),
    );
  }

  void _navigateToAddContacts() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddContactsScreen(remainingSlots: _controller.remainingSlots)),
    );

    if (result != null && result is List<SafeContact>) {
      _controller.onContactsAdded(result, setState);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contacts = _controller.contacts;
    final canAddMore = contacts.length < 5;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text(
          'Numéros "Safe"',
          style: TextStyle(color: Colors.black, fontSize: 20, fontFamily: "Poppins", fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Ajouter (conditionnelle)
            if (canAddMore)
              InkWell(
                onTap: _navigateToAddContacts,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1))),
                  child: const Row(
                    children: [
                      Text('Ajouter un nouveau...', style: TextStyle(fontFamily: "Poppins", color: Colors.red, fontSize: 14)),
                    ],
                  ),
                ),
              ),

            // Liste des contacts safe
            if (contacts.isNotEmpty)
              Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      return _buildSafeContactTile(contact);
                    },
                  ),
                ],
              ),

            SizedBox(height: 30),

            // Message si aucun contact
            if (contacts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'Aucun numéro "Safe" enregistré',
                    style: TextStyle(fontSize: 14, fontFamily: "Poppins", color: Colors.grey),
                  ),
                ),
              ),

            // Texte explicatif
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Tous les contacts ajoutés recevront un message les informant que vous êtes en sécurité. Le nombre maximal de contacts est limité à 5.',
                style: TextStyle(fontSize: 12, fontFamily: "Poppins", color: Colors.grey[600]),
              ),
            ),

            // Option de partage de position
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Partager sa position à ces proches',
                    style: TextStyle(fontSize: 14, fontFamily: "Poppins", color: Colors.black),
                  ),
                  CupertinoSwitch(
                    value: _shareLocation,
                    onChanged: (bool value) {
                      setState(() {
                        _shareLocation = value;
                      });
                      _controller.updateLocationSharing(value, setState);
                    },
                    activeColor: const Color(0xFF4CD964),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
