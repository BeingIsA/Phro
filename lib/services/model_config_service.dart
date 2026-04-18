import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ModelConfigService {
  static const String configFileName = 'model_configs';

  static final ModelConfigService instance = ModelConfigService._();
  ModelConfigService._();

  Map<String, dynamic> _data = {};
  String? _activated = '';

  String? _filePath;
  bool _loaded = false;

  final Uuid _uuid = const Uuid();

  Future<void> _ensureLoaded() async {
    // _data 的结构是 [{'id':{key:value}}]
    // _activated 就是一个String
    if (_loaded) return;

    final directory = (await getApplicationSupportDirectory()).path;
    _filePath = '$directory/$configFileName.json';

    final file = File(_filePath!);

    if (await file.exists()) {
      try {
        Map<String, dynamic> json = jsonDecode((await file.readAsString()));

        _activated = json['activated'];

        final List<dynamic> jsonList = json['configs'];
        _data.clear();

        for (var item in jsonList) {
          final config = item as Map<String, dynamic>;
          final id = config['id'] as String?;
          if (id != null && id.isNotEmpty) {
            _data[id] = config;
          }
        }
      } catch (e) {
        _data.clear();
      }
    } else {
      _data.clear();
    }

    _loaded = true;
  }

  Future<void> _save() async {
    // 存储为{'configs':[{key:value}],'activated':String}
    final file = File(_filePath!);

    await file.parent.create(recursive: true);

    final jsonList = _data.values.toList();
    Map<String, dynamic> json = {'configs': jsonList, 'activated': _activated};
    await file.writeAsString(jsonEncode(json), flush: true);
  }

  Future<String> _generateUniqueId() async {
    String id;
    do {
      id = _uuid.v4();
    } while (_data.containsKey(id));
    return id;
  }

  Future<String> saveConfig({
    String? id, // 传入 id 则编辑，不传入（null 或空）则新增
    required String? configName,
    required String url,
    required String modelName,
    required String apiKey,
  }) async {
    await _ensureLoaded();
    // id没传就是新增
    if (id == null || id.isEmpty) {
      id = await _generateUniqueId();
    }

    var config = <String, dynamic>{
      'id': id,
      'configName': configName?.isNotEmpty == true
          ? configName!
          : modelName, // 如果没填则采用模型名称
      'url': url,
      'modelName': modelName,
      'apiKey': apiKey,
    };

    _data[id] = config;
    await _save();
    return id;
  }

  Future<void> deleteConfig(String id) async {
    await _ensureLoaded();
    _data.remove(id);
    await _save();
  }

  /// 获取所有配置（按名称排序）
  Future<List<dynamic>> getAllConfigs() async {
    await _ensureLoaded();
    final list = _data.values.toList();
    list.sort(
      (a, b) =>
          (a['configName'] as String).compareTo(b['configName'] as String),
    );
    return list;
  }

  /// 根据 ID 获取单个配置
  Future<Map<String, dynamic>?> getConfigById(String id) async {
    await _ensureLoaded();
    return _data[id];
  }

  Future<void> activate(String id) async {
    await _ensureLoaded();
    _activated = id;
    await _save();
  }

  Future<void> deactivate(String id) async {
    await _ensureLoaded();
    if (_activated == id) {
      _activated = null;
    }
    await _save();
  }

  Future<String?> getActivatedId() async {
    await _ensureLoaded();
    return _activated;
  }
}
