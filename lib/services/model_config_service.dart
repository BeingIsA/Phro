import 'package:phro/models/model_config.dart';
import 'package:phro/repositories/model_config_repository.dart';
import 'package:uuid/uuid.dart';

class ModelConfigService {
  static final ModelConfigService instance = ModelConfigService._();

  final ModelConfigRepository _repository;

  ModelConfigService._() : _repository = ModelConfigRepository.instance;

  Future<String> _generateUniqueId() async {
    String id;
    do {
      id = const Uuid().v4();
    } while (await _repository.getConfigById(id) != null);
    return id;
  }

  Future<String> saveConfig({
    String? id, // 传入 id 则编辑，不传入（null 或空）则新增
    required String? configName,
    required String url,
    required String modelName,
    required String apiKey,
  }) async {
    // id没传就是新增
    if (id == null || id.isEmpty) {
      id = await _generateUniqueId();
    }

    final config = ModelConfig(
      id: id,
      configName: configName?.isNotEmpty == true ? configName! : modelName,
      url: url,
      modelName: modelName,
      apiKey: apiKey,
    );

    return await _repository.saveConfig(config);
  }

  Future<void> deleteConfig(String id) async {
    return _repository.deleteConfig(id);
  }

  /// 获取所有配置（按名称排序）
  Future<List<ModelConfig>> getAllConfigs() async {
    return await _repository.getAllConfigs();
  }

  /// 根据 ID 获取单个配置
  Future<ModelConfig?> getConfigById(String id) async {
    return await _repository.getConfigById(id);
  }

  Future<ModelConfig?> getActivatedConfig() async {
    return await _repository.getActivatedConfig();
  }

  Future<void> activate(String id) async {
    await _repository.setActivated(id);
  }

  Future<void> deactivate(String id) async {
    if (await _repository.getActivatedId() == id) {
      await _repository.setActivated(null);
    }
  }

  Future<String?> getActivatedId() async {
    return await _repository.getActivatedId();
  }
}
