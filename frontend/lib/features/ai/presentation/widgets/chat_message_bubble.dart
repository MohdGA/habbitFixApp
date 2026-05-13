import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/ai_repository.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageBubble({super.key, required this.message});

  bool get _isUser => message.role == MessageRole.user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: _isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!_isUser) ...[
            // Avatar
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                gradient: AppColors.xpGradient,
                shape: BoxShape.circle,
              ),
              child: const Center(child: Text('🤖', style: TextStyle(fontSize: 16))),
            ),
          ],

          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _isUser ? AppColors.purple : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(_isUser ? 18 : 4),
                  bottomRight: Radius.circular(_isUser ? 4 : 18),
                ),
                border: _isUser
                    ? null
                    : Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.content.isEmpty && message.isStreaming)
                    _TypingIndicator()
                  else
                    _MessageContent(text: message.content),
                  if (message.isStreaming && message.content.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: _CursorBlink(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Renders message with basic markdown-like formatting (no package needed)
class _MessageContent extends StatelessWidget {
  final String text;
  const _MessageContent({required this.text});

  @override
  Widget build(BuildContext context) {
    final spans = _parseMarkdown(text);
    return RichText(
      text: TextSpan(
        children: spans,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          height: 1.5,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  List<TextSpan> _parseMarkdown(String text) {
    final spans = <TextSpan>[];
    final boldPattern = RegExp(r'\*\*(.*?)\*\*');

    int lastEnd = 0;
    for (final match in boldPattern.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ));
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }
    return spans.isEmpty ? [TextSpan(text: text)] : spans;
  }
}

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
        (i) => Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: const BoxDecoration(
            color: AppColors.textMuted,
            shape: BoxShape.circle,
          ),
        )
            .animate(delay: Duration(milliseconds: i * 150), onPlay: (c) => c.repeat(reverse: true))
            .moveY(begin: 0, end: -4, duration: 400.ms, curve: Curves.easeInOut),
      ),
    );
  }
}

class _CursorBlink extends StatelessWidget {
  const _CursorBlink();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 2,
      height: 14,
      color: AppColors.purple,
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .fadeIn(duration: 400.ms)
        .fadeOut(duration: 400.ms);
  }
}
