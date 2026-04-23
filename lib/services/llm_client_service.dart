import 'package:dart_openai/dart_openai.dart';
import 'package:phro/services/model_config_service.dart';

class LLMClientService {
  static final LLMClientService instance = LLMClientService._();
  LLMClientService._();

  final modelConfigService = ModelConfigService.instance;

  // 流式对话（推荐前端使用）
  Stream<String> sendMessageStream(List<Map<String, String>> messages) async* {
    try {
      final config = await modelConfigService.getActivatedConfig();
      if (config == null) throw Exception('未激活api配置');
      var fullUrl = config.url;
      final lastSlash = fullUrl.lastIndexOf('/');
      final baseUrl = fullUrl.substring(0, lastSlash);
      final version = fullUrl.substring(lastSlash + 1);

      OpenAI.apiKey = config.apiKey;
      OpenAI.baseUrl = baseUrl;
      OpenAI.baseUrlVersion = version;
      final stream = OpenAI.instance.chat.createStream(
        model: config.configName,
        messages: messages
            .map(
              (m) => OpenAIChatCompletionChoiceMessageModel(
                role: switch (m['role']) {
                  'user' => OpenAIChatMessageRole.user,
                  'system' => OpenAIChatMessageRole.system,
                  _ => OpenAIChatMessageRole.assistant, // 其他情况默认 assistant
                },
                content: [
                  OpenAIChatCompletionChoiceMessageContentItemModel.text(
                    m['content']!,
                  ),
                ],
              ),
            )
            .toList(),
      );

      await for (final chunk in stream) {
        final contentList = chunk.choices.first.delta.content;
        if (contentList != null) {
          for (final item in contentList) {
            final text = item?.text;
            if (text != null && text.isNotEmpty) {
              yield text; // 每次 yield 一段文本，保持流式效果
            }
          }
        }
      }
    } on RequestFailedException catch (e) {
      // 使用 [ERROR] 前缀，方便前端区分普通消息和错误消息
      yield '[ERROR] ${e.statusCode}:${e.message}';
      // 如果你希望上层继续通过 onError 捕获，可以在这里 rethrow;
      // rethrow;
    }
  }
}
