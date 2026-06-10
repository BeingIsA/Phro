import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phro/models/chat.dart';
import 'package:phro/services/chat_service.dart';

class ChatHistoryNotifier extends AsyncNotifier<List<Chat>?> {
  final ChatService _chatService = ChatService.instance;

  @override
  Future<List<Chat>?> build() async {
    return await _chatService.getAllChats();
  }

  /// 刷新列表（核心方法）
  Future<void> refresh() async {
    // 这两行是 Riverpod 中更新 AsyncNotifier state 的标准写法
    state = const AsyncValue.loading(); // 显示 loading 状态
    state = await AsyncValue.guard(
      // 加载新数据并更新 state
      () => ChatService.instance.getAllChats(),
    );
  }
}

final chatHistoryNotifierProvider =
    AsyncNotifierProvider<ChatHistoryNotifier, List<Chat>?>(
      () => ChatHistoryNotifier(),
    );
