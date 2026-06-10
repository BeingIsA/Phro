import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phro/models/chat.dart';
import 'package:phro/services/chat_service.dart';

/// 管理当前激活的完整 Agent 对象
class SelectedChatNotifier extends Notifier<Chat?> {
  final ChatService _chatService = ChatService.instance;

  @override
  Chat? build() {
    return null;
  }

  /// 激活某个 Agent
  Future<void> select(String id) async {
    state = await _chatService.getChatById(id);
  }

  void clear() {
    state = null;
  }

  void update(Chat chat) {
    // 必须创建新对象不然不会触发rebuild
    state = chat.copy();
  }
}

// Provider
final selectedChatNotifierProvider =
    NotifierProvider<SelectedChatNotifier, Chat?>(() => SelectedChatNotifier());
