import 'dart:io';
import 'dart:async'; // 确保引入了 async 包以使用 Completer

import 'package:phro/infrastructures/llm_client.dart';
import 'package:phro/repositories/chat_repository.dart';
import 'package:phro/models/agent.dart';
import 'package:phro/models/chat.dart';
import 'package:phro/models/message.dart';
import 'package:phro/services/agent_service.dart';
import 'package:phro/services/model_config_service.dart';
import 'package:phro/services/tools/tool_service.dart';

class ToolConfirmationResult {
  final bool approved;
  final String? reason;
  ToolConfirmationResult({required this.approved, this.reason});
}

class ChatService {
  static final ChatService instance = ChatService._();

  final ChatRepository _chatRepository;
  final LLMClient _llmClient;
  final ToolService _toolService;
  final ModelConfigService _modelConfigService;
  final AgentService _agentService;

  // 用于执行tool call时挂起等待用户确认
  final Map<String, Completer<ToolConfirmationResult>>
  _toolConfirmationCompleters = {};

  // 私有构造函数，防止外部调用构造函数
  ChatService._()
    : _llmClient = LLMClient.instance,
      _toolService = ToolService.instance,
      _modelConfigService = ModelConfigService.instance,
      _chatRepository = ChatRepository.instance,
      _agentService = AgentService.instance;

  ChatService.forTest({
    LLMClient? llmClient,
    ToolService? toolService,
    ModelConfigService? modelConfigService,
    ChatRepository? chatRepository,
    AgentService? agentService,
  }) : _llmClient = llmClient ?? LLMClient.instance,
       _toolService = toolService ?? ToolService.instance,
       _modelConfigService = modelConfigService ?? ModelConfigService.instance,
       _chatRepository = chatRepository ?? ChatRepository.instance,
       _agentService = agentService ?? AgentService.instance;

  // 提供给 UI 层调用的公开方法：用户点击“允许”或“拒绝”时通过此方法输入反馈
  void confirmToolCall(
    String toolCallId, {
    required bool approved,
    String? reason,
  }) {
    final completer = _toolConfirmationCompleters[toolCallId];
    if (completer != null && !completer.isCompleted) {
      completer.complete(
        ToolConfirmationResult(approved: approved, reason: reason),
      );
    }
  }

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

        String fullContent = '';
        String fullReasoningContent = '';
        final fullToolCalls = <int, Map<String, dynamic>>{};
        List<Map<String, dynamic>> fullToolCallsList = [];

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
          modelConfig.url,
          modelConfig.apiKey,
          modelConfig.modelName,
          messages,
          _toolService.getAllToolsInJsonSchema(),
        )) {
          final error = chunk['error'];
          final content = chunk['content'];
          final reasoningContent = chunk['reasoning_content'];
          final toolCalls = chunk['tool_calls'];
          if (error != null) {
            assistantMessage.update(error: error as String);
            yield chat.messages.toList();
            return;
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

          assistantMessage.update(
            content: fullContent,
            reasoningContent: fullReasoningContent,
          );
          yield chat.messages.toList();
        }

        fullToolCallsList = [
          for (var key in fullToolCalls.keys.toList()..sort())
            fullToolCalls[key]!,
        ];
        if (fullToolCallsList.isEmpty) {
          break;
        }
        assistantMessage.update(toolCalls: fullToolCallsList);

        // 核心修改：利用 yield* 托管带有 HITL 拦截的工具流
        yield* _executeToolCalls(fullToolCallsList, chat);
      }
    } finally {
      await _chatRepository.saveChat(chat);
    }
  }

  // 核心改造：修改 _executeToolCalls 方法
  Stream<List<Message>> _executeToolCalls(
    List<Map<String, dynamic>> fullToolCallsList,
    Chat chat,
  ) async* {
    for (final toolJson in fullToolCallsList) {
      final functionName = toolJson['function']["name"];
      final functionArgs = toolJson['function']["arguments"];
      final toolCallId = toolJson['id'];

      // 1. 动态判断当前工具是否需要用户确认
      final bool needsAuth = _toolService.requiresConfirmation(functionName);

      // 2. 初始化工具消息，如果是高危工具，初始状态设为等待确认
      Message toolMessage = Message(
        role: 'tool',
        content: needsAuth ? "等待用户授权执行该工具..." : "正在执行工具 '$functionName'...",
        toolCallId: toolCallId,
        name: functionName,
        argument: functionArgs,
        isPendingConfirmation: needsAuth,
      );
      chat.addMessage(toolMessage);
      yield chat.messages.toList();

      bool shouldExecute = true;
      String? rejectionReason;

      // 3. 只有需要确认的工具才进入 Completer 挂起逻辑
      if (needsAuth) {
        final completer = Completer<ToolConfirmationResult>();
        _toolConfirmationCompleters[toolCallId] = completer;

        // 代码在此处原地挂起，等待 UI 唤醒
        final ToolConfirmationResult result = await completer.future;
        _toolConfirmationCompleters.remove(toolCallId); // 释放内存

        // 解除拦截状态
        toolMessage.update(isPendingConfirmation: false);
        shouldExecute = result.approved;
        rejectionReason = result.reason;
      }

      // 4. 根据授权状态执行相应分支
      if (shouldExecute) {
        if (needsAuth) {
          // 如果曾被挂起，通过授权后更新一下中间执行状态
          toolMessage.update(content: "正在执行工具 '$functionName'...");
          yield chat.messages.toList();
        }

        // 真正物理执行工具代码
        final String toolResult = await _toolService.execute(
          functionName,
          functionArgs,
        );
        toolMessage.update(content: toolResult);
        yield chat.messages.toList();
      } else {
        // 用户拒绝逻辑：拼接反馈原因推送给模型
        final String reasonText =
            (rejectionReason != null && rejectionReason.trim().isNotEmpty)
            ? "：\"$rejectionReason\"。\n"
            : "。";

        toolMessage.update(
          isRejected: true,
          content: "用户拒绝了执行该工具的请求\n$reasonText",
        );
        yield chat.messages.toList();
      }
    }
  }

  void _accumulateToolCalls(
    List toolCallList,
    Map<int, Map<String, dynamic>> fullToolCalls,
  ) {
    for (final toolCallChunk in toolCallList) {
      final index = toolCallChunk['index'];
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
        final prevArgs =
            fullToolCalls[index]!["function"]["arguments"] as String;
        final newArgs = toolCallChunk['function']['arguments'];
        if (newArgs != null && newArgs.isNotEmpty) {
          fullToolCalls[index]!["function"]["arguments"] = prevArgs + newArgs;
        }
      }
    }
  }

  Future<String> createChat({String? title}) async {
    final chat = Chat(title: title);
    chat.addMessage(
      Message(
        role: 'system',
        content:
            "${await _agentService.getActivatedPrompt()}${buildOSSpecificPrompt()}",
        reasoningContent: null,
      ),
    );
    await _chatRepository.saveChat(chat);
    return chat.id;
  }

  String buildOSSpecificPrompt() {
    String prompt = '当前操作系统: ${Platform.operatingSystem}\n';
    if (Platform.isAndroid) {
      prompt += '一切路径均须以 /storage/emulated/0/开头 \n';
    }
    return prompt;
  }
}
