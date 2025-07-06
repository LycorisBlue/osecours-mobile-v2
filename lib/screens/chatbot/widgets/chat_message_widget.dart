// lib/screens/chatbot/widgets/chat_message_widget.dart
import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/constants/themes.dart';
import '../chatbot_screen.dart';

class ChatMessageWidget extends StatefulWidget {
  final ChatMessage message;
  final bool isTyping;

  const ChatMessageWidget({Key? key, required this.message, this.isTyping = false}) : super(key: key);

  @override
  State<ChatMessageWidget> createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends State<ChatMessageWidget> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _typingController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _typingAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _typingController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));

    _typingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _typingController, curve: Curves.easeInOut));

    _fadeController.forward();

    if (widget.isTyping) {
      _typingController.repeat(reverse: true);
    }
  }

  /// Corrige l'encodage UTF-8 mal interprété
  String _fixEncoding(String text) {
    // Corrections des caractères les plus courants
    return text
        .replaceAll('Ã©', 'é')
        .replaceAll('Ã¨', 'è')
        .replaceAll('Ã ', 'à')
        .replaceAll('Ã´', 'ô')
        .replaceAll('Ã§', 'ç')
        .replaceAll('Ã¹', 'ù')
        .replaceAll('Ã«', 'ë')
        .replaceAll('Ã¯', 'ï')
        .replaceAll('Ã®', 'î')
        .replaceAll('Ã¢', 'â')
        .replaceAll('Ã', 'à'); // Fallback général
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _typingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: EdgeInsets.only(bottom: AppSizes.spacingMedium),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: widget.message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!widget.message.isUser) ..._buildBotAvatar(),
            SizedBox(width: AppSizes.spacingSmall),
            Flexible(
              child: Container(
                padding: EdgeInsets.all(AppSizes.spacingMedium),
                decoration: BoxDecoration(
                  color: widget.message.isUser ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(widget.message.isUser ? 16 : 4),
                    bottomRight: Radius.circular(widget.message.isUser ? 4 : 16),
                  ),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.isTyping ? _buildTypingIndicator() : _buildMessageContent(),
                    if (!widget.isTyping) ...[
                      SizedBox(height: AppSizes.spacingXSmall),
                      Text(
                        _formatTime(widget.message.timestamp),
                        style: TextStyle(
                          fontSize: AppSizes.bodySmall,
                          color: widget.message.isUser ? AppColors.white.withOpacity(0.7) : AppColors.textLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(width: AppSizes.spacingSmall),
            if (widget.message.isUser) ..._buildUserAvatar(),
          ],
        ),
      ),
    );
  }

/// Widget pour afficher le contenu du message avec support Markdown
  Widget _buildMessageContent() {
    return MarkdownBody(
      data: _fixEncoding(widget.message.text),
      styleSheet: MarkdownStyleSheet(
        p: _getBaseTextStyle(),
        strong: _getBaseTextStyle().copyWith(fontWeight: FontWeight.bold),
        em: _getBaseTextStyle().copyWith(fontStyle: FontStyle.italic),
        h1: _getBaseTextStyle().copyWith(fontSize: AppSizes.h1, fontWeight: FontWeight.bold),
        h2: _getBaseTextStyle().copyWith(fontSize: AppSizes.h2, fontWeight: FontWeight.bold),
        h3: _getBaseTextStyle().copyWith(fontSize: AppSizes.h3, fontWeight: FontWeight.bold),
        code: _getBaseTextStyle().copyWith(
          backgroundColor: widget.message.isUser ? AppColors.white.withOpacity(0.2) : AppColors.lightGrey.withOpacity(0.5),
          fontFamily: 'monospace',
        ),
        codeblockDecoration: BoxDecoration(
          color: widget.message.isUser ? AppColors.white.withOpacity(0.1) : AppColors.lightGrey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        listBullet: _getBaseTextStyle(),
        blockquote: _getBaseTextStyle().copyWith(fontStyle: FontStyle.italic, color: _getTextColor().withOpacity(0.8)),
      ),
      selectable: true,
      // Ajout de ces propriétés pour les caractères spéciaux
      extensionSet: md.ExtensionSet(md.ExtensionSet.gitHubFlavored.blockSyntaxes, [
        md.EmojiSyntax(),
        ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
      ]),
    );
  }

  /// Style de texte de base selon le type de message
  TextStyle _getBaseTextStyle() {
    return AppTextStyles.bodyMedium.copyWith(color: _getTextColor(), height: 1.5, fontFamily: 'Poppins');
  }

  /// Couleur du texte selon le type de message
  Color _getTextColor() {
    return widget.message.isUser ? AppColors.white : AppColors.text;
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "En train d'écrire",
          style: TextStyle(fontSize: AppSizes.bodyMedium, color: AppColors.textLight, fontStyle: FontStyle.italic),
        ),
        SizedBox(width: AppSizes.spacingXSmall),
        AnimatedBuilder(
          animation: _typingAnimation,
          builder: (context, child) {
            return Row(
              children: List.generate(3, (index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 1),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(
                        0.3 +
                            (0.7 *
                                _typingAnimation.value *
                                (index == 0
                                    ? 1.0
                                    : index == 1
                                    ? 0.7
                                    : 0.4)),
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }

  List<Widget> _buildBotAvatar() {
    return [
      Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
        child: Icon(Icons.smart_toy, color: AppColors.white, size: 18),
      ),
    ];
  }

  List<Widget> _buildUserAvatar() {
    return [
      Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(16)),
        child: Icon(Icons.person, color: AppColors.text, size: 18),
      ),
    ];
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
