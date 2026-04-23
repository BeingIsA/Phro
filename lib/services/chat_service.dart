import 'package:hive_ce/hive.dart';
import 'package:phro/services/llm_client_service.dart';
import 'package:uuid/uuid.dart';

class Message {
  final String id;
  final String role; // "user" 或 "assistant"
  final String? reasoningContent;
  final String content;
  final DateTime createdAt;

  Message({
    String? id,
    required this.role,
    this.reasoningContent,
    required this.content,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       id = id ?? const Uuid().v4();

  Map<String, String> toJson() => {
    'id': id,
    'role': role,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Message.fromJson(Map<String, String> json) => Message(
    id: json['id'] as String,
    role: json['role'] as String,
    reasoningContent: json['reasoningContent'] as String,
    content: json['content'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

class Chat {
  final String id;
  String title;
  final DateTime createdAt;
  DateTime updatedAt;
  List<Message> messages = [];

  Chat({
    String? id,
    this.title = '新对话',
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Message>? messages,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now() {
    if (messages != null) this.messages.addAll(messages);
  }

  void addMessage(Message message) {
    messages.add(message);
    updatedAt = DateTime.now();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'messages': messages.map((m) => m.toJson()).toList(),
  };

  factory Chat.fromJson(Map<String, dynamic> json) {
    final messages =
        (json['messages'] as List<String>?)
            ?.map((e) => Message.fromJson(e as Map<String, String>))
            .toList() ??
        <Message>[];
    return Chat(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      messages: messages,
    );
  }
}

class ChatService {
  static final ChatService instance = ChatService._();
  ChatService._();

  static const String _boxName = 'chats';
  late Box<Map<dynamic, dynamic>> _box;

  final LLMClientService _llmClientService = LLMClientService.instance;

  Future<void> init() async {
    _box = await Hive.openBox<Map>(_boxName);
  }

  Future<List<Chat>> getAllChats() async {
    final chats = _box.values
        .map((data) => Chat.fromJson(Map<String, String>.from(data)))
        .toList();
    chats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return chats;
  }

  Future<Chat?> getChatById(String id) async {
    final data = _box.get(id);
    if (data == null) return null;
    return Chat.fromJson(Map<String, String>.from(data));
  }

  Future<Chat> _createChat(String id, String title) async {
    final chat = Chat(id: id, title: title);
    await _saveChat(chat);
    return chat;
  }

  Future<void> _saveChat(Chat chat) async {
    await _box.put(chat.id, chat.toJson());
  }

  Future<void> deleteChat(String id) async {
    await _box.delete(id);
  }

  Stream<String> sendMessage({
    required String chatId,
    required String content,
  }) async* {
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
        .map((m) => m.toJson())
        .toList();

    await for (final chunk in _llmClientService.sendMessageStream(
      messages,
    )) {
      fullResponse += chunk;
      yield chunk; // 实时返回给 UI
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
}
