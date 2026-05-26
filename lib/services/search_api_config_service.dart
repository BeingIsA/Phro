import 'package:phro/models/search_api_config.dart';
import 'package:phro/repositories/search_api_repository.dart';

class SearchApiConfigService {
  static final SearchApiConfigService instance = SearchApiConfigService._();
  final SearchApiConfigRepository _repository;
  SearchApiConfigService._() : _repository = SearchApiConfigRepository.instance;

  Future<void> updateConfig({
    required String url,
    required String apiKey,
  }) async {
    final config = SearchApiConfig(url: url, apiKey: apiKey);
    await _repository.updateConfig(config); // 只传递单个领域对象
  }

  Future<SearchApiConfig?> getConfig() async {
    return await _repository.getConfig();
  }
}
