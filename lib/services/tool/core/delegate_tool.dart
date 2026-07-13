import 'package:phro/services/tool/core/tool.dart';

class DelegateTool extends Tool {
  DelegateTool._();
  static final DelegateTool instance = DelegateTool._();

  @override
  String get name => 'delegate';

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
    throw Exception("this method shoudn't be called");
  }
}
