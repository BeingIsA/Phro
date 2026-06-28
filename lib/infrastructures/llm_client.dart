import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:platform_proxy/platform_proxy.dart';

Future<http.Client> createSystemProxyAwareClient(Uri targetUrl) async {
  final ioClient = HttpClient();

  try {
    final platformProxy = PlatformProxy();

    final proxies = await platformProxy.getPlatformProxies(
      url: targetUrl.toString(),
    );

    final pacString = proxies.getProxiesAsPac();

    if (pacString.trim().isNotEmpty) {
      ioClient.findProxy = (_) => pacString;
    } else {
      ioClient.findProxy = HttpClient.findProxyFromEnvironment;
    }
  } catch (_) {
    ioClient.findProxy = HttpClient.findProxyFromEnvironment;
  }

  return IOClient(ioClient);
}

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
    http.Client? client;
    final controller = StreamController<Map<String, dynamic>>(
      onCancel: () {
        client?.close();
      },
    );

    // 立即在后台启动请求（行为与原来完全一致）
    () async {
      try {
        final completionsUrl = Uri.parse('$baseUrl/chat/completions');
        client = await createSystemProxyAwareClient(completionsUrl);
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

        final request = http.Request('POST', completionsUrl)
          ..headers.addAll(headers)
          ..body = body;

        final streamedResponse = await client!.send(request);

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
        if (!controller.isClosed) {
          await controller.close();
        }
      }
    }();

    return controller.stream;
  }
}
