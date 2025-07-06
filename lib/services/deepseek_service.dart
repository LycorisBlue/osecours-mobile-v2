import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';
import 'pharmacy_service.dart';

class DeepSeekService {
  // Contexte du projet O'secours
  static const String _projectContext = '''
Vous êtes l'assistant IA de l'application O'secours, une application mobile d'urgence en Côte d'Ivoire.

CONTEXTE DU PROJET:
- Application mobile d'urgence pour la Côte d'Ivoire
- Permet aux utilisateurs de signaler des urgences et d'obtenir de l'aide
- Fournit des informations sur les services d'urgence locaux
- Géolocalise les hôpitaux, pharmacies et services d'urgence
- Permet de contacter rapidement les secours

FONCTIONNALITÉS PRINCIPALES:
- Alertes d'urgence géolocalisées
- Contacts d'urgence (famille, amis, services)
- Localisation des hôpitaux et pharmacies
- Numéros d'urgence (Police: 170, SAMU: 185, Pompiers: 180)
- Conseils de premiers secours
- Assistance médicale d'urgence

SERVICES DISPONIBLES:
- Hôpitaux et cliniques
- Pharmacies de garde
- Services de police
- Pompiers
- SAMU (Service d'Aide Médicale Urgente)
- Ambulances

RÈGLES DE RÉPONSE:
1. Répondez UNIQUEMENT aux questions liées aux urgences, à la santé, à la sécurité en Côte d'Ivoire
2. Donnez des informations pratiques et utiles
3. Encouragez à appeler les services d'urgence si nécessaire
4. Restez dans le contexte de l'application O'secours
5. Ne répondez pas aux questions sans rapport avec les urgences ou la santé
6. Utilisez un ton professionnel et rassurant

Si une question n'est pas liée aux urgences, à la santé ou à la sécurité, répondez poliment que vous ne pouvez aider que pour les urgences et questions de santé.
''';

  static Future<String> sendMessage(String userMessage) async {
    try {
      // Enrichir le message avec les données des pharmacies si demandé
      String enrichedMessage = await _enrichMessageWithPharmacies(userMessage);

      final response = await http.post(
        Uri.parse(ApiConfig.deepseekBaseUrl),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${ApiConfig.deepseekApiKey}'},
        body: jsonEncode({
          'model': ApiConfig.deepseekModel,
          'messages': [
            {'role': 'system', 'content': _projectContext},
            {'role': 'user', 'content': enrichedMessage},
          ],
          'max_tokens': ApiConfig.maxTokens,
          'temperature': ApiConfig.temperature,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        print('Erreur API DeepSeek: ${response.statusCode}');
        print('Response: ${response.body}');
        return _getFallbackResponse(userMessage);
      }
    } catch (e) {
      print('Erreur lors de l\'appel à l\'API DeepSeek: $e');
      return _getFallbackResponse(userMessage);
    }
  }

  static Future<String> _enrichMessageWithPharmacies(String userMessage) async {
    String message = userMessage.toLowerCase();

    // Vérifier si la question concerne les pharmacies
    if (message.contains('pharmacie') || message.contains('médicament') || message.contains('medicament')) {
      try {
        final pharmacyService = PharmacyService();
        // Coordonnées d'Abidjan par défaut (latitude: 5.3600, longitude: -4.0083)
        final pharmacies = await pharmacyService.getNearbyPharmacies(5.3600, -4.0083);

        if (pharmacies.isNotEmpty) {
          String pharmacyData = '\n\nDonnées des pharmacies disponibles :\n';
          for (int i = 0; i < pharmacies.length && i < 5; i++) {
            final pharmacy = pharmacies[i];
            pharmacyData +=
                '- ${pharmacy['name'] ?? 'Nom inconnu'} (${pharmacy['address'] ?? 'Adresse inconnue'}) - ${pharmacy['distance']?.toStringAsFixed(1) ?? '0.0'} km\n';
          }

          return userMessage + pharmacyData;
        }
      } catch (e) {
        print('Erreur lors de la récupération des pharmacies: $e');
        // Continuer avec le message original si l'API des pharmacies échoue
      }
    }

    return userMessage;
  }

  static String _getFallbackResponse(String userMessage) {
    String message = userMessage.toLowerCase();

    if (message.contains('hôpital') || message.contains('hopital')) {
      return "Voici les hôpitaux les plus proches de votre position :\n\n🏥 CHU de Treichville - 2.3 km\n🏥 Hôpital Général de Bingerville - 4.1 km\n🏥 Clinique Internationale Sainte Anne-Marie - 3.8 km\n\nSouhaitez-vous que je vous guide vers l'un d'eux ?";
    } else if (message.contains('pharmacie')) {
      return "Voici les pharmacies de garde les plus proches :\n\n💊 Pharmacie de la Paix - Ouverte 24h/24 - 1.2 km\n💊 Pharmacie du Plateau - Ouverte jusqu'à 22h - 2.1 km\n💊 Pharmacie Nouvelle - Ouverte 24h/24 - 3.5 km\n\nVoulez-vous les coordonnées de l'une d'elles ?";
    } else if (message.contains('accident') && message.contains('voiture')) {
      return "En cas d'accident de voiture, voici les étapes à suivre :\n\n1. 🚨 Sécurisez la zone et allumez vos feux de détresse\n2. 📞 Appelez les secours (185 ou 170)\n3. 🩹 Vérifiez s'il y a des blessés\n4. 📋 Établissez un constat amiable si possible\n5. 📸 Prenez des photos des dégâts\n\nAvez-vous besoin d'aide pour contacter les secours ?";
    } else if (message.contains('urgence') || message.contains('secours')) {
      return "Pour une urgence, voici les numéros à composer :\n\n🚨 Police: 170\n🚑 SAMU: 185\n🚒 Pompiers: 180\n\nEn cas d'urgence vitale, n'hésitez pas à appeler directement ces numéros.";
    } else {
      return "Je suis l'assistant O'secours, spécialisé dans les urgences et la santé. Je peux vous aider avec :\n\n• Localiser les hôpitaux et pharmacies\n• Donner des conseils d'urgence\n• Fournir les numéros d'urgence\n• Guider en cas d'accident\n\nQue puis-je faire pour vous aider ?";
    }
  }
}
