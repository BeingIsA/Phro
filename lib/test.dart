import 'dart:io';

import 'package:phro/services/llm_client_service.dart'; // 用于控制台输入输出

void main() async {
  print('🚀 LLMClientService 流式调用测试开始...\n');

  final service = LLMClientService.instance;

  // 1. 准备对话消息（至少包含一条 user 消息）
  final List<Map<String, String>> messages = [
    {
      'role': 'system',
      'content': '你是一个幽默、友好的AI助手，请用中文回复。',
    },
    {
      'role': 'user',
      'content': '你好！今天天气怎么样？随便说点有趣的事吧～',
    },
  ];

  try {
    print('📤 正在发送请求...\n');
    String fullResponse = '';

    // 2. 调用流式接口
    final stream = service.sendMessageStream(messages);

    // 3. 实时接收并打印每一小段内容（模拟打字效果）
    await for (final chunk in stream) {
      fullResponse += chunk;
      stdout.write(chunk); // 实时输出到控制台（不换行）
    }

    print('\n\n✅ 完整回复已结束：');
    print('─' * 50);
    print(fullResponse);
    print('─' * 50);

    // 4. 可选：把 AI 回复加入历史，方便下次继续对话
    messages.add({
      'role': 'assistant',
      'content': fullResponse,
    });

    print('\n💡 下次对话可以直接使用更新后的 messages 继续聊天！');
  } catch (e) {
    print('\n❌ 调用失败: $e');
  }
  
  print('\n🎉 测试结束，按 Enter 退出...');
  stdin.readLineSync(); // 防止程序立即退出
}