import 'package:flutter/material.dart';
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
    if (messages.isEmpty) {
      return const Center(
        child: Text(
          '开始新的对话吧！',
          style: TextStyle(fontSize: 18, color: Colors.grey),
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
          columnChildren.add(_buildBasicBubble(context, message));
        } else if (message.role == 'assistant') {
          if (message.reasoningContent != null &&
              message.reasoningContent!.trim().isNotEmpty) {
            columnChildren.add(_buildReasoningBubble(message));
          }
          columnChildren.add(_buildBasicBubble(context, message));
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

  Widget _buildBasicBubble(BuildContext context, Message message) {
    final bool isUser = message.role == 'user';
    final bool hasError =
        message.error != null && message.error!.trim().isNotEmpty;
    final String displayText = hasError ? message.error! : message.content;

    if (displayText.trim().isEmpty) return const SizedBox.shrink();

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.75,
      ),
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: isUser ? Colors.blue[500] : Colors.grey[200],
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: isUser ? const Radius.circular(18) : Radius.zero,
          bottomRight: isUser ? Radius.zero : const Radius.circular(18),
        ),
      ),
      child: SelectableText(
        displayText,
        style: TextStyle(
          color: isUser
              ? Colors.white
              : (hasError ? Colors.red : Colors.black87),
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildReasoningBubble(Message message) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 4.0),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        leading: const Icon(Icons.psychology_outlined, size: 20),
        title: const Text(
          '思考过程',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          SelectableText(
            message.reasoningContent!,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
