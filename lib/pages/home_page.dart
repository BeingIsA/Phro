import 'package:flutter/material.dart';
import 'package:phro/pages/message_input.dart';
import 'package:phro/pages/settings/settings_page.dart';
import 'package:phro/services/chat_service.dart';
import 'package:phro/services/data_objects/chat.dart';
import 'package:phro/services/data_objects/message.dart';
import 'package:uuid/uuid.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ChatService _chatService = ChatService.instance;
  final ScrollController _scrollController = ScrollController();

  String _currentChatId = Uuid().v4();
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
      drawer: Drawer(
        child: Column(
          // 关键修复：让所有子组件横向拉满（DrawerHeader 蓝色背景不再有白边）
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 顶部固定 Header（蓝色背景现在会完全横向拉满）
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Phro',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),

            // 顶部固定 - 新对话按钮
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('新对话'),
              onTap: () {
                _startNewChat();
                Navigator.pop(context);
              },
            ),

            const Divider(height: 1),

            // 中间可滚动区域 - 历史对话列表
            Expanded(
              child: _allChats.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          '暂无历史对话',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _allChats.length,
                      itemBuilder: (context, index) {
                        final chat = _allChats[index];
                        return ListTile(
                          leading: const Icon(Icons.chat_bubble_outline),
                          title: Text(
                            chat.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          selected: chat.id == _currentChatId,
                          onTap: () {
                            _selectChat(chat.id);
                            Navigator.pop(context);
                          },
                          trailing: PopupMenuButton<String>(
                            tooltip: '更多操作',
                            icon: const Icon(Icons.more_vert, size: 20),
                            itemBuilder: (BuildContext context) => [
                              const PopupMenuItem<String>(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 20),
                                    SizedBox(width: 8),
                                    Text('编辑'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem<String>(
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
                            onSelected: (String value) async {
                              if (value == 'edit') {
                                final newTitle = await _showEditDialog(
                                  chat.title,
                                );
                                if (newTitle != null &&
                                    newTitle.trim().isNotEmpty &&
                                    newTitle != chat.title) {
                                  await _chatService.updateChatTitle(
                                    chat.id,
                                    newTitle,
                                  );
                                  await _loadChats();
                                }
                              } else if (value == 'delete') {
                                final confirm = await _showDeleteConfirmDialog(
                                  chat.title,
                                );
                                if (confirm == true) {
                                  await _chatService.deleteChat(chat.id);
                                  await _loadChats();
                                  if (chat.id == _currentChatId && mounted) {
                                    _startNewChat();
                                  }
                                }
                              }
                            },
                          ),
                        );
                      },
                    ),
            ),

            // 底部固定 - 设置按钮
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: _openSettings,
                    tooltip: '设置',
                    icon: const Icon(Icons.settings_outlined, size: 28),
                  ),
                ],
              ),
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

  // 从后台重新加载对话
  Future<void> _loadChats() async {
    final chats = await _chatService.getAllChats();

    if (mounted) {
      setState(() {
        _allChats = chats;
      });
    }
  }

  void _startNewChat() {
    setState(() {
      _currentChatId = Uuid().v4();
      _messages = [];
    });
    _scrollToBottom();
  }

  Future<void> _selectChat(String chatId) async {
    if (chatId == _currentChatId) return;
    final chat = await _chatService.getChatById(chatId);
    if (chat != null && mounted) {
      setState(() {
        _currentChatId = chatId;
        _messages = List.from(chat.messages);
      });
      _scrollToBottom();
    }
  }

  void _openSettings() {
    final bool isSmallScreen = MediaQuery.sizeOf(context).shortestSide < 600;

    if (isSmallScreen) {
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          pageBuilder: (context, animation, secondaryAnimation) =>
              const SettingsPage(),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return Dialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560, maxHeight: 680),
              child: const Padding(
                padding: EdgeInsets.all(24),
                child: SettingsPage(),
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildMessageBubble(Message message) {
    final bool isUser = message.role == 'user';
    final bool hasReasoning =
        message.reasoningContent != null &&
        message.reasoningContent!.trim().isNotEmpty;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (hasReasoning)
            Padding(
              padding: const EdgeInsets.only(
                left: 12.0,
                right: 12.0,
                bottom: 4.0,
              ),
              child: ExpansionTile(
                initiallyExpanded: false, // 默认收起
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
                collapsedBackgroundColor: Colors.transparent,
                backgroundColor: Colors.transparent,
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
            ),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
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
              message.content,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final userMessage = Message(role: 'user', content: content);
    setState(() {
      _messages.add(userMessage);
    });
    _scrollToBottom();

    setState(() {
      _messages.add(Message(role: 'assistant', content: ''));
    });
    _scrollToBottom();

    String fullContent = '';
    String fullReasoningContent = '';

    await for (final chunk in _chatService.sendMessage(
      chatId: _currentChatId,
      content: content,
    )) {
      String chunkContent = chunk['content']!;
      if (chunk['type'] == 'reasoningContent') {
        fullReasoningContent += chunkContent;
      } else if (chunk['type'] == 'content') {
        fullContent += chunkContent;
      }
      setState(() {
        _messages[_messages.length - 1] = Message(
          role: 'assistant',
          content: fullContent,
          reasoningContent: fullReasoningContent,
        );
      });
      _scrollToBottom();
    }

    await _loadChats();
  }

  /// 新增：编辑标题弹窗
  Future<String?> _showEditDialog(String currentTitle) async {
    final TextEditingController controller = TextEditingController(
      text: currentTitle,
    );
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

  Future<bool?> _showDeleteConfirmDialog(String title) async {
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
}
