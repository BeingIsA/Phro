import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phro/models/chat.dart';
import 'package:phro/services/chat_service.dart';
import 'package:phro/notifiers/chat_history_notifier.dart';

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

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    var chat = state;

    // 情况一：还没有激活的对话 → 先创建
    if (chat == null) {
      chat = await _chatService.createChat(content);
      state = chat.copy();
      // 通知历史列表刷新（见下方“跨 Notifier 协作”说明）
      ref.read(chatHistoryNotifierProvider.notifier).refresh();
    }

    // 情况二：已有对话 → 消费 Stream，自己更新自己的 state
    await for (final updatedChat in _chatService.sendMessage(
      chatId: chat.id,
      content: content,
    )) {
      state = updatedChat.copy();
    }
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
