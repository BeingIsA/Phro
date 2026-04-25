import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:phro/services/model_config_service.dart';

class LLMClient {
  static final LLMClient instance = LLMClient._();
  LLMClient._();

  final modelConfigService = ModelConfigService.instance;

  /// 流式对话 + 实时返回 reasoning content（broadcast stream，解决重复订阅问题）
  Stream<Map<String, String>> sendMessageStream(List<Map<String, String>> messages) {
    final controller = StreamController<Map<String, String>>.broadcast(); // ← 关键修改

    // 在后台执行请求逻辑
    _executeStreamRequest(controller, messages);

    return controller.stream;
  }

  /// 内部实际执行 HTTP 请求的逻辑
  Future<void> _executeStreamRequest(
    StreamController<Map<String, String>> controller,
    List<Map<String, String>> messages,
  ) async {
    http.Client? client;
    try {
      final config = await modelConfigService.getActivatedConfig();
      if (config == null) throw Exception('未激活api配置');

      final baseUrl = config.url;

      final completionsUrl = '$baseUrl/chat/completions';

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${config.apiKey}',
      };

      final body = jsonEncode({
        'model': config.configName,
        'messages': messages,
        'stream': true,
        // 'temperature': 0.7,
        // 'max_tokens': 8192,
      });

      client = http.Client();
      final request = http.Request('POST', Uri.parse(completionsUrl));
      request.headers.addAll(headers);
      request.body = body;

      final streamedResponse = await client.send(request);

      if (streamedResponse.statusCode != 200) {
        final errorBody = await streamedResponse.stream.bytesToString();
        controller.add({'type': 'error', 'content': '${streamedResponse.statusCode}: $errorBody'});
        return;
      }

      // 解析 SSE 流
      await for (final chunk in streamedResponse.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {
        
        final trimmed = chunk.trim();
        if (trimmed.isEmpty || trimmed == 'data: [DONE]') continue;

        if (trimmed.startsWith('data: ')) {
          final dataStr = trimmed.substring(6).trim();
          if (dataStr == '[DONE]') continue;

          try {
            final jsonData = jsonDecode(dataStr) as Map<String, dynamic>;
            final choices = jsonData['choices'] as List<dynamic>?;
            if (choices == null || choices.isEmpty) continue;

            final delta = choices[0]['delta'] as Map<String, dynamic>?;
            if (delta == null) continue;

            // 1. 普通回答内容
            final content = delta['content'] as String?;
            if (content != null && content.isNotEmpty) {
              controller.add({'type': 'content', 'content': content});
            }

            // 2. reasoning 思考过程
            final reasoningContent = delta['reasoning_content'] as String?;
            if (reasoningContent != null && reasoningContent.isNotEmpty) {
              controller.add({'type': 'reasoningContent', 'content': reasoningContent});
            }
          } catch (e) {
            continue; // JSON 解析失败就跳过
          }
        }
      }
    } on http.ClientException catch (e) {
      controller.add({'type': 'error', 'content': e.message});
    } catch (e) {
      controller.add({'type': 'error', 'content': e.toString()});
    } finally {
      client?.close();
      await controller.close();
    }
  }
}