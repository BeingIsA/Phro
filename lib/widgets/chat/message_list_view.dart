import 'package:flutter/material.dart';
import 'package:phro/l10n/app_localizations.dart';
import 'package:phro/models/message.dart';
import 'package:phro/widgets/chat/assistant_content.dart';
import 'package:phro/widgets/chat/user_input_bubble/editable_user_bubble.dart';
import 'package:phro/widgets/chat/expantion_tiles/reasoning_content_tile.dart';
import 'package:phro/widgets/chat/expantion_tiles/sub_agent_tile.dart';
import 'package:phro/widgets/chat/expantion_tiles/tool_tile.dart';
import 'package:phro/widgets/chat/user_input_bubble/user_bubble.dart';

class MessageListView extends StatelessWidget {
  final List<Message> messages;
  final ScrollController? scrollController;
  // 是否为嵌套模式
  final bool inSubAgent;

  const MessageListView({
    super.key,
    required this.messages,
    this.scrollController,
    // 是否为SubAgent内容
    this.inSubAgent = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (messages.isEmpty) {
      // 嵌套时如果没消息就不显示居中提示语
      if (inSubAgent) return const SizedBox.shrink();
      return Center(
        child: Text(
          l10n.startNewChatText,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      // 嵌套时禁用滚动并自适应高度
      physics: inSubAgent ? const NeverScrollableScrollPhysics() : null,
      shrinkWrap: inSubAgent,
      padding: const EdgeInsets.all(8.0),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final List<Widget> columnChildren = [];

        if (message.role == 'user') {
          if (inSubAgent) {
            columnChildren.add(UserBubble(message: message));
          } else {
            columnChildren.add(EditableUserBubble(message: message));
          }
        } else if (message.role == 'assistant') {
          if (message.reasoningContent?.trim().isNotEmpty ?? false) {
            columnChildren.add(ReasoningContentTile(message: message));
          }
          columnChildren.add(AssistantContent(message: message));
        } else if (message.role == 'tool') {
          if (message.name == 'delegate') {
            columnChildren.add(SubAgentTile(message: message));
          } else {
            columnChildren.add(ToolTile(message: message));
          }
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
}
