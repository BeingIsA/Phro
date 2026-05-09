import 'package:hive_ce/hive.dart';
import 'package:phro/infrastructures/llm_client.dart';
import 'package:phro/services/data_objects/agent.dart';
import 'package:phro/services/data_objects/chat.dart';
import 'package:phro/services/data_objects/message.dart';
import 'package:uuid/uuid.dart';

class ChatService {
  static final ChatService instance = ChatService._();
  ChatService._();

  static const String _boxName = 'chats';
  late Box<Map<dynamic, dynamic>> _box;

  final LLMClient _llmClientService = LLMClient.instance;
  Agent agent = Agent();

  // 存聊天记录就用Hive，别想着存文件了。性能差
  Future<void> initHiveBox() async {
    _box = await Hive.openBox<Map>(_boxName);
  }

  Future<List<Chat>> getAllChats() async {
    final chats = _box.values
        .map((data) => Chat.fromMap(Map<String, dynamic>.from(data)))
        .toList();
    chats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return chats;
  }

  Future<Chat> getChatById(String id) async {
    final data = _box.get(id);
    if (data == null) {
      throw Exception("ChatId $id doesn't exist");
    }
    return Chat.fromMap(Map<String, dynamic>.from(data));
  }

  Future<void> updateChatTitle(String id, String newTitle) async {
    final data = _box.get(id);
    if (data == null) return;
    final chatMap = Map<String, dynamic>.from(data);
    chatMap['title'] = newTitle.trim(); // 只更新标题
    await _box.put(id, chatMap);
  }

  Future<void> deleteChat(String id) async {
    await _box.delete(id);
  }

  Stream<List<Message>> sendMessage({
    required String chatId,
    required String content,
  }) async* {
    Chat chat = await getChatById(chatId);

    // 1. 添加用户消息
    final userMsg = Message(
      role: 'user',
      content: content,
      id: Uuid().v4(),
      reasoningContent: null,
    );
    chat.addMessage(userMsg);
    chat.addMessage(Message(role: 'assistant', content: ''));
    await _saveChat(chat);

    yield chat.messages
        .where((message) => message.role != 'system') // 前端不需要看到 system prompt
        .toList();

    String fullContent = '';
    String fullReasoningContent = '';
    List<Map<String, dynamic>> fullToolCalls = [];

    await for (final chunk in _llmClientService.sendMessageStream(
      chat.messages.map((messaage) => messaage.toMap()).toList(),
      agent.tools,
    )) {
      if (chunk['type'] == 'reasoning_content') {
        fullReasoningContent += chunk['content'];
      } else if (chunk['type'] == 'content') {
        fullContent += chunk['content'];
      } else if (chunk['type'] == 'tool_calls') {
        final list = chunk['content'];
        fullToolCalls.addAll(list.cast<Map<String, dynamic>>());
      }
      // 每次有更新就 yield 一个新的 Message 给 UI
      chat.messages.last.update(
        reasoningContent: fullReasoningContent,
        content: fullContent,
        toolCalls: fullToolCalls,
      );
    }

    await _saveChat(chat);
  }

  // 创建新对话，添加系统消息，落库
  Future<String> createChat({String? title}) async {
    final chat = Chat(title: title);
    chat.addMessage(
      Message(
        role: 'system',
        content: agent.systemPrompt,
        id: Uuid().v4(),
        reasoningContent: null,
      ),
    );
    await _saveChat(chat);
    return chat.id;
  }

  Future<void> _saveChat(Chat chat) async {
    await _box.put(chat.id, chat.toMap());
  }
}
