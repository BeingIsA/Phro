// test/services/chat_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:hive_ce_test/hive_ce_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:phro/infrastructures/llm_client.dart';
import 'package:phro/services/chat/chat_service.dart';
import 'package:phro/services/chat/message.dart';

class MockLLMClient extends Mock implements LLMClient {}

void main() {
  late ChatService chatService;
  late MockLLMClient mockLLMClient;
  late Box<Map<dynamic, dynamic>> testBox;

  setUpAll(() async {
    await setUpTestHive(); // hive_ce_test 提供的临时数据库
  });

  setUp(() async {
    mockLLMClient = MockLLMClient();
    testBox = await Hive.openBox<Map>('chats_test');

    chatService = ChatService.forTest(
      llmClient: mockLLMClient,
      modelConfigService: null,
      box: testBox,
    );
  });

  tearDown(() async {
    await testBox.close();
  });

  tearDownAll(() async {
    await tearDownTestHive();
  });

  group('ChatService.sendMessage - Tool Calls 拼接测试', () {
    test('多个 tool call 的 arguments 应该被正确累加', () async {
      // Arrange
      final chatId = await chatService.createChat(title: 'Tool Call Test');

      final toolCallStream = Stream.fromIterable([
        {'type': 'content', 'content': '让我帮你查询天气。\n'},
        {
          'type': 'tool_calls',
          'content': [
            {
              'index': 0,
              'id': 'call_abc123',
              'type': 'function',
              'function': {'name': 'get_weather', 'arguments': ''},
            },
          ],
        },
        {
          'type': 'tool_calls',
          'content': [
            {
              'index': 0,
              'function': {'arguments': '{"city":'},
            },
          ],
        },
        {
          'type': 'tool_calls',
          'content': [
            {
              'index': 0,
              'function': {'arguments': '"北京"'},
            },
          ],
        },
        {
          'type': 'tool_calls',
          'content': [
            {
              'index': 0,
              'function': {'arguments': ',"unit":"celsius"}'},
            },
          ],
        },
        {
          'type': 'tool_calls',
          'content': [
            {
              'index': 1,
              'id': 'call_xyz789',
              'type': 'function',
              'function': {'name': 'search_web', 'arguments': ''},
            },
          ],
        },
        {
          'type': 'tool_calls',
          'content': [
            {
              'index': 1,
              'function': {'arguments': '{"query":"北京空气质量"}'},
            },
          ],
        },
      ]);

      when(
        () => mockLLMClient.sendMessageStream(any(), any()),
      ).thenAnswer((_) => toolCallStream);

      // Act
      final emitted = <List<Message>>[];
      await for (final messages in chatService.sendMessage(
        chatId: chatId,
        content: '今天北京天气怎么样？',
      )) {
        emitted.add(messages);
      }

      // Assert
      final finalMessages = emitted.last;
      final assistantMsg = finalMessages.lastWhere(
        (m) => m.role == 'assistant',
      );

      final tc0 = assistantMsg.toolCalls![0];
      expect(tc0['id'], 'call_abc123');
      expect(tc0['function']['name'], 'get_weather');
      expect(tc0['function']['arguments'], '{"city":"北京","unit":"celsius"}');

      final tc1 = assistantMsg.toolCalls![1];
      expect(tc1['id'], 'call_xyz789');
      expect(tc1['function']['name'], 'search_web');
      expect(tc1['function']['arguments'], '{"query":"北京空气质量"}');
    });
  });
}
