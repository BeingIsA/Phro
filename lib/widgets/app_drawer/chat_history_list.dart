import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phro/notifiers/chat_history_notifier.dart';
import 'package:phro/notifiers/selected_chat_notifier.dart';
import 'package:phro/services/chat_service.dart';
import 'package:phro/widgets/common/delete_alert_dialog.dart';

class ChatHistoryList extends ConsumerStatefulWidget {
  final TextStyle? titleStyle;

  const ChatHistoryList({super.key, this.titleStyle});

  @override
  ConsumerState<ChatHistoryList> createState() => _ChatHistoryListState();
}

class _ChatHistoryListState extends ConsumerState<ChatHistoryList> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final chatService = ChatService.instance;
    final currentChat = ref.watch(selectedChatNotifierProvider);
    final chatHistoryList = ref.watch(chatHistoryNotifierProvider).value ?? [];

    return Expanded(
      child: Column(
        children: [
          // 可折叠标题栏
          ListTile(
            title: Text('聊天历史', style: widget.titleStyle),
            trailing: SizedBox(
              width: 40,
              child: Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                size: 22,
                color: colorScheme.onSurface,
              ),
            ),
            onTap: () {
              setState(() => _isExpanded = !_isExpanded);
            },
          ),
          // 可折叠内容
          if (_isExpanded)
            Expanded(
              child: chatHistoryList.isEmpty
                  ? Center(
                      child: Text(
                        '暂无历史对话',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    )
                  : ListView.builder(
                      itemCount: chatHistoryList.length,
                      itemBuilder: (context, index) {
                        final chat = chatHistoryList[index];
                        return ListTile(
                          leading: const Icon(Icons.chat_bubble_outline),
                          title: Text(
                            chat.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall,
                          ),
                          selected: chat.id == currentChat?.id,
                          onTap: () async {
                            await ref
                                .read(selectedChatNotifierProvider.notifier)
                                .select(chat.id);
                            Navigator.pop(context);
                          },
                          trailing: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, size: 20),
                            onSelected: (value) async {
                              if (value == 'edit') {
                                final newTitle = await _showEditDialog(
                                  context,
                                  chat.title,
                                );
                                if (newTitle != null &&
                                    newTitle.trim().isNotEmpty &&
                                    newTitle != chat.title) {
                                  await chatService.updateChatTitle(
                                    chat.id,
                                    newTitle,
                                  );

                                  await ref
                                      .read(
                                        chatHistoryNotifierProvider.notifier,
                                      )
                                      .refresh();
                                }
                              } else if (value == 'delete') {
                                final confirm = await _showDeleteConfirmDialog(
                                  context,
                                  chat.title,
                                );
                                if (confirm == true) {
                                  // 如果删掉的是当前对话，则更新状态
                                  if (chat.id == currentChat?.id) {
                                    ref
                                        .read(
                                          selectedChatNotifierProvider.notifier,
                                        )
                                        .clear();
                                  }
                                  await chatService.deleteChat(chat.id);
                                  await ref
                                      .read(
                                        chatHistoryNotifierProvider.notifier,
                                      )
                                      .refresh();
                                }
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 20),
                                    SizedBox(width: 8),
                                    Text('编辑'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      size: 20,
                                      color: colorScheme.error,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '删除',
                                      style: TextStyle(
                                        color: colorScheme.error,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }

  // 编辑对话框
  Future<String?> _showEditDialog(BuildContext context, String currentTitle) {
    final controller = TextEditingController(text: currentTitle);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑标题'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '请输入新标题'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  // 删除确认对话框
  Future<bool?> _showDeleteConfirmDialog(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;

    return showDialog<bool>(
      context: context,
      builder: (context) => DeleteAlertDialog(
        colorScheme: colorScheme,
        content: '确定删除会话 "$title" 吗？此操作无法撤销。',
      ),
    );
  }
}
