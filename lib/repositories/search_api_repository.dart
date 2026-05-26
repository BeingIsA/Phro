import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:phro/models/search_api_config.dart';

class SearchApiConfigRepository {
  static final SearchApiConfigRepository instance =
      SearchApiConfigRepository._();

  SearchApiConfigRepository._();

  String? _filePath;
  SearchApiConfig? _config;
  bool _loaded = false;

  Future<String> _ensureFilePath() async {
    if (_filePath != null) return _filePath!;
    final directory = await getApplicationSupportDirectory();
    _filePath = '${directory.path}/search_api_config.json';
    return _filePath!;
  }

  Future<void> _ensureLoaded() async {
    if (_loaded) return;

    final path = await _ensureFilePath();
    final file = File(path);

    if (await file.exists()) {
      try {
        final String content = await file.readAsString();
        if (content.trim().isEmpty) {
          _config = null;
        } else {
          final Map<String, dynamic> json = jsonDecode(content);
          _config = SearchApiConfig.fromMap(json);
        }
      } catch (_) {
        _config = null;
      }
    } else {
      _config = null;
    }

    _loaded = true;
  }

  Future<void> _save() async {
    final path = await _ensureFilePath();
    final file = File(path);
    await file.parent.create(recursive: true);

    if (_config == null) {
      if (await file.exists()) {
        await file.delete();
      }
      return;
    }

    await file.writeAsString(jsonEncode(_config!.toMap()), flush: true);
  }

  Future<SearchApiConfig?> getConfig() async {
    await _ensureLoaded();
    return _config;
  }

  Future<void> updateConfig(SearchApiConfig config) async {
    await _ensureLoaded();
    _config = config;
    await _save();
  }
}
