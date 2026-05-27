import 'package:uuid/uuid.dart';

class Message {
  // 规范：生成Message时只能自动生成id，禁止编造id
  final String id;
  final String role; // "user"、"tool" 或 "assistant"
  String content;
  String? reasoningContent;

  List? toolCalls;

  // 以下仅当role == tool时会出现
  // 工具调用ID
  String? toolCallId;
  // 已选工具名称
  String? name;
  // 工具调用的参数，
  String? argument;
  // 新增：HITL 人类在环控制状态
  bool isPendingConfirmation;
  bool isRejected;

  String? error;
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
    this.isPendingConfirmation = false,
    this.isRejected = false,
  }) : id = const Uuid().v4(),
       createdAt = DateTime.now();

  /// 从数据库/存储加载时使用的构造函数
  Message.fromMap(Map<String, dynamic> json)
    : id = json['id'] as String,
      role = json['role'] as String,
      content = json['content'] as String,
      reasoningContent = json['reasoning_content'],
      toolCalls = json['tool_calls'],
      toolCallId = json['tool_call_id'],
      name = json['name'],
      argument = json['argument'],
      error = json['error'],
      isPendingConfirmation = json['is_pending_confirmation'] as bool? ?? false,
      isRejected = json['is_rejected'] as bool? ?? false,
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
      'is_pending_confirmation': isPendingConfirmation,
      'is_rejected': isRejected,
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
    map.remove('is_pending_confirmation');
    map.remove('is_rejected');
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
    List? toolCalls,
    String? error,
    bool? isPendingConfirmation,
    bool? isRejected,
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

    if (isPendingConfirmation != null) {
      this.isPendingConfirmation = isPendingConfirmation;
    }

    if (isRejected != null) {
      this.isRejected = isRejected;
    }
  }
}
