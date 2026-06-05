import 'package:flutter/material.dart';
import 'package:phro/pages/message_input.dart';
import 'package:phro/pages/sidebar/settings/settings_page.dart';
import 'package:phro/services/chat_service.dart';
import 'package:phro/models/chat.dart';
import 'package:phro/models/message.dart';

import 'sidebar/app_drawer.dart';
import 'chat/message_list_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ChatService _chatService = ChatService.instance;
  final ScrollController _scrollController = ScrollController();

  String? _currentChatId;
  List<Message> _messages = [];
  List<Chat> _allChats = [];

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phro')),
      // 声明式使用重构后的抽屉
      drawer: AppDrawer(
        allChats: _allChats,
        currentChatId: _currentChatId,
        onChatSelected: _selectChat,
        onNewChat: _startNewChat,
        onRefreshChats: _loadChats,
      ),
      body: Column(
        children: [
          // 声明式使用重构后的消息列表
          Expanded(
            child: MessageListView(
              messages: _messages,
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

  void _startNewChat() {
    setState(() {
      _currentChatId = null;
      _messages = [];
    });
    _scrollToBottom();
  }

  Future<void> _selectChat(String chatId) async {
    if (chatId == _currentChatId) return;
    final chat = await _chatService.getChatById(chatId);

    setState(() {
      _currentChatId = chatId;
      _messages = chat.messages.where((m) => m.role != 'system').toList();
    });
    _scrollToBottom();
  }

  Future<void> _handleSendMessage(String content) async {
    if (content.trim().isEmpty) return;
    _currentChatId ??= await _chatService.createChat();

    _scrollToBottom();
    setState(() {
      _messages.add(Message(role: 'assistant', content: ''));
    });
    _scrollToBottom();

    await for (final currentMessages in _chatService.sendMessage(
      chatId: _currentChatId!,
      content: content,
    )) {
      setState(() {
        _messages = currentMessages.where((m) => m.role != 'system').toList();
      });
      _scrollToBottom();
    }
    await _loadChats();
  }
}
