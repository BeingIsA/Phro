import 'package:phro/services/chat/message.dart';
import 'package:uuid/uuid.dart';

class Chat {
  final String id;
  String title;
  final DateTime createdAt;
  DateTime updatedAt;
  List<Message> messages = [];

  Chat({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Message>? messages,
  }) : id = id?.isNotEmpty == true ? id! : const Uuid().v4(),
       title = title?.isNotEmpty == true ? title! : DateTime.now().toString(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now() {
    if (messages != null) this.messages.addAll(messages);
  }

  void addMessage(Message message) {
    messages.add(message);
    updatedAt = DateTime.now();
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'messages': messages.map((m) => m.toMap4Storage()).toList(),
  };

  // 历史记录中的tool是否正确读取
  factory Chat.fromMap(Map<String, dynamic> json) {
    final messages =
        (json['messages'] as List<dynamic>?)
            ?.map((json) => Message.fromMap(Map<String, dynamic>.from(json)))
            .toList() ??
        <Message>[];
    return Chat(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      messages: messages,
    );
  }
}
