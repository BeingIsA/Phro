import 'package:hive_ce/hive.dart';
import 'package:phro/models/chat.dart';

class ChatRepository {
  static final ChatRepository instance = ChatRepository._();

  static const String _boxName = 'chats';

  late Box<Map<dynamic, dynamic>> _box;

  // 私有构造函数
  ChatRepository._();

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

  Future<Chat?> getChatById(String id) async {
    final data = _box.get(id);
    if (data == null) {
      return null;
    }
    return Chat.fromMap(Map<String, dynamic>.from(data));
  }

  Future<void> updateChatTitle(String id, String newTitle) async {
    final data = _box.get(id);
    if (data == null) return;
    final chatMap = Map<String, dynamic>.from(data);
    chatMap['title'] = newTitle.trim();
    await _box.put(id, chatMap);
  }

  Future<void> deleteChat(String id) async {
    await _box.delete(id);
  }

  Future<void> saveChat(Chat chat) async {
    await _box.put(chat.id, chat.toMap());
  }
}
