import 'dart:async';
import 'dart:convert';
import 'package:phro/infrastructures/llm_client.dart';
import 'package:phro/models/message.dart';
import 'package:phro/services/agent_runtime/agent_context.dart';
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

  Stream<AgentContext> run({
    required AgentContext context,
    List<Map<String, dynamic>>? tools,
  }) async* {
    List<Message> messages = context.messages;
    while (true) {
      messages.add(Message(role: 'assistant', content: ""));
      await for (final updatedMessage in streamAssistantResponse(
        messages: messages.map((message) => message.toMap4Api()).toList(),
        tools: tools,
      )) {
        messages[messages.length - 1] = updatedMessage;
        yield context;
      }
      // 如果没有tool_call说明该结束了
      final assistantMessage = messages.last;
      if (assistantMessage.toolCalls == null ||
          assistantMessage.toolCalls!.isEmpty) {
        context.update(result: assistantMessage.content);
        break;
      }
      await for (final _ in _executeToolCalls(
        assistantMessage.toolCalls!,
        context,
      )) {
        yield context;
      }
    }
  }

  // 处理模型单次回复内容
  Stream<Message> streamAssistantResponse({
    required List<Map<String, dynamic>> messages,
    List<Map<String, dynamic>>? tools,
  }) async* {
    Message assistantMessage = Message(role: 'assistant', content: '');

    String fullContent = '';
    String fullReasoningContent = '';
    final fullToolCalls = <int, Map<String, dynamic>>{};
    List<Map<String, dynamic>> fullToolCallsList = [];

    final modelConfig = await _modelConfigService.getActivatedConfig();
    if (modelConfig == null) {
      assistantMessage.update(content: '语言模型未配置，请先配置并激活');
      yield assistantMessage;
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
        assistantMessage.update(error: error as String);
        yield assistantMessage;
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
      yield assistantMessage;
    }

    fullToolCallsList = [
      for (var key in fullToolCalls.keys.toList()..sort()) fullToolCalls[key]!,
    ];

    assistantMessage.update(toolCalls: fullToolCallsList);
    yield assistantMessage;
  }

  Stream<AgentContext> _executeToolCalls(
    List<Map<String, dynamic>> fullToolCallsList,
    AgentContext context,
  ) async* {
    for (final toolJson in fullToolCallsList) {
      final functionName = toolJson['function']["name"];
      final argString = toolJson['function']["arguments"];
      final toolCallId = toolJson['id'];

      // 1. 动态判断当前工具是否需要用户确认
      final bool needsAuth = _toolService.requiresConfirmation(functionName);

      // 2. 初始化工具消息，如果是高危工具，初始状态设为等待确认
      Message toolMessage = Message(
        role: 'tool',
        content: "",
        toolCallId: toolCallId,
        name: functionName,
        argument: argString,
        toolCallStatus: needsAuth
            ? ToolCallStatus.pendingConformation
            : ToolCallStatus.executing,
      );
      context.messages.add(toolMessage);
      yield context;

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
        toolMessage.update(
          toolCallStatus: toolCallStatus,
          content: rejectionReason,
        );
        yield context;
        continue;
      }
      // 如果同意，先修改状态为executing
      if (needsAuth && toolCallStatus == ToolCallStatus.executing) {
        toolMessage.update(toolCallStatus: ToolCallStatus.executing);
        yield context;
      }
      // 开始执行工具
      final functionArgs = jsonDecode(argString);
      if (functionName == "delegate") {
        if (context.depth >= 2) {
          toolMessage.update(
            toolCallStatus: ToolCallStatus.rejected,
            content: 'sub agent reached the maximum depth 2',
          );
        } else {
          final toolsRaw = functionArgs['tools'];
          final List<Map<String, dynamic>>? tools = toolsRaw is List
              ? toolsRaw
                    .whereType<Map>()
                    .map((item) => Map<String, dynamic>.from(item))
                    .toList()
              : null;
          AgentContext subAgentContext = AgentContext(context.depth + 1, [
            Message(role: 'system', content: functionArgs['system_prompt']),
            Message(role: 'user', content: functionArgs['user_input']),
          ], parentToolCallId: toolCallId);
          await run(context: subAgentContext, tools: tools).drain();
          toolMessage.update(content: subAgentContext.result);
        }
      } else {
        final String toolResult = await _toolService.execute(
          functionName,
          functionArgs,
        );
        toolMessage.update(content: toolResult);
      }
      // 工具执行完毕了
      toolMessage.update(toolCallStatus: ToolCallStatus.finished);
      yield context;
    }
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
