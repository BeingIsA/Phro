import 'package:flutter/material.dart';
import 'package:phro/models/chat.dart';
import 'package:phro/pages/app_drawer/agent_selector.dart';
import 'package:phro/pages/app_drawer/chat_history_list.dart';
import 'package:phro/pages/app_drawer/settings/settings_page.dart';
import 'package:phro/services/agent_service.dart';
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
    final agentService = AgentService.instance;
    final activatedAgentName = agentService.getActivatedName();
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
            title: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'Noto Sans SC',
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ), // 默认颜色
                children: [
                  const TextSpan(text: '新对话（'),
                  TextSpan(
                    text: activatedAgentName,
                    style: TextStyle(color: Colors.blue),
                  ),
                  const TextSpan(text: '）'),
                ],
              ),
            ),
            onTap: () {
              onNewChat();
              Navigator.pop(context);
            },
          ),
          const Divider(height: 1),
          AgentSelector(),
          const Divider(height: 1),
          ChatHistoryList(
            allChats: allChats,
            currentChatId: currentChatId,
            onChatSelected: onChatSelected,
            onRefreshChats: onRefreshChats,
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
          pageBuilder: (context, _, _) => const SettingsPage(),
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
