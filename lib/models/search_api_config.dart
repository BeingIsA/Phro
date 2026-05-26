/// 搜索 API 配置对象（全局仅一个配置）
class SearchApiConfig {
  final String url;
  final String apiKey;

  SearchApiConfig({required this.url, required this.apiKey});

  /// 从 Map 创建对象（用于从 JSON 反序列化）
  factory SearchApiConfig.fromMap(Map<String, dynamic> map) {
    return SearchApiConfig(
      url: map['url'] as String,
      apiKey: map['apiKey'] as String,
    );
  }

  /// 转换为 Map（用于 JSON 序列化）
  Map<String, dynamic> toMap() {
    return {'url': url, 'apiKey': apiKey};
  }
}
