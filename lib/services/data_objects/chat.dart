import 'package:phro/services/data_objects/message.dart';
import 'package:uuid/uuid.dart';

class Chat {
  final String id;
  String title;
  final DateTime createdAt;
  DateTime updatedAt;
  List<Message> messages = [];

  Chat({
    String? id,
    this.title = '新对话',
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Message>? messages,
  }) : id = id ?? const Uuid().v4(),
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
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'messages': messages.map((m) => m.toMap()).toList(),
  };

  factory Chat.fromMap(Map<String, dynamic> json) {
    final messages =
        (json['messages'] as List<Map<String, dynamic>>?)
            ?.map((e) => Message.fromMap(e as Map<String, String>))
            .toList() ??
        <Message>[];
    return Chat(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      messages: messages,
    );
  }
}
