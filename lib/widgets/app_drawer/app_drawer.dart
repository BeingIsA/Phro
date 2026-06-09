import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phro/models/chat.dart';
import 'package:phro/widgets/app_drawer/agent_manager.dart';
import 'package:phro/widgets/app_drawer/chat_history_list.dart';
import 'package:phro/widgets/app_drawer/settings/settings_page.dart';
import 'package:phro/providers/agent_providers.dart';

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
    final titleTextTheme = theme.textTheme.titleMedium?.copyWith(
      fontSize: 17,
      fontWeight: FontWeight.w600,
    );

    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: colorScheme.primary),
            child: Text(
              'Phro',
              style: theme.textTheme.headlineLarge?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // 使用 Consumer 只监听 activatedAgentName
          Consumer(
            builder: (context, ref, child) {
              final activatedAgentName = ref.watch(activatedAgentNameProvider);

              return ListTile(
                title: RichText(
                  text: TextSpan(
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontFamily: 'Noto Sans SC',
                      color: colorScheme.onSurface,
                    ),
                    children: [
                      TextSpan(text: '新对话（', style: titleTextTheme),
                      TextSpan(
                        text: activatedAgentName,
                        style: titleTextTheme?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                      const TextSpan(text: '）'),
                    ],
                  ),
                ),
                trailing: SizedBox(
                  width: 40,
                  child: Icon(
                    Icons.add,
                    size: 22,
                    color: colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  onNewChat();
                  Navigator.pop(context);
                },
              );
            },
          ),

          Divider(height: 1, color: colorScheme.outline),
          AgentManager(titleStyle: titleTextTheme),
          Divider(height: 1, color: colorScheme.outline),
          ChatHistoryList(
            allChats: allChats,
            currentChatId: currentChatId,
            onChatSelected: onChatSelected,
            onRefreshChats: onRefreshChats,
            titleStyle: titleTextTheme,
          ),
          Divider(height: 1, color: colorScheme.outline),
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
                  tooltip: '设置',
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
