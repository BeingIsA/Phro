import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:phro/models/message.dart';
import 'package:phro/widgets/chat/code_element_builder.dart';
import 'package:phro/widgets/chat/editable_user_bubble.dart';
import 'package:phro/widgets/chat/tool_message_tile.dart';

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
          style: theme.textTheme.headlineMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
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
          columnChildren.add(EditableUserBubble(message: message));
        } else if (message.role == 'assistant') {
          if (message.reasoningContent != null &&
              message.reasoningContent!.trim().isNotEmpty) {
            columnChildren.add(_buildReasoningBubble(context, message));
          }
          columnChildren.add(_buildAssistantContent(context, message));
        } else if (message.role == 'tool') {
          columnChildren.add(ToolMessageTile(message: message));
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
          : SelectionArea(
              child: GptMarkdown(
                displayText,

                codeBuilder: (context, name, code, closed) => CustomCodeBlock(
                  language: name,
                  codeText: code,
                  closed: closed,
                ),
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
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
          color: colorScheme.primary,
        ),
        title: Text(
          '思考过程',
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
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
