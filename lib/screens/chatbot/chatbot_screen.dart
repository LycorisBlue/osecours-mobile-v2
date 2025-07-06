// lib/screens/chatbot/chatbot_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/sizes.dart';
import '../../services/ai_service.dart' show AIService, ChatMessage; // 🆕 Remplace deepseek_service et importe ChatMessage
import 'widgets/chat_message_widget.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  // 🆕 Services IA avec vocal
  late AIService _aiService;

  final List<ChatMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showQuickQuestions = true;
  bool _showKeyboard = false;

  // 🆕 États vocaux
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _isThinking = false;
  bool _autoSpeak = false;
  bool _isServiceReady = false;
  String _recognizedText = '';
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _initializeAI(); // 🆕 Initialiser l'IA vocale

    // 🆕 Écouter les changements dans le champ de texte
    _messageController.addListener(() {
      setState(() {
        _hasText = _messageController.text.trim().isNotEmpty;
      });
    });
  }

  // 🆕 Initialisation IA
  Future<void> _initializeAI() async {
    _aiService = AIService();

    _aiService.onTtsStart = () {
      if (mounted) setState(() => _isSpeaking = true);
    };

    _aiService.onTtsComplete = () {
      if (mounted) setState(() => _isSpeaking = false);
    };

    while (!_aiService.isInitialized) {
      await Future.delayed(Duration(milliseconds: 100));
    }

    if (mounted) {
      setState(() => _isServiceReady = true);
    }
  }

  // 🆕 Fonctionnalités vocales
  Future<void> _startListening() async {
    if (!_aiService.isSpeechAvailable) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Reconnaissance vocale non disponible'), backgroundColor: Colors.red));
      return;
    }

    try {
      await _aiService.startListening(
        onResult: (text) {
          if (mounted) setState(() => _recognizedText = text);
        },
        onListeningChange: (isListening) {
          if (mounted) {
            setState(() => _isListening = isListening);
            if (!isListening && _recognizedText.trim().isNotEmpty) {
              _sendMessage(_recognizedText);
            }
          }
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur vocal: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _stopListening() async {
    await _aiService.stopListening();
    if (mounted) setState(() => _isListening = false);
  }

  Future<void> _speakMessage(String text) async {
    if (_aiService.isTtsAvailable) {
      await _aiService.speak(text);
    }
  }

  Future<void> _stopSpeaking() async {
    await _aiService.stopSpeaking();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true, timestamp: DateTime.now(), isVoice: _isListening)); // 🆕 isVoice
      _showQuickQuestions = false;
      _isThinking = true; // 🆕
      _recognizedText = '';
    });

    _messageController.clear();
    _scrollToBottom();

    // Simuler une réponse du bot
    _simulateBotResponse(text);
  }

  void _simulateBotResponse(String userMessage) async {
    try {
      // 🆕 Utiliser AIService au lieu de DeepSeekService
      String response = await _aiService.generateResponse(userMessage);

      setState(() {
        _messages.add(ChatMessage(text: response, isUser: false, timestamp: DateTime.now(), isVoice: false));
        _isThinking = false; // 🆕
      });
      _scrollToBottom();

      // 🆕 Lecture automatique si activée
      if (_autoSpeak && _aiService.isTtsAvailable) {
        await _aiService.speak(response);
      }
    } catch (e) {
      String fallbackResponse = _generateResponse(userMessage);
      setState(() {
        _messages.add(ChatMessage(text: fallbackResponse, isUser: false, timestamp: DateTime.now(), isVoice: false));
        _isThinking = false; // 🆕
      });
      _scrollToBottom();
    }
  }

  String _generateResponse(String userMessage) {
    // 🆕 Utiliser le fallback d'AIService
    if (_isServiceReady) {
      return _aiService.getFallbackResponse(userMessage);
    }

    // Fallback de base si service pas prêt
    String message = userMessage.toLowerCase();
    if (message.contains('hôpital') || message.contains('hopital')) {
      return "Voici les hôpitaux les plus proches de votre position :\n\n🏥 CHU de Treichville - 2.3 km\n🏥 Hôpital Général de Bingerville - 4.1 km\n🏥 Clinique Internationale Sainte Anne-Marie - 3.8 km\n\nSouhaitez-vous que je vous guide vers l'un d'eux ?";
    }
    return "Je suis l'assistant O'secours. Comment puis-je vous aider ?";
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
    // 🆕 Loading pendant initialisation
    if (!_isServiceReady) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text('Initialisation de l\'assistant...', style: TextStyle(color: AppColors.text)),
            ],
          ),
        ),
      );
    }

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
          // 🆕 Toggle lecture automatique
          if (_aiService.isTtsAvailable)
            IconButton(
              icon: Icon(_autoSpeak ? Icons.volume_up : Icons.volume_off, color: AppColors.text),
              onPressed: () {
                setState(() => _autoSpeak = !_autoSpeak);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_autoSpeak ? 'Lecture automatique activée' : 'Lecture automatique désactivée'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
            ),
          IconButton(
            onPressed: () {
              // Menu options
            },
            icon: Icon(Icons.more_horiz, color: AppColors.text),
          ),
        ],
      ),
      body: Column(
        children: [
          // 🆕 Barre d'état vocal
          if (_isListening || _isThinking || _isSpeaking)
            Container(
              padding: EdgeInsets.all(12),
              color: AppColors.lightGrey.withOpacity(0.3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isListening) ...[
                    Icon(Icons.mic, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Écoute...', style: TextStyle(color: Colors.red)),
                  ],
                  if (_isThinking) ...[
                    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                    SizedBox(width: 8),
                    Text('Réflexion...', style: TextStyle(color: AppColors.primary)),
                  ],
                  if (_isSpeaking) ...[
                    Icon(Icons.volume_up, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Text('Parle...', style: TextStyle(color: Colors.green)),
                  ],
                ],
              ),
            ),

          // 🆕 Texte reconnu
          if (_isListening && _recognizedText.isNotEmpty)
            Container(
              padding: EdgeInsets.all(12),
              color: AppColors.primary.withOpacity(0.1),
              width: double.infinity,
              child: Text(
                'Vous dites: "$_recognizedText"',
                style: TextStyle(fontStyle: FontStyle.italic, color: AppColors.primary),
              ),
            ),

          // Corps principal (IDENTIQUE à votre original)
          Expanded(child: _showQuickQuestions ? _buildInitialScreen() : _buildChatScreen()),

          // 🆕 Bouton stop si parle
          if (_isSpeaking)
            Padding(
              padding: EdgeInsets.all(8),
              child: FloatingActionButton.small(
                onPressed: _stopSpeaking,
                backgroundColor: Colors.orange,
                child: Icon(Icons.stop, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  // VOS WIDGETS ORIGINAUX (identiques)
  Widget _buildInitialScreen() {
    return Padding(
      padding: EdgeInsets.all(AppSizes.spacingMedium),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildQuestionButton("Quel est l'hôpital le plus proche ?"),
                SizedBox(height: AppSizes.spacingMedium),
                _buildQuestionButton("Quels sont les pharmacies\nde gardes les plus proches ?"),
                SizedBox(height: AppSizes.spacingMedium),
                _buildQuestionButton("Que faire en cas d'accident de voiture ?"),
              ],
            ),
          ),
          _buildInputArea(), // 🆕 Avec vocal
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
              final isTyping = _isThinking && index == _messages.length - 1 && !message.isUser;
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

  // 🆕 Zone de saisie AVEC vocal (style WhatsApp)
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
                    hintText: "Posez une question ou utilisez le micro...", // 🆕 Texte mis à jour
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
                  enabled: !_isThinking && !_isListening, // 🆕 Désactiver pendant vocal
                ),
              ),
            ),
            SizedBox(width: AppSizes.spacingSmall),

            // 🆕 Bouton intelligent (micro/envoi selon contexte)
            GestureDetector(
              onTap:
                  _isThinking
                      ? null
                      : _hasText
                      ? () => _sendMessage(_messageController.text) // Envoi si texte
                      : _isListening
                      ? _stopListening // Stop si écoute
                      : _startListening, // Démarrer écoute
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      _isThinking
                          ? Colors.grey
                          : _hasText
                          ? AppColors
                              .primary // Bleu pour envoi
                          : _isListening
                          ? Colors
                              .red // Rouge pour stop
                          : Colors.green, // Vert pour micro
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _hasText
                      ? Icons
                          .send // Icône envoi si texte
                      : _isListening
                      ? Icons
                          .mic_off // Icône micro barré si écoute
                      : Icons.mic, // Icône micro normal
                  color: AppColors.white,
                  size: 18,
                ),
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
    _aiService.dispose(); // 🆕
    super.dispose();
  }
}
