import 'package:flutter/material.dart';
import 'package:phro/pages/message_input.dart';
import 'package:phro/pages/settings/settings_page.dart';
import 'package:phro/services/chat_service.dart';
import 'package:uuid/uuid.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  final ChatService _chatService = ChatService.instance;
  final ScrollController _scrollController = ScrollController();

  String _currentChatId = Uuid().v4();
  List<Message> _messages = [];


  //  TODO 历史记录查询和展示功能

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

  Widget _buildMessageBubble(Message message) {
    final bool isUser = message.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
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
        child: Text(
          message.content,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Future<void> _handleSendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // 1. 立即显示用户气泡
    final userMessage = Message(role: 'user', content: content);
    setState(() {
      _messages.add(userMessage);
    });
    _scrollToBottom();

    // 2. 立即显示助手占位气泡
    setState(() {
      _messages.add(Message(role: 'assistant', content: ''));
    });
    _scrollToBottom();

    // 3. 调用服务流式输出并实时更新助手气泡
    String fullResponse = '';

    await for (final chunk in _chatService.sendMessage(
      chatId: _currentChatId,
      content: content,
    )) {
      fullResponse += chunk;
      setState(() {
        _messages[_messages.length - 1] = Message(
          role: 'assistant',
          content: fullResponse,
        );
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.sizeOf(context).shortestSide < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phro'), // 可自定义标题
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Phro',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('设置'),
              onTap: () {
                if (isSmallScreen) {
                  // 手机：跳转新页面
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      // 保留 route settings（重要）
                      transitionDuration: Duration.zero, // 正向切换无动画
                      reverseTransitionDuration: Duration.zero, // 返回时也无动画
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const SettingsPage(),
                    ),
                  );
                } else {
                  // 平板/大屏：弹出对话框
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return Dialog(
                        backgroundColor: Theme.of(
                          context,
                        ).scaffoldBackgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 560, // 控制弹窗最大宽度
                            maxHeight: 680, // 可选，根据内容调整或去掉
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: SettingsPage(),
                          ), // 直接复用
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text(
                      '开始新的对话吧！',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageBubble(_messages[index]);
                    },
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
}
