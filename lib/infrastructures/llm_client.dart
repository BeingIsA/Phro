import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LLMClient {
  static final LLMClient instance = LLMClient._();
  LLMClient._();

  /// 流式对话 + 实时返回 reasoning content（broadcast stream，解决重复订阅问题）
  Stream<Map<String, dynamic>> sendMessageStream(
    String baseUrl,
    String apiKey,
    String modelName,
    List<Map<String, dynamic>> messages,
    List<Map<String, dynamic>> tools,
  ) {
    final controller = StreamController<Map<String, dynamic>>.broadcast();

    // 立即在后台启动请求（行为与原来完全一致）
    () async {
      http.Client? client;
      try {
        final completionsUrl = Uri.parse('$baseUrl/chat/completions');

        final headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        };

        final body = jsonEncode({
          'model': modelName,
          'messages': messages,
          'tools': tools,
          'stream': true,
        });

        client = http.Client();
        final request = http.Request('POST', completionsUrl)
          ..headers.addAll(headers)
          ..body = body;

        final streamedResponse = await client.send(request);

        if (streamedResponse.statusCode != 200) {
          final errorBody = await streamedResponse.stream.bytesToString();
          controller.add({
            'error': '${streamedResponse.statusCode}: $errorBody',
          });
          return;
        }

        // 解析 SSE 流
        await for (final chunk
            in streamedResponse.stream
                .transform(utf8.decoder)
                .transform(const LineSplitter())) {
          final trimmed = chunk.trim();
          if (trimmed.isEmpty || trimmed == 'data: [DONE]') continue;

          if (trimmed.startsWith('data: ')) {
            final dataStr = trimmed.substring(6).trim();
            if (dataStr == '[DONE]') continue;

            try {
              final jsonData = jsonDecode(dataStr) as Map<String, dynamic>;
              final delta =
                  jsonData['choices']?[0]?['delta'] as Map<String, dynamic>?;
              if (delta != null) {
                controller.add(delta);
              }
            } catch (_) {
              continue;
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
    }();

    return controller.stream;
  }
}
