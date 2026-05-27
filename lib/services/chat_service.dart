import 'dart:io';

import 'package:phro/infrastructures/llm_client.dart';
import 'package:phro/repositories/chat_repository.dart';
import 'package:phro/models/agent.dart';
import 'package:phro/models/chat.dart';
import 'package:phro/models/message.dart';
import 'package:phro/services/model_config_service.dart';
import 'package:phro/services/tools/tool_service.dart';

class ChatService {
  static final ChatService instance = ChatService._();

  final ChatRepository _chatRepository;

  final LLMClient _llmClient;
  final ToolService _toolService;
  final ModelConfigService _modelConfigService;
  late Agent agent;

  // 私有构造函数，防止外部调用构造函数
  ChatService._()
    : _llmClient = LLMClient.instance, // ← 这里初始化
      _toolService = ToolService.instance,
      _modelConfigService = ModelConfigService.instance,
      _chatRepository = ChatRepository.instance,
      agent = Agent();

  ChatService.forTest({
    LLMClient? llmClient,
    ToolService? toolService,
    ModelConfigService? modelConfigService,
    ChatRepository? chatRepository,
    Agent? agent,
  }) : _llmClient = llmClient ?? LLMClient.instance,
       _toolService = toolService ?? ToolService.instance,
       _modelConfigService = modelConfigService ?? ModelConfigService.instance,
       _chatRepository = chatRepository ?? ChatRepository.instance,
       agent = agent ?? Agent();

  // 存聊天记录就用Hive，别想着存文件了。性能差
  Future<List<Chat>> getAllChats() async {
    return await _chatRepository.getAllChats();
  }

  Future<Chat> getChatById(String id) async {
    return await _chatRepository.getChatById(id);
  }

  Future<void> updateChatTitle(String id, String newTitle) async {
    await _chatRepository.updateChatTitle(id, newTitle);
  }

  Future<void> deleteChat(String id) async {
    await _chatRepository.deleteChat(id);
  }

  // 每次返回完整的消息列表
  Stream<List<Message>> sendMessage({
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
    try {
      while (true) {
        // 先搞一个空会话，前端展示空气泡
        Message assistantMessage = Message(role: 'assistant', content: '');
        chat.addMessage(assistantMessage);
        yield chat.messages.toList();
        // 存流结果用的
        String fullContent = '';
        String fullReasoningContent = '';
        final fullToolCalls = <int, Map<String, dynamic>>{};
        List<Map<String, dynamic>> fullToolCallsList = [];
        // 开始调用api，同步更新最后一条消息

        final modelConfig = await _modelConfigService.getActivatedConfig();
        if (modelConfig == null) {
          assistantMessage.update(content: '语言模型未配置，请先配置并激活');
          yield chat.messages.toList();
          break;
        }

        final messages = chat.messages
            .map((messaage) => messaage.toMap4Api())
            .toList();
        messages.removeLast();
        await for (final chunk in _llmClient.sendMessageStream(
          modelConfig!.url,
          modelConfig.apiKey,
          modelConfig.modelName,
          messages,
          agent.tools,
        )) {
          final error = chunk['error'];
          final content = chunk['content'];
          final reasoningContent = chunk['reasoning_content'];
          final toolCalls = chunk['tool_calls'];
          if (error != null) {
            assistantMessage.update(error: error as String);
            yield chat.messages.toList();
            return; // 错误时提前结束
          }
          if (content != null) {
            fullContent += content as String;
          }
          if (reasoningContent != null) {
            fullReasoningContent += reasoningContent as String;
          }
          if (toolCalls != null && toolCalls.isNotEmpty) {
            _accumulateToolCalls(toolCalls, fullToolCalls);
          }

          // 流一更新消息就要更新，前端也实时更新
          assistantMessage.update(
            content: fullContent,
            reasoningContent: fullReasoningContent,
          );
          yield chat.messages.toList();
        } // 流结束

        fullToolCallsList = [
          for (var key in fullToolCalls.keys.toList()..sort())
            fullToolCalls[key]!,
        ];
        if (fullToolCallsList.isEmpty) {
          break;
        }
        assistantMessage.update(toolCalls: fullToolCallsList);
        yield* _executeToolCalls(fullToolCallsList, chat);
      } // 循环结束
    } finally {
      await _chatRepository.saveChat(chat);
    }
  }

  // 执行tool call并更新Chat
  Stream<List<Message>> _executeToolCalls(
    List<Map<String, dynamic>> fullToolCallsList,
    Chat chat,
  ) async* {
    for (final toolJson in fullToolCallsList) {
      final functionName = toolJson['function']["name"];
      final functionArgs = toolJson['function']["arguments"];
      Message toolMessage = Message(
        role: 'tool',
        content: "正在执行工具 '$functionName'...",
        toolCallId: toolJson['id'],
        name: functionName,
        argument: functionArgs,
      );
      chat.addMessage(toolMessage);
      yield chat.messages.toList();

      final String toolResult = await _toolService.execute(
        functionName,
        functionArgs,
      );
      toolMessage.update(content: toolResult);
      yield chat.messages.toList();
    }
  }

  void _accumulateToolCalls(
    List toolCallList,
    Map<int, Map<String, dynamic>> fullToolCalls,
  ) {
    for (final toolCallChunk in toolCallList) {
      final index = toolCallChunk['index'];
      // 第一次遇到这个 index 时初始化
      if (!fullToolCalls.containsKey(index)) {
        fullToolCalls[index] = {
          "id": toolCallChunk['id'],
          "type": toolCallChunk['type'] ?? "function",
          "function": {
            "name": toolCallChunk['function']['name'] ?? "",
            "arguments": toolCallChunk['function']['arguments'],
          },
        };
      } else {
        // 累加 arguments（最关键的部分）
        final prevArgs =
            fullToolCalls[index]!["function"]["arguments"] as String;
        final newArgs = toolCallChunk['function']['arguments'];
        if (newArgs != null && newArgs.isNotEmpty) {
          fullToolCalls[index]!["function"]["arguments"] = prevArgs + newArgs;
        }
      }
    }
  }

  // 创建新对话，添加系统消息，落库
  Future<String> createChat({String? title}) async {
    final chat = Chat(title: title);
    chat.addMessage(
      Message(
        role: 'system',
        content:
            "current operating system: ${Platform.operatingSystem}\n${agent.systemPrompt}",
        reasoningContent: null,
      ),
    );
    await _chatRepository.saveChat(chat);
    return chat.id;
  }
}
