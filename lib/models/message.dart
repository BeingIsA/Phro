import 'package:uuid/uuid.dart';

class Message {
  // 规范：生成Message时只能自动生成id，禁止编造id
  final String id;
  final String role; // "user"、"tool" 或 "assistant"
  String content;
  String? reasoningContent;

  List<Map<String, dynamic>>? toolCalls;

  // 以下仅当role == tool时会出现，表示工具调用的结果
  // 工具调用ID
  String? toolCallId;
  // 已选工具名称
  String? name;
  // 工具调用的参数，
  String? argument;
  // HITL 人类在环控制状态
  ToolCallStatus? toolCallStatus;

  String? error;

  List<Message>? subAgentMessages;

  final DateTime createdAt;

  Message({
    required this.role,
    required this.content,
    this.reasoningContent,
    this.toolCalls,
    this.toolCallId,
    this.name,
    this.argument,
    this.error,
    this.toolCallStatus,
    this.subAgentMessages,
  }) : id = const Uuid().v4(),
       createdAt = DateTime.now();

  /// 从数据库/存储加载时使用的构造函数
  Message.fromMap(Map<String, dynamic> json)
    : id = json['id'] as String,
      role = json['role'] as String,
      content = json['content'] as String,
      reasoningContent = json['reasoning_content'],
      toolCalls = (json['tool_calls'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      toolCallId = json['tool_call_id'],
      name = json['name'],
      argument = json['argument'],
      error = json['error'],
      toolCallStatus = _parseToolCallStatus(json),
      subAgentMessages = (json['sub_agent_messages'] as List<dynamic>?)
          ?.map((e) => Message.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      createdAt = DateTime.parse(json['created_at'] as String);

  // 用来存储本地
  Map<String, dynamic> toMap4Storage() {
    final map = <String, dynamic>{
      'id': id,
      'role': role,
      'content': content,
      'reasoning_content': reasoningContent?.trim() ?? '',
      'tool_calls': toolCalls,
      'tool_call_id': toolCallId,
      'name': name,
      'argument': argument,
      'error': error,
      'tool_call_status': toolCallStatus?.name,
      if (subAgentMessages != null && subAgentMessages!.isNotEmpty)
        'sub_agent_messages': subAgentMessages!
            .map((m) => m.toMap4Storage())
            .toList(),
      'created_at': createdAt.toIso8601String(),
    };
    return map;
  }

  // 用来调用API
  Map<String, dynamic> toMap4Api() {
    final map = toMap4Storage();
    map.remove('reasoning_content');
    map.remove('error');
    map.remove('created_at');
    map.remove('tool_call_status');
    map.remove('subAgentMessages');
    // 空的键值对全删了防止报错
    map.removeWhere((key, value) {
      if (value == null) return true;
      if (value.isEmpty) return true;
      return false;
    });

    return map;
  }

  // api返回流式结果拼接用的
  void update({
    String? reasoningContent,
    String? content,
    List<Map<String, dynamic>>? toolCalls,
    String? error,
    ToolCallStatus? toolCallStatus,
    List<Message>? subAgentMessages,
    String? toolCallId,
    String? name,
    String? argument,
  }) {
    if (reasoningContent != null && reasoningContent.isNotEmpty) {
      this.reasoningContent = reasoningContent;
    }

    if (content != null && content.isNotEmpty) {
      this.content = content;
    }

    if (error != null && error.isNotEmpty) {
      this.error = error;
    }

    // List 类型：null 或空列表都不更新
    if (toolCalls != null && toolCalls.isNotEmpty) {
      this.toolCalls = toolCalls;
    }

    if (toolCallStatus != null) {
      this.toolCallStatus = toolCallStatus;
    }
    if (subAgentMessages != null) {
      this.subAgentMessages = subAgentMessages;
    }
    if (toolCallId != null) {
      this.toolCallId = toolCallId;
    }
    if (name != null) {
      this.name = name;
    }
    if (argument != null) {
      this.argument = argument;
    }
  }

  static ToolCallStatus? _parseToolCallStatus(Map<String, dynamic> json) {
    if (json['tool_call_status'] != null) {
      return ToolCallStatus.values.byName(json['tool_call_status'] as String);
    }

    return null;
  }
}

enum ToolCallStatus {
  executing,
  finished,
  canceled,
  rejected,
  pendingConformation,
}
