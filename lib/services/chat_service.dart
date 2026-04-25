import 'package:hive_ce/hive.dart';
import 'package:phro/infrastructures/llm_client.dart';
import 'package:phro/services/data_objects/chat.dart';
import 'package:phro/services/data_objects/message.dart';
import 'package:uuid/uuid.dart';

class ChatService {
  static final ChatService instance = ChatService._();
  ChatService._();

  static const String _boxName = 'chats';
  late Box<Map<dynamic, dynamic>> _box;

  final LLMClient _llmClientService = LLMClient.instance;

  Future<void> init() async {
    _box = await Hive.openBox<Map>(_boxName);
  }

  Future<List<Chat>> getAllChats() async {
    final chats = _box.values
        .map((data) => Chat.fromMap(Map<String, dynamic>.from(data)))
        .toList();
    chats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return chats;
  }

  Future<Chat?> getChatById(String id) async {
    final data = _box.get(id);
    if (data == null) return null;
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

  Stream<String> sendMessage({
    required String chatId,
    required String content,
  }) async* {
    // 先查，有就编辑没有则创建
    Chat? chat = await getChatById(chatId);
    if (chat == null) {
      chat = await _createChat(chatId, '新对话');
      await _saveChat(chat);
    }

    // 1. 添加用户消息
    final userMsg = Message(
      role: 'user',
      content: content,
      id: Uuid().v4(),
      reasoningContent: null,
    );
    chat.addMessage(userMsg);
    await _saveChat(chat);

    String fullResponse = '';

    final List<Map<String, String>> messages = chat.messages
        .map((m) => m.toMap())
        .toList();

    await for (final chunk in _llmClientService.sendMessageStream(messages)) {
      content = chunk['content']!;
      fullResponse += content;
      yield content; // 实时返回给 UI
    }
    chat.addMessage(
      Message(
        role: 'assistant',
        content: fullResponse,
        id: Uuid().v4(),
        reasoningContent: null, // TODO: 添加推理内容
      ),
    );

    await _saveChat(chat);
  }

  Future<Chat> _createChat(String id, String title) async {
    final chat = Chat(id: id, title: title);
    await _saveChat(chat);
    return chat;
  }

  Future<void> _saveChat(Chat chat) async {
    await _box.put(chat.id, chat.toMap());
  }
}
