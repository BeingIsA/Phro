abstract class Tool {
  String get name;
  String get description;
  Map<String, dynamic> get parameters; // JSON Schema

  // 该工具是否需要用户授权确认，默认不需要
  bool get requiresConfirmation => false;

  Future<String> execute(Map<String, dynamic> args);

  Map<String, dynamic> toJsonSchema() => {
    "type": "function",
    "function": {
      "name": name,
      "description": description,
      "parameters": parameters,
    },
  };
}
