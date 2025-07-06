// lib/screens/chatbot/chatbot_screen.dart
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/sizes.dart';
import '../../services/deepseek_service.dart';
import 'widgets/chat_message_widget.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showQuickQuestions = true;
  bool _showKeyboard = false;

  @override
  void initState() {
    super.initState();
    // Pas de message de bienvenue automatique selon la maquette
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true, timestamp: DateTime.now()));
      _showQuickQuestions = false;
    });

    _messageController.clear();
    _scrollToBottom();

    // Ajouter un message de frappe temporaire
    final typingMessage = ChatMessage(text: "", isUser: false, timestamp: DateTime.now());

    setState(() {
      _messages.add(typingMessage);
    });
    _scrollToBottom();

    // Simuler une réponse du bot avec animation de frappe
    _simulateBotResponse(text);
  }

  void _simulateBotResponse(String userMessage) async {
    try {
      String response = await DeepSeekService.sendMessage(userMessage);
      setState(() {
        // Retirer le message de frappe
        if (_messages.isNotEmpty && _messages.last.text.isEmpty && !_messages.last.isUser) {
          _messages.removeLast();
        }
        // Ajouter la vraie réponse
        _messages.add(ChatMessage(text: response, isUser: false, timestamp: DateTime.now()));
      });
      _scrollToBottom();
    } catch (e) {
      // En cas d'erreur, utiliser une réponse de secours
      String fallbackResponse = _generateResponse(userMessage);
      setState(() {
        if (_messages.isNotEmpty && _messages.last.text.isEmpty && !_messages.last.isUser) {
          _messages.removeLast();
        }
        _messages.add(ChatMessage(text: fallbackResponse, isUser: false, timestamp: DateTime.now()));
      });
      _scrollToBottom();
    }
  }

  String _generateResponse(String userMessage) {
    String message = userMessage.toLowerCase();

    if (message.contains('hôpital') || message.contains('hopital')) {
      return "Voici les hôpitaux les plus proches de votre position :\n\n🏥 CHU de Treichville - 2.3 km\n🏥 Hôpital Général de Bingerville - 4.1 km\n🏥 Clinique Internationale Sainte Anne-Marie - 3.8 km\n\nSouhaitez-vous que je vous guide vers l'un d'eux ?";
    } else if (message.contains('pharmacie')) {
      return "Voici les pharmacies de garde les plus proches :\n\n💊 Pharmacie de la Paix - Ouverte 24h/24 - 1.2 km\n💊 Pharmacie du Plateau - Ouverte jusqu'à 22h - 2.1 km\n💊 Pharmacie Nouvelle - Ouverte 24h/24 - 3.5 km\n\nVoulez-vous les coordonnées de l'une d'elles ?";
    } else if (message.contains('accident') && message.contains('voiture')) {
      return "En cas d'accident de voiture, voici les étapes à suivre :\n\n1. 🚨 Sécurisez la zone et allumez vos feux de détresse\n2. 📞 Appelez les secours (185 ou 170)\n3. 🩹 Vérifiez s'il y a des blessés\n4. 📋 Établissez un constat amiable si possible\n5. 📸 Prenez des photos des dégâts\n\nAvez-vous besoin d'aide pour contacter les secours ?";
    } else {
      return "Je comprends votre préoccupation. Pour une assistance plus précise, je vous recommande de :\n\n• Contacter directement les services d'urgence si c'est urgent\n• Utiliser les fonctionnalités d'alerte de l'application\n• Consulter les numéros d'urgence disponibles\n\nY a-t-il autre chose que je puisse vous aider ?";
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.arrow_back_ios_new, color: AppColors.text, size: 16),
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset('assets/pictures/logo.png', fit: BoxFit.cover),
              ),
            ),
            SizedBox(width: AppSizes.spacingSmall),
            Text("O'secours AI", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.text)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Menu options
            },
            icon: Icon(Icons.more_horiz, color: AppColors.text),
          ),
        ],
      ),
      body: _showQuickQuestions ? _buildInitialScreen() : _buildChatScreen(),
    );
  }

  Widget _buildInitialScreen() {
    return Padding(
      padding: EdgeInsets.all(AppSizes.spacingMedium),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Questions prédéfinies selon la maquette
                _buildQuestionButton("Quel est l'hôpital le plus proche ?"),
                SizedBox(height: AppSizes.spacingMedium),
                _buildQuestionButton("Quels sont les pharmacies\nde gardes les plus proches ?"),
                SizedBox(height: AppSizes.spacingMedium),
                _buildQuestionButton("Que faire en cas d'accident de voiture ?"),
              ],
            ),
          ),
          // Zone de saisie en bas
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildChatScreen() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(AppSizes.spacingMedium),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              final isTyping = message.text.isEmpty && !message.isUser;
              return ChatMessageWidget(message: message, isTyping: isTyping);
            },
          ),
        ),
        _buildInputArea(),
      ],
    );
  }

  Widget _buildQuestionButton(String question) {
    return GestureDetector(
      onTap: () => _sendMessage(question),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSizes.spacingMedium),
        decoration: BoxDecoration(
          color: AppColors.lightGrey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.lightGrey, width: 1),
        ),
        child: Text(
          question,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: AppSizes.bodyMedium, color: AppColors.text, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.all(AppSizes.spacingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: AppColors.lightGrey, width: 1),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: "Posez une question...",
                    hintStyle: TextStyle(color: AppColors.textLight, fontSize: AppSizes.bodyMedium),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.spacingMedium, vertical: AppSizes.spacingSmall),
                  ),
                  style: TextStyle(fontSize: AppSizes.bodyMedium, color: AppColors.text),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _sendMessage(_messageController.text),
                  onTap: () {
                    setState(() {
                      _showQuickQuestions = false;
                    });
                  },
                ),
              ),
            ),
            SizedBox(width: AppSizes.spacingSmall),
            GestureDetector(
              onTap: () => _sendMessage(_messageController.text),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
                child: Icon(Icons.send, color: AppColors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, required this.timestamp});
}
