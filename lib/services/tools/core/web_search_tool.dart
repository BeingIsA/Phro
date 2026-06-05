import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:phro/models/search_api_config.dart';
import 'package:phro/services/search_api_config_service.dart';
import 'package:phro/services/tools/core/tool.dart';

/// 极简版统一搜索工具
/// 直接返回 response.body（已经是字符串）
class WebSearchTool extends Tool {
  WebSearchTool._();
  static final WebSearchTool instance = WebSearchTool._();

  SearchApiConfigService searchApiConfigService =
      SearchApiConfigService.instance;

  @override
  String get name => 'web_search';

  @override
  String get description => "联网搜索工具，用于获取实时、公开的网页搜索结果";

  @override
  Map<String, dynamic> get parameters => {
    "type": "object",
    "properties": {
      "query": {"type": "string", "description": "搜索关键词"},
      "limit": {"type": "integer", "description": "返回结果数量，默认20", "default": 20},
      "timeout": {
        "type": "integer",
        "description": "请求超时时间（秒），默认30",
        "default": 30,
      },
    },
    "required": ["query"],
  };

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    final query = args['query'] as String;
    final limit = args['limit'] as int? ?? 10;
    final timeout = args['timeout'] as int? ?? 45;

    SearchApiConfig? searchApiConfigObject = await searchApiConfigService
        .getConfig();

    if (searchApiConfigObject == null) {
      return '没有配置搜索api，请先进行配置';
    }
    final url = searchApiConfigObject.url;
    final apiKey = searchApiConfigObject.apiKey;
    final uri = Uri.parse(url);

    final response = await http
        .post(
          uri,
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
            'User-Agent': 'Phro-UnifiedSearchTool/1.0',
          },
          body: jsonEncode({'query': query, 'limit': limit}),
        )
        .timeout(Duration(seconds: timeout));

    if (response.statusCode != 200) {
      throw http.ClientException(
        '搜索失败: HTTP ${response.statusCode}\n${response.body}',
        uri,
      );
    }

    final formattedJson = JsonEncoder.withIndent(
      '  ',
    ).convert(json.decode(response.body));

    return formattedJson;
  }
}
