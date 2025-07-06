// lib/screens/chatbot/widgets/chat_message_widget.dart
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/sizes.dart';
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
                    widget.isTyping
                        ? _buildTypingIndicator()
                        : Text(
                          widget.message.text,
                          style: TextStyle(
                            fontSize: AppSizes.bodyMedium,
                            color: widget.message.isUser ? AppColors.white : AppColors.text,
                            height: 1.4,
                          ),
                        ),
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
