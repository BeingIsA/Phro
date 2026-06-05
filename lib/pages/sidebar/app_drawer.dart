import 'package:flutter/material.dart';
import 'package:phro/models/chat.dart';
import 'package:phro/pages/sidebar/agent_selector.dart';
import 'package:phro/pages/sidebar/settings/settings_page.dart';
import 'package:phro/services/chat_service.dart';

class AppDrawer extends StatelessWidget {
  final List<Chat> allChats;
  final String? currentChatId;
  final ValueChanged<String> onChatSelected;
  final VoidCallback onNewChat; // 注意：这里改回 VoidCallback
  final VoidCallback onRefreshChats;

  const AppDrawer({
    super.key,
    required this.allChats,
    required this.currentChatId,
    required this.onChatSelected,
    required this.onNewChat,
    required this.onRefreshChats,
  });

  @override
  Widget build(BuildContext context) {
    final chatService = ChatService.instance;

    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Phro',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('新对话'),
            onTap: () {
              onNewChat();
              Navigator.pop(context);
            },
          ),
          const Divider(height: 1),

          AgentSelector(onAgentChanged: onNewChat),
          const Divider(height: 1),

          Expanded(
            child: allChats.isEmpty
                ? const Center(
                    child: Text('暂无历史对话', style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    itemCount: allChats.length,
                    itemBuilder: (context, index) {
                      final chat = allChats[index];
                      return ListTile(
                        leading: const Icon(Icons.chat_bubble_outline),
                        title: Text(
                          chat.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        selected: chat.id == currentChatId,
                        onTap: () {
                          onChatSelected(chat.id);
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
                                onRefreshChats();
                              }
                            } else if (value == 'delete') {
                              final confirm = await _showDeleteConfirmDialog(
                                context,
                                chat.title,
                              );
                              if (confirm == true) {
                                await chatService.deleteChat(chat.id);
                                onRefreshChats();
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
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    '删除',
                                    style: TextStyle(color: Colors.red),
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
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => _openSettings(context),
                  icon: const Icon(Icons.settings_outlined, size: 28),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 移入内部的辅助弹窗逻辑
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

  // 删除确认弹窗
  Future<bool?> _showDeleteConfirmDialog(BuildContext context, String title) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除对话'),
        content: Text('确定删除 "$title" 吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  // 设置页面
  void _openSettings(BuildContext context) {
    final bool isSmallScreen = MediaQuery.sizeOf(context).shortestSide < 600;

    if (isSmallScreen) {
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          pageBuilder: (context, _, __) => const SettingsPage(),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560, maxHeight: 680),
            child: const Padding(
              padding: EdgeInsets.all(24),
              child: SettingsPage(),
            ),
          ),
        ),
      );
    }
  }
}
