import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phro/providers/chat_providers.dart';
import 'package:phro/widgets/message_input.dart';
import 'package:phro/services/chat_service.dart';
import 'package:phro/models/chat.dart';
import 'package:phro/models/message.dart';

import 'app_drawer/app_drawer.dart';
import 'chat/message_list_view.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ChatService _chatService = ChatService.instance;
  final ScrollController _scrollController = ScrollController();

  List<Chat> _allChats = [];

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 当切换到新的聊天时，滚动到底部
    ref.listen(selectedChatProvider, (previous, next) {
      _scrollToBottom();
    });

    final currentChat = ref.watch(selectedChatProvider);
    final List<Message> messages = currentChat != null
        ? currentChat.messages.where((m) => m.role != 'system').toList()
        : [];

    return Scaffold(
      appBar: AppBar(title: const Text('Phro')),
      // 声明式使用重构后的抽屉
      drawer: AppDrawer(
        allChats: _allChats,
        currentChatId: currentChat?.id,
        onRefreshChats: _loadChats,
      ),
      body: Column(
        children: [
          if (currentChat != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              color: theme.colorScheme.surfaceContainerHighest,
              child: Text(
                '当前对话Agent：${currentChat.agentName}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),

          // 声明式使用重构后的消息列表
          Expanded(
            child: MessageListView(
              messages: messages,
              scrollController: _scrollController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: MessageInput(onSend: _handleSendMessage),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _loadChats() async {
    final chats = await _chatService.getAllChats();
    if (mounted) setState(() => _allChats = chats);
  }

  Future<void> _handleSendMessage(String content) async {
    if (content.trim().isEmpty) return;
    final notifier = ref.read(selectedChatProvider.notifier);
    Chat? currentChat = ref.read(selectedChatProvider);

    if (currentChat == null) {
      currentChat = await _chatService.createChat(content);
      await notifier.select(currentChat.id);
    }

    await for (final updatedChat in _chatService.sendMessage(
      chatId: currentChat.id,
      content: content,
    )) {
      ref.read(selectedChatProvider.notifier).update(updatedChat);
      _scrollToBottom();
    }
    await _loadChats();
  }
}
