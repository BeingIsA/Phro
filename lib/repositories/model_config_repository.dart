import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:phro/models/model_config.dart';

class ModelConfigRepository {
  static final ModelConfigRepository instance = ModelConfigRepository._();

  ModelConfigRepository._();

  String? _filePath;
  Map<String, ModelConfig>? _data;
  String? _activated;
  bool _loaded = false;

  Future<String> _initFilePath() async {
    if (_filePath != null) return _filePath!;
    final dir = await getApplicationSupportDirectory();
    _filePath = '${dir.path}/model_configs.json';
    return _filePath!;
  }

  Future<void> _ensureLoaded() async {
    if (_loaded) return;

    final path = await _initFilePath();
    final file = File(path);

    if (await file.exists()) {
      try {
        final content = await file.readAsString();
        if (content.trim().isNotEmpty) {
          final Map<String, dynamic> json = jsonDecode(content);
          _activated = json['activated'] as String?;

          final List<dynamic> list = json['configs'] ?? [];
          _data = {};
          for (final item in list) {
            final map = item as Map<String, dynamic>;
            final id = map['id'] as String?;
            if (id != null && id.isNotEmpty) {
              _data![id] = ModelConfig.fromMap(map);
            }
          }
        }
      } catch (_) {
        _data = {};
        _activated = '';
      }
    } else {
      _data = {};
      _activated = '';
    }

    _loaded = true;
  }

  Future<void> _save() async {
    final path = await _initFilePath();
    final file = File(path);
    await file.parent.create(recursive: true);

    final jsonList = _data!.values.map((c) => c.toMap()).toList();
    final Map<String, dynamic> json = {
      'configs': jsonList,
      'activated': _activated,
    };
    await file.writeAsString(jsonEncode(json), flush: true);
  }

  // ==================== 对外 API（只传变更值） ====================

  Future<List<ModelConfig>> getAllConfigs() async {
    await _ensureLoaded();
    final list = _data!.values.toList();
    list.sort((a, b) => a.configName.compareTo(b.configName));
    return list;
  }

  Future<ModelConfig?> getConfigById(String id) async {
    await _ensureLoaded();
    return _data![id];
  }

  Future<ModelConfig?> getActivatedConfig() async {
    await _ensureLoaded();
    if (_activated != null && _activated!.isNotEmpty) {
      return _data![_activated];
    }
    return null;
  }

  Future<String> saveConfig(ModelConfig config) async {
    await _ensureLoaded();
    _data![config.id] = config;
    await _save();
    return config.id;
  }

  Future<void> deleteConfig(String id) async {
    await _ensureLoaded();
    _data!.remove(id);
    if (_activated == id) {
      _activated = '';
    }
    await _save();
  }

  Future<void> setActivated(String? id) async {
    await _ensureLoaded();
    _activated = id;
    await _save();
  }

  Future<String?> getActivatedId() async {
    await _ensureLoaded();
    return _activated;
  }
}
