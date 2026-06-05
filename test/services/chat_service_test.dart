import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:phro/infrastructures/llm_client.dart';
import 'package:phro/models/chat.dart';
import 'package:phro/models/message.dart';
import 'package:phro/models/model_config.dart';
import 'package:phro/repositories/chat_repository.dart';
import 'package:phro/services/chat_service.dart';
import 'package:phro/services/model_config_service.dart';
import 'package:phro/services/tools/tool_service.dart';

class MockLLMClient extends Mock implements LLMClient {}

class MockToolService extends Mock implements ToolService {}

class MockModelConfigService extends Mock implements ModelConfigService {}

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockLLMClient mockLLMClient;
  late MockToolService mockToolService;
  late MockModelConfigService mockModelConfigService;
  late MockChatRepository mockChatRepository;
  late ChatService chatService;
  late Chat testChat;

  setUpAll(() {
    // mocktail 需要为 any() 注册 fallback 值
    registerFallbackValue('');
    registerFallbackValue(<Map<String, dynamic>>[]);
    registerFallbackValue(<String, dynamic>{});
    // === 新增：必须注册的模型类 fallback ===
    registerFallbackValue(
      Chat(title: 'fallback chat', agentName: 'test'),
    ); // 解决当前 Chat 报错
    registerFallbackValue(Message(role: 'user', content: ''));
  });

  setUp(() {
    mockLLMClient = MockLLMClient();
    mockToolService = MockToolService();
    mockModelConfigService = MockModelConfigService();
    mockChatRepository = MockChatRepository();

    chatService = ChatService.forTest(
      llmClient: mockLLMClient,
      toolService: mockToolService,
      modelConfigService: mockModelConfigService,
      chatRepository: mockChatRepository,
    );

    // 准备一个测试用的 Chat（真实模型类）
    testChat = Chat(title: 'Test Chat', agentName: 'test agent');
  });

  group('ChatService.sendMessage - Tool Call 流式拼接', () {
    test('正确拼接分块的 tool_calls arguments（get_weather + search_web）', () async {
      // Arrange
      final testConfig = ModelConfig(
        id: 'test',
        configName: 'test',
        url: 'test',
        modelName: 'test',
        apiKey: 'test',
      );
      when(
        () => mockModelConfigService.getActivatedConfig(),
      ).thenAnswer((_) async => testConfig);

      when(
        () => mockChatRepository.getChatById(any()),
      ).thenAnswer((_) async => testChat);

      when(() => mockChatRepository.saveChat(any())).thenAnswer((_) async {});
      final llmStreamWithTools = Stream.fromIterable([
        {'content': '让我帮你查询天气。\n'},
        {
          'tool_calls': [
            {
              'index': 0,
              'id': 'call_abc123',
              'type': 'function',
              'function': {'name': 'get_weather', 'arguments': ''},
            },
          ],
        },
        {
          'tool_calls': [
            {
              'index': 0,
              'function': {'arguments': '{"city":'},
            },
          ],
        },
        {
          'tool_calls': [
            {
              'index': 0,
              'function': {'arguments': '"北京"'},
            },
          ],
        },
        {
          'tool_calls': [
            {
              'index': 0,
              'function': {'arguments': ',"unit":"celsius"}'},
            },
          ],
        },
        {
          'tool_calls': [
            {
              'index': 1,
              'id': 'call_xyz789',
              'type': 'function',
              'function': {'name': 'search_web', 'arguments': ''},
            },
          ],
        },
        {
          'tool_calls': [
            {
              'index': 1,
              'function': {'arguments': '{"query":"北京空气质量"}'},
            },
          ],
        },
      ]);

      // LLM 第二次调用（工具执行后返回最终答案，无 tool_calls）
      final llmStreamFinalAnswer = Stream.fromIterable([
        {'content': '查询完成：北京天气晴朗 23°C，空气质量良好。'},
      ]);

      var llmCallCount = 0;
      when(
        () =>
            mockLLMClient.sendMessageStream(any(), any(), any(), any(), any()),
      ).thenAnswer((_) {
        return llmCallCount++ == 0 ? llmStreamWithTools : llmStreamFinalAnswer;
      });

      // Mock 工具执行（返回任意结果即可）
      when(() => mockToolService.execute(any(), any())).thenAnswer((
        invocation,
      ) async {
        final name = invocation.positionalArguments[0] as String;
        return '[$name] 执行成功';
      });

      // Act
      await chatService
          .sendMessage(chatId: testChat.id, content: '北京天气和空气质量如何？')
          .drain();

      // Assert - 核心验证：tool call arguments 被正确拼接并执行
      verify(
        () => mockToolService.execute(
          'get_weather',
          '{"city":"北京","unit":"celsius"}',
        ),
      ).called(1);

      verify(
        () => mockToolService.execute('search_web', '{"query":"北京空气质量"}'),
      ).called(1);
    });
  });
}
