import 'package:flutter/material.dart';
import 'package:phro/models/chat.dart';
import 'package:phro/widgets/app_drawer/agent_selector.dart';
import 'package:phro/widgets/app_drawer/chat_history_list.dart';
import 'package:phro/widgets/app_drawer/settings/settings_page.dart';
import 'package:phro/services/agent_service.dart';

class AppDrawer extends StatelessWidget {
  final List<Chat> allChats;
  final String? currentChatId;
  final ValueChanged<String> onChatSelected;
  final VoidCallback onNewChat;
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final agentService = AgentService.instance;
    final activatedAgentName = agentService.getActivatedName();

    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: colorScheme.primary, // 使用主题主色
            ),
            child: Text(
              'Phro',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.add, color: colorScheme.onSurface),
            title: RichText(
              text: TextSpan(
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: 'Noto Sans SC',
                  color: colorScheme.onSurface,
                ),
                children: [
                  const TextSpan(text: '新对话（'),
                  TextSpan(
                    text: activatedAgentName,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
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
                  icon: Icon(
                    Icons.settings_outlined,
                    size: 28,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
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
