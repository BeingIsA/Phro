import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// 搜索 API 配置对象（全局仅一个配置）
class SearchApiConfigObject {
  final String url;
  final String apiKey;

  SearchApiConfigObject({required this.url, required this.apiKey});

  /// 从 Map 创建对象（用于从 JSON 反序列化）
  factory SearchApiConfigObject.fromMap(Map<String, dynamic> map) {
    return SearchApiConfigObject(
      url: map['url'] as String,
      apiKey: map['apiKey'] as String,
    );
  }

  /// 转换为 Map（用于 JSON 序列化）
  Map<String, dynamic> toMap() {
    return {'url': url, 'apiKey': apiKey};
  }
}

class SearchApiConfigService {
  static final SearchApiConfigService instance = SearchApiConfigService._();
  SearchApiConfigService._();

  SearchApiConfigObject? _config;
  String? _filePath;
  bool _loaded = false;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;

    final directory = await getApplicationSupportDirectory();
    _filePath = '${directory.path}/search_api_config.json';

    final file = File(_filePath!);

    if (await file.exists()) {
      try {
        final String content = await file.readAsString();
        final Map<String, dynamic> json = jsonDecode(content);
        _config = SearchApiConfigObject.fromMap(json);
      } catch (e) {
        _config = null;
      }
    } else {
      _config = null;
    }

    _loaded = true;
  }

  Future<void> _save() async {
    if (_filePath == null) return;

    final file = File(_filePath!);
    await file.parent.create(recursive: true);

    if (_config == null) {
      if (await file.exists()) {
        await file.delete();
      }
      return;
    }

    await file.writeAsString(jsonEncode(_config!.toMap()), flush: true);
  }

  /// 更新搜索 API 配置（全局仅有一个配置，覆盖旧配置）
  Future<void> updateConfig({
    required String url,
    required String apiKey,
  }) async {
    await _ensureLoaded();

    _config = SearchApiConfigObject(url: url, apiKey: apiKey);

    await _save();
  }

  /// 查询当前搜索 API 配置
  /// 如果从未配置过，返回 null
  Future<SearchApiConfigObject?> getConfig() async {
    await _ensureLoaded();
    return _config;
  }
}
