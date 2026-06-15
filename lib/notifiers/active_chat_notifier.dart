import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phro/models/chat.dart';
import 'package:phro/services/chat_service.dart';

/// 管理当前激活的完整 Chat 对象
class ActiveChatNotifier extends Notifier<Chat?> {
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

  Future<void> editMessageAndContinue({
    required String messageId,
    required String newContent,
  }) async {
    final currentChat = state;
    if (currentChat == null) return;

    await for (final updatedChat in _chatService.editAndSendMessag(
      chatId: currentChat.id,
      messageId: messageId,
      newContent: newContent,
    )) {
      state = updatedChat.copy(); // 触发 UI 更新
    }
  }
}

// Provider
final activeChatNotifierProvider = NotifierProvider<ActiveChatNotifier, Chat?>(
  () => ActiveChatNotifier(),
);
