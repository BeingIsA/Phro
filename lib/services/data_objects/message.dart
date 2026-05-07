import 'package:uuid/uuid.dart';


class Message {
  final String id;
  final String role; // "user" 或 "assistant"
  final String? reasoningContent;
  final String content;
  final DateTime createdAt;

  Message({
    String? id,
    required this.role,
    this.reasoningContent,
    required this.content,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       id = id ?? const Uuid().v4();

  Map<String, String> toMap() => {
    'id': id,
    'role': role,
    'content': content,
    'reasoningContent': reasoningContent?.trim() ?? '',
    'createdAt': createdAt.toIso8601String(),
  };

  factory Message.fromMap(Map<String, dynamic> json) => Message(
    id: json['id'] as String,
    role: json['role'] as String,
    reasoningContent: json['reasoningContent'],
    content: json['content'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
