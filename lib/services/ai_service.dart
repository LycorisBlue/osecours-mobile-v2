// lib/services/ai_service.dart
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../core/config/api_config.dart';

// Classe pour les messages de chat
class ChatMessage {
  final String text;
  final bool isUser;
  final bool isVoice;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, this.isVoice = false, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();
}

class AIService {
  // Services
  late GenerativeModel _gemini;
  late FlutterTts _flutterTts;
  late SpeechToText _speechToText;

  // États
  bool _isInitialized = false;
  bool _ttsInitialized = false;
  bool _speechInitialized = false;

  // Getters pour vérifier l'état
  bool get isInitialized => _isInitialized;
  bool get isTtsAvailable => _ttsInitialized;
  bool get isSpeechAvailable => _speechInitialized;

  // Callbacks TTS
  Function()? onTtsStart;
  Function()? onTtsComplete;

  // Contexte O'secours (identique à GeminiService)
static const String _projectContext = '''
Vous êtes l'assistant IA de l'application O'secours, une application mobile d'urgence en Côte d'Ivoire.

CONTEXTE DU PROJET:
O'secours est une application mobile d'urgence conçue spécialement pour la Côte d'Ivoire. Elle permet aux utilisateurs de signaler des urgences, d'obtenir de l'aide rapidement, de localiser les services d'urgence locaux comme les hôpitaux et pharmacies, et de contacter directement les secours.

FONCTIONNALITÉS PRINCIPALES:
L'application propose des alertes d'urgence géolocalisées, la gestion des contacts d'urgence (famille, amis, services), la localisation des hôpitaux et pharmacies, des conseils de premiers secours et une assistance médicale d'urgence.

NUMÉROS D'URGENCE EN CÔTE D'IVOIRE:
En cas d'urgence, voici les numéros officiels à composer : 185 (ou +225 27 22 44 53 53) pour le SAMU et les urgences médicales, 180 pour les Pompiers et la Protection civile, 110 ou 111 ou 170 pour la Police secours, 199 pour la Défense nationale, 111 pour la Gendarmerie ou 145 pour l'unité spéciale CCDO. Pour les urgences techniques, composez le 175 pour le dépannage eau SODECI ou le 179 pour le dépannage électricité CIE. Ces numéros sont gratuits et disponibles 24h/24.

SERVICES DISPONIBLES:
Vous avez accès aux informations sur les hôpitaux et cliniques, les pharmacies de garde, les services de police, les pompiers, le SAMU (Service d'Aide Médicale Urgente), les ambulances, la gendarmerie et les services de dépannage d'urgence.

RÈGLES DE RÉPONSE:
Répondez uniquement aux questions liées aux urgences, à la santé et à la sécurité en Côte d'Ivoire. Donnez des informations pratiques et utiles. Encouragez à appeler les services d'urgence si nécessaire. Restez dans le contexte de l'application O'secours.

Utilisez un ton professionnel et rassurant. Rédigez vos réponses en paragraphes fluides, sans utiliser de formatage markdown, sans puces, sans texte en gras et sans grands titres. Privilégiez des paragraphes courts séparés par des sauts de ligne pour faciliter la lecture.

Si une question n'est pas liée aux urgences, à la santé ou à la sécurité, répondez poliment que vous ne pouvez aider que pour les urgences et questions de santé en Côte d'Ivoire.
''';


