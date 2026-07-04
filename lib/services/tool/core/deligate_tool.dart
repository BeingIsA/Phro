import 'package:phro/services/tool/core/tool.dart';
import 'package:phro/services/chat_service.dart';

class DeligateTool extends Tool {
  DeligateTool._();
  static final DeligateTool instance = DeligateTool._();

  @override
  String get name => 'deligate';

  @override
  bool get requiresConfirmation => true;

  @override
  String get description =>
      "Assign and execute a sub-task using a specialized sub-agent.";

  @override
  Map<String, dynamic> get parameters => {
    "type": "object",
    "properties": {
      "system_prompt": {
        "type": "string",
        "description": "set by the super Agent according to its task.",
      },
      "tools": {
        "type": "array",
        "description": "tools available to sub agent, filtered by super agent",
        "items": {
          "type": "object",
          "properties": {
            "type": {
              "type": "string",
              "enum": ["function"],
            },
            "function": {
              "type": "object",
              "properties": {
                "name": {"type": "string"},
                "description": {"type": "string"},
                "parameters": {"type": "object"},
              },
              "required": ["name", "parameters"],
            },
          },
          "required": ["type", "function"],
        },
      },
      "user_input": {
        "type": "string",
        "description": "the exact subtask that sub agent has to finish",
      },
    },
    "required": ["path"],
  };

  @override
  Future<String> execute(Map args) async {
    final systemPrompt = args['system_prompt'];
    final userInput = args['user_input'];
    final tools = args['tools'];
    List<Map<String, dynamic>> messages = [
      {"role": "system", "content": systemPrompt},
      {"role": "user", "content": userInput},
    ];
    // TODO 未完成

    return "";
  }
}
