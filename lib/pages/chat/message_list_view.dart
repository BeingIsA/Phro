import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:phro/models/message.dart';
import 'package:phro/pages/chat/tool_message_tile.dart';
import 'package:phro/services/chat_service.dart';

class MessageListView extends StatelessWidget {
  final List<Message> messages;
  final ScrollController scrollController;

  const MessageListView({
    super.key,
    required this.messages,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (messages.isEmpty) {
      return Center(
        child: Text(
          '开始新的对话吧！',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 18,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(8.0),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        List<Widget> columnChildren = [];

        if (message.role == 'user') {
          columnChildren.add(_buildUserBubble(context, message));
        } else if (message.role == 'assistant') {
          if (message.reasoningContent != null &&
              message.reasoningContent!.trim().isNotEmpty) {
            columnChildren.add(_buildReasoningBubble(context, message));
          }
          columnChildren.add(_buildAssistantContent(context, message));
        } else if (message.role == 'tool') {
          columnChildren.add(
            ToolMessageTile(
              message: message,
              chatService: ChatService.instance,
            ),
          );
        }

        return Align(
          alignment: message.role == 'user'
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: message.role == 'user'
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: columnChildren,
          ),
        );
      },
    );
  }

  Widget _buildAssistantContent(BuildContext context, Message message) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bool hasError =
        message.error != null && message.error!.trim().isNotEmpty;
    final String displayText = hasError ? message.error! : message.content;

    if (displayText.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: hasError
          ? SelectableText(
              displayText,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.error,
                fontSize: 16,
                height: 1.5,
              ),
            )
          : MarkdownBody(
              data: displayText,
              selectable: true,
              styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                p: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                code: theme.textTheme.bodyMedium?.copyWith(
                  backgroundColor: colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
    );
  }

  Widget _buildUserBubble(BuildContext context, Message message) {
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.75,
      ),
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: colorScheme.primary, // 使用主题 primary
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.zero,
        ),
      ),
      child: SelectableText(
        message.content,
        style: theme.textTheme.bodyLarge?.copyWith(
          // 统一使用 textTheme
          color: colorScheme.onPrimary,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildReasoningBubble(BuildContext context, Message message) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 4.0),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        leading: Icon(
          Icons.psychology_outlined,
          size: 20,
          color: colorScheme.onSurfaceVariant,
        ),
        title: Text(
          '思考过程',
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          SelectableText(
            message.reasoningContent!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
