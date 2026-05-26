abstract class Tool {
  String get name;
  String get description;
  Map<String, dynamic> get parameters; // JSON Schema

  Future<String> execute(Map<String, dynamic> args);

  // 转成 LLM 可识别的 function 定义
  Map<String, dynamic> toJsonSchema() => {
    "type": "function",
    "function": {
      "name": name,
      "description": description,
      "parameters": parameters,
    },
  };
}
