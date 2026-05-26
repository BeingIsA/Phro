class ModelConfig {
  final String id;
  final String configName;
  final String url;
  final String modelName;
  final String apiKey;

  const ModelConfig({
    required this.id,
    required this.configName,
    required this.url,
    required this.modelName,
    required this.apiKey,
  });

  /// 从 Map 创建对象（用于从 JSON 反序列化）
  factory ModelConfig.fromMap(Map<String, dynamic> map) {
    return ModelConfig(
      id: map['id'] as String,
      configName: map['configName'] as String,
      url: map['url'] as String,
      modelName: map['modelName'] as String,
      apiKey: map['apiKey'] as String,
    );
  }

  /// 转换为 Map（用于 JSON 序列化）
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'configName': configName,
      'url': url,
      'modelName': modelName,
      'apiKey': apiKey,
    };
  }
}