  AIService() {
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Initialiser Gemini
      _gemini = GenerativeModel(model: ApiConfig.geminiModel, apiKey: ApiConfig.geminiApiKey);

      // Initialiser TTS
      await _initializeTTS();

      // Initialiser Speech-to-Text
      await _initializeSpeech();

      _isInitialized = true;
    } catch (e) {
      print('Erreur lors de l\'initialisation des services: $e');
    }
  }

  Future<void> _initializeTTS() async {
    try {
      _flutterTts = FlutterTts();

      await _flutterTts.setLanguage("fr-FR");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setStartHandler(() {
        onTtsStart?.call();
      });

      _flutterTts.setCompletionHandler(() {
        onTtsComplete?.call();
      });

      _flutterTts.setErrorHandler((message) {
        print('Erreur TTS: $message');
        onTtsComplete?.call();
      });

      _ttsInitialized = true;
    } catch (e) {
      print('Erreur lors de l\'initialisation TTS: $e');
      _ttsInitialized = false;
    }
  }

  Future<void> _initializeSpeech() async {
    try {
      _speechToText = SpeechToText();

      bool available = await _speechToText.initialize(
        onError: (errorNotification) {
          print('Erreur Speech-to-Text: ${errorNotification.errorMsg}');
        },
        onStatus: (status) {
          print('Status Speech-to-Text: $status');
        },
      );

      _speechInitialized = available;
    } catch (e) {
      print('Erreur lors de l\'initialisation Speech-to-Text: $e');
      _speechInitialized = false;
    }
  }

  // Générer une réponse avec Gemini (contexte O'secours)
  Future<String> generateResponse(String input) async {
    if (!_isInitialized) {
      throw Exception('Service AI non initialisé');
    }

    try {
      // Créer le prompt avec le contexte O'secours
      final prompt = '''$_projectContext

QUESTION DE L'UTILISATEUR: $input

Répondez en tant qu'assistant O'secours spécialisé en urgences et santé.''';

      final response = await _gemini.generateContent([Content.text(prompt)]);

      if (response.text != null && response.text!.isNotEmpty) {
        return response.text!;
      } else {
        return getFallbackResponse(input);
      }
    } catch (e) {
      print('Erreur lors de la génération de contenu: $e');
      return getFallbackResponse(input);
    }
  }

  // Réponses de secours (identiques à GeminiService)
  String getFallbackResponse(String userMessage) {
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

  // Text-to-Speech
  Future<void> speak(String text) async {
    if (!_ttsInitialized || text.trim().isEmpty) return;

    try {
      // Nettoyer le texte pour TTS (enlever markdown)
      String cleanText = _cleanTextForTTS(text);
      await _flutterTts.speak(cleanText);
    } catch (e) {
      print('Erreur lors de la synthèse vocale: $e');
    }
  }

  Future<void> stopSpeaking() async {
    if (!_ttsInitialized) return;

    try {
      await _flutterTts.stop();
    } catch (e) {
      print('Erreur lors de l\'arrêt de la synthèse vocale: $e');
    }
  }

  // Speech-to-Text
  Future<void> startListening({required Function(String) onResult, required Function(bool) onListeningChange}) async {
    if (!_speechInitialized) {
      throw Exception('Service de reconnaissance vocale non disponible');
    }

    try {
      onListeningChange(true);

      await _speechToText.listen(
        onResult: (result) {
          onResult(result.recognizedWords);

          if (result.finalResult) {
            onListeningChange(false);
          }
        },
        localeId: 'fr-FR',
        listenFor: Duration(seconds: 30),
        pauseFor: Duration(seconds: 3),
        partialResults: true,
      );
    } catch (e) {
      print('Erreur lors du démarrage de l\'écoute: $e');
      onListeningChange(false);
    }
  }

  Future<void> stopListening() async {
    if (!_speechInitialized) return;

    try {
      await _speechToText.stop();
    } catch (e) {
      print('Erreur lors de l\'arrêt de l\'écoute: $e');
    }
  }

  // Nettoyer le texte pour la synthèse vocale (enlever markdown)
  String _cleanTextForTTS(String text) {
    return text
        .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'\1') // **texte** → texte
        .replaceAll(RegExp(r'\*(.*?)\*'), r'\1') // *texte* → texte
        .replaceAll(RegExp(r'`(.*?)`'), r'\1') // `code` → code
        .replaceAll(RegExp(r'#{1,6}\s*'), '') // # titre → titre
        .replaceAll(RegExp(r'\n\s*\n'), '. ') // Double saut de ligne → point
        .replaceAll('\n', ' ') // Saut de ligne → espace
        .replaceAll('•', '') // Puces
        .replaceAll('🏥', 'Hôpital') // Emojis hôpital
        .replaceAll('💊', 'Pharmacie') // Emojis pharmacie
        .replaceAll('🚨', 'Urgence') // Emojis urgence
        .replaceAll('📞', 'Téléphone') // Emojis téléphone
        .replaceAll('🩹', 'Soins') // Emojis soins
        .replaceAll(RegExp(r'[🔥⚡🚑🚒👨‍⚕️]'), '') // Autres emojis
        .trim();
  }

  // Configuration TTS
  Future<void> configureTTS({double? speechRate, double? volume, double? pitch, String? language}) async {
    if (!_ttsInitialized) return;

    try {
      if (speechRate != null) await _flutterTts.setSpeechRate(speechRate);
      if (volume != null) await _flutterTts.setVolume(volume);
      if (pitch != null) await _flutterTts.setPitch(pitch);
      if (language != null) await _flutterTts.setLanguage(language);
    } catch (e) {
      print('Erreur lors de la configuration TTS: $e');
    }
  }

  // Nettoyage des ressources
  void dispose() {
    try {
      _flutterTts.stop();
      _speechToText.stop();
    } catch (e) {
      print('Erreur lors du nettoyage: $e');
    }
  }
}
