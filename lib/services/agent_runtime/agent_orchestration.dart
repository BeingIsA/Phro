import 'dart:async';
import 'dart:convert';
import 'package:phro/infrastructures/llm_client.dart';
import 'package:phro/models/message.dart';
import 'package:phro/services/model_config_service.dart';
import 'package:phro/services/tool/tool_service.dart';

class ToolConfirmationResult {
  final ToolCallStatus toolCallStatus;
  final String? reason;
  ToolConfirmationResult({required this.toolCallStatus, this.reason});
}

class AgentOrchestration {
  static final AgentOrchestration instance = AgentOrchestration._();
  final ModelConfigService _modelConfigService;
  final LLMClient _llmClient;
  final ToolService _toolService;

  AgentOrchestration._()
    : _modelConfigService = ModelConfigService.instance,
      _llmClient = LLMClient.instance,
      _toolService = ToolService.instance;

  // 用于执行tool call时挂起等待用户确认
  final Map<String, Completer<ToolConfirmationResult>>
  _toolConfirmationCompleters = {};
  StreamIterator<Map<String, dynamic>>? _activeGeneration;

  Stream<List<Message>> run({
    required List<Message> mutableMessages,
    required int depth,
    List<Map<String, dynamic>>? tools,
  }) async* {
    while (true) {
      Message assistantMessage = Message(role: 'assistant', content: "");
      mutableMessages.add(assistantMessage);
      await for (final _ in streamAssistantResponse(
        mutableMessage: assistantMessage,
        messages: mutableMessages
            .map((message) => message.toMap4Api())
            .toList(),
        tools: tools,
      )) {
        yield mutableMessages;
      }
      // 如果没有tool_call说明该结束了

      if (assistantMessage.toolCalls == null ||
          assistantMessage.toolCalls!.isEmpty) {
        break;
      }

      for (final toolJson in assistantMessage.toolCalls!) {
        Message toolMessage = Message(role: 'tool', content: "");
        mutableMessages.add(toolMessage);
        await for (final _ in _executeToolCall(toolMessage, toolJson, depth)) {
          yield mutableMessages;
        }
      }
    }
  }

