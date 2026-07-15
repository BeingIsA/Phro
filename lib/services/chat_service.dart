import 'dart:io';
import 'dart:async';
import 'package:phro/infrastructures/llm_client.dart';
import 'package:phro/repositories/chat_repository.dart';
import 'package:phro/models/chat.dart';
import 'package:phro/models/message.dart';
import 'package:phro/services/agent_runtime/cancel_token.dart';
import 'package:phro/services/agent_runtime/agent_orchestration.dart';
import 'package:phro/services/agent_service.dart';
import 'package:phro/services/model_config_service.dart';
import 'package:phro/services/tool/tool_service.dart';

class ChatService {
  static final ChatService instance = ChatService._();
  static final kGenerationCanceledFlag = 'generation_calceled_by_user';
  final ChatRepository _chatRepository;
  final ToolService _toolService;
  final AgentService _agentService;
  final AgentOrchestration _agentOrchestration;
  CancenToken? _agentContext;

  // 私有构造函数，防止外部调用构造函数
  ChatService._()
    : _toolService = ToolService.instance,
      _chatRepository = ChatRepository.instance,
      _agentService = AgentService.instance,
      _agentOrchestration = AgentOrchestration.instance;

  ChatService.forTest({
    LLMClient? llmClient,
    ToolService? toolService,
    ModelConfigService? modelConfigService,
    ChatRepository? chatRepository,
    AgentService? agentService,
    AgentOrchestration? agentOrchestration,
  }) : _toolService = toolService ?? ToolService.instance,
       _chatRepository = chatRepository ?? ChatRepository.instance,
       _agentService = agentService ?? AgentService.instance,
       _agentOrchestration = agentOrchestration ?? AgentOrchestration.instance;

  Future<List<Chat>> getAllChats() async {
    return await _chatRepository.getAllChats();
  }

  Future<Chat> getChatById(String id) async {
    Chat? chat = await _chatRepository.getChatById(id);
    if (chat == null) {
      throw Exception("ChatId $id doesn't exist");
    }
    return chat;
  }

  Future<void> updateChatTitle(String id, String newTitle) async {
    await _chatRepository.updateChatTitle(id, newTitle);
  }

  Future<void> deleteChat(String id) async {
    await _chatRepository.deleteChat(id);
  }

  Stream<Chat> sendMessage({
    required String chatId,
    required String content,
  }) async* {
    Chat chat = await getChatById(chatId);

    // 1. 添加用户消息
    final userMsg = Message(
      role: 'user',
      content: content,
      reasoningContent: null,
    );
    chat.addMessage(userMsg);
    yield* _continueGeneration(chat);
  }

  Stream<Chat> _continueGeneration(Chat chat) async* {
    try {
      chat.isGenerating = true;
      int messageNum = chat.messages.length;
      _agentContext = CancenToken();
      await for (final _ in _agentOrchestration.run(
        cancelToken: _agentContext!,
        mutableMessages: chat.messages,
        depth: 0,
        tools: _toolService.getAllToolsInJsonSchema(),
      )) {
        if (chat.messages.length > messageNum) {
          await _chatRepository.saveChat(chat);
          messageNum = chat.messages.length;
        }
        yield chat;
      }
    } finally {
      chat.isGenerating = false;
      yield chat;
      await _chatRepository.saveChat(chat);
    }
  }

  Future<void> cancelGeneration() async {
    _agentContext?.cancel();
    _agentOrchestration.cancelAllPendingTools();
  }

  Stream<Chat> editAndSendMessage({
    required String chatId,
    required String messageId, // 要编辑的消息 ID
    required String newContent,
  }) async* {
    Chat chat = await getChatById(chatId);

    // 1. 找到要编辑的消息并校验
    final messageIndex = chat.messages.indexWhere((m) => m.id == messageId);
    if (messageIndex == -1) {
      return;
    }

    final targetMessage = chat.messages[messageIndex];
    if (targetMessage.role != 'user') {
      // 目前只允许编辑 user 消息
      return;
    }

    // 2. 更新消息内容
    targetMessage.update(content: newContent);

    // 3. 截断消息至当前位置
    if (messageIndex + 1 < chat.messages.length) {
      chat.messages.removeRange(messageIndex + 1, chat.messages.length);
    }

    // 4. 保存一次（防止中途崩溃）
    await _chatRepository.saveChat(chat);
    yield chat; // 前端立即看到修改后的状态

    // 5. 继续走原有的生成流程（复用代码！）
    yield* _continueGeneration(chat);
  }

  // TODO 也是透传
  void confirmToolCall(
    String toolCallId, {
    required bool approved,
    String? reason,
  }) {
    _agentOrchestration.confirmToolCall(
      toolCallId,
      approved: approved,
      reason: reason,
    );
  }

  Future<Chat> createChat(String? title) async {
    final activatedAgentName = _agentService.getActivatedName();
    final chat = Chat(title: title, agentName: activatedAgentName);
    chat.addMessage(
      Message(
        role: 'system',
        content:
            "${await _agentService.getActivatedPrompt()}${buildOSSpecificPrompt()}",
        reasoningContent: null,
      ),
    );
    await _chatRepository.saveChat(chat);
    return chat;
  }

  String buildOSSpecificPrompt() {
    String prompt = '当前操作系统: ${Platform.operatingSystem}\n';
    if (Platform.isAndroid) {
      prompt += '一切路径均须以 /storage/emulated/0/开头 \n';
    }
    return prompt;
  }
}
