import 'package:phro/models/message.dart';

class AgentContext {
  int depth = 0;
  String? parentToolCallId;
  List<Message> messages = [];
  String result = '';

  AgentContext(
    this.depth,
    this.messages, {
    this.result = '',
    this.parentToolCallId,
  });

  void update({String? result, List<Message>? messages}) {
    if (result != null && result.isNotEmpty) {
      this.result = result;
    }

    if (messages != null && messages.isNotEmpty) {
      this.messages = messages;
    }
  }

  void appendMessage(Message message) {
    messages.add(message);
  }
}
