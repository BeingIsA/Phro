import 'package:uuid/uuid.dart';

class Message {
  final String id;
  final String role; // "user" 或 "assistant"
  final String? reasoningContent;
  final String content;
  final List? toolCalls;
  final DateTime createdAt;

  Message({
    String? id,
    required this.role,
    this.reasoningContent,
    required this.content,
    DateTime? createdAt,
    this.toolCalls,
  }) : createdAt = createdAt ?? DateTime.now(),
       id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() => {
    'id': id,
    'role': role,
    'content': content,
    'reasoning_content': reasoningContent?.trim() ?? '',
    'tool_calls': toolCalls,
    'created_at': createdAt.toIso8601String(),
  };

  // TODO tool_calls是否能正常存取
  factory Message.fromMap(Map<String, dynamic> json) => Message(
    id: json['id'] as String,
    role: json['role'] as String,
    reasoningContent: json['reasoning_content'],
    content: json['content'] as String,
    toolCalls: json['tool_calls'],
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : DateTime.now(),
  );
}