  // 处理模型单次回复内容
  Stream<Message> streamAssistantResponse({
    required Message mutableMessage,
    required List<Map<String, dynamic>> messages,
    List<Map<String, dynamic>>? tools,
  }) async* {
    String fullContent = '';
    String fullReasoningContent = '';
    final fullToolCalls = <int, Map<String, dynamic>>{};
    List<Map<String, dynamic>> fullToolCallsList = [];

    final modelConfig = await _modelConfigService.getActivatedConfig();
    if (modelConfig == null) {
      mutableMessage.update(content: '语言模型未配置，请先配置并激活');
      yield mutableMessage;
      return;
    }

    final iterator = StreamIterator<Map<String, dynamic>>(
      _llmClient.sendMessageStream(
        modelConfig.url,
        modelConfig.apiKey,
        modelConfig.modelName,
        messages,
        tools,
      ),
    );
    _activeGeneration = iterator;
    while (await iterator.moveNext()) {
      final chunk = iterator.current;
      final error = chunk['error'];
      final content = chunk['content'];
      final reasoningContent = chunk['reasoning_content'];
      final toolCalls = chunk['tool_calls'];
      if (error != null) {
        mutableMessage.update(error: error as String);
        yield mutableMessage;
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

      mutableMessage.update(
        content: fullContent,
        reasoningContent: fullReasoningContent,
      );
      yield mutableMessage;
    }

    fullToolCallsList = [
      for (var key in fullToolCalls.keys.toList()..sort()) fullToolCalls[key]!,
    ];

    mutableMessage.update(toolCalls: fullToolCallsList);
    yield mutableMessage;
  }

  Stream<Message> _executeToolCall(
    Message mutableMessage,
    Map<String, dynamic> toolJson,
    int depth,
  ) async* {
    final toolCallId = toolJson['id'];
    final functionName = toolJson['function']["name"];
    final argString = toolJson['function']["arguments"];

    // 1. 动态判断当前工具是否需要用户确认
    final bool needsAuth = _toolService.requiresConfirmation(functionName);

    // 2. 初始化工具消息，如果是高危工具，初始状态设为等待确认
    mutableMessage.update(
      toolCallId: toolCallId,
      name: functionName,
      argument: argString,
      toolCallStatus: needsAuth
          ? ToolCallStatus.pendingConformation
          : ToolCallStatus.executing,
    );
    yield mutableMessage;

    ToolCallStatus toolCallStatus = ToolCallStatus.executing;
    String? rejectionReason;

    // 将需要确认的工具挂起
    if (needsAuth) {
      final completer = Completer<ToolConfirmationResult>();
      _toolConfirmationCompleters[toolCallId] = completer;

      // 代码在此处原地挂起，等待 UI 唤醒
      final ToolConfirmationResult result = await completer.future;
      _toolConfirmationCompleters.remove(toolCallId); // 释放内存

      toolCallStatus = result.toolCallStatus;
      rejectionReason = result.reason;
    }

    // 拒绝了就不执行直接返回
    if (needsAuth && toolCallStatus != ToolCallStatus.executing) {
      mutableMessage.update(
        toolCallStatus: toolCallStatus,
        content: rejectionReason,
      );
      yield mutableMessage;
      return;
    }
    // 如果同意，先修改状态为executing
    if (needsAuth && toolCallStatus == ToolCallStatus.executing) {
      mutableMessage.update(toolCallStatus: ToolCallStatus.executing);
      yield mutableMessage;
    }
    // 开始执行工具
    final functionArgs = jsonDecode(argString);
    if (functionName == "delegate") {
      if (depth >= 2) {
        mutableMessage.update(
          toolCallStatus: ToolCallStatus.rejected,
          content: 'sub agent reached the maximum depth 2',
        );
      } else {
        List<String> toolNames = List<String>.from(functionArgs['tools'] ?? []);
        List<Message> subAgentMessages = [
          Message(role: 'system', content: functionArgs['system_prompt']),
          Message(role: 'user', content: functionArgs['user_input']),
        ];
        mutableMessage.update(subAgentMessages: subAgentMessages);
        await for (final _ in run(
          mutableMessages: subAgentMessages,
          depth: depth + 1,
          tools: _toolService.getToolJsonSchemasByNameList(toolNames),
        )) {
          yield mutableMessage;
        }
        mutableMessage.update(content: subAgentMessages.last.content);
      }
    } else {
      final String toolResult = await _toolService.execute(
        functionName,
        functionArgs,
      );
      mutableMessage.update(content: toolResult);
    }
    // 工具执行完毕了
    mutableMessage.update(toolCallStatus: ToolCallStatus.finished);
    yield mutableMessage;
  }

  // 用来拼接LLM生成的tool call信息
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

  Future<void> cancelGeneration() async {
    if (_activeGeneration == null) return;
    _activeGeneration!.cancel();
    _activeGeneration = null;
    for (final completer in _toolConfirmationCompleters.values) {
      if (!completer.isCompleted) {
        completer.complete(
          ToolConfirmationResult(toolCallStatus: ToolCallStatus.canceled),
        );
      }
    }
  }

  // 提供给 UI 层调用的公开方法：用户点击“允许”或“拒绝”时通过此方法输入反馈
  void confirmToolCall(
    String toolCallId, {
    required bool approved,
    String? reason,
  }) {
    final completer = _toolConfirmationCompleters[toolCallId];
    if (completer != null && !completer.isCompleted) {
      completer.complete(
        ToolConfirmationResult(
          toolCallStatus: approved
              ? ToolCallStatus.executing
              : ToolCallStatus.rejected,
          reason: reason,
        ),
      );
    }
  }
}
