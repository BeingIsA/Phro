import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phro/services/agent_service.dart';

// Notifier 类
class ActivatedAgentNameNotifier extends Notifier<String> {
  final AgentService _agentService = AgentService.instance;

  @override
  String build() {
    // 初始化时从 AgentService 获取当前名称
    return _agentService.getActivatedName();
  }

  /// 更新激活的 Agent 名称（供 AgentService 调用）
  void updateName(String name) {
    state = name;
  }

  /// 刷新（从 AgentService 重新读取）
  void refresh() {
    state = _agentService.getActivatedName();
  }
}

// Provider 定义
final activatedAgentNameProvider =
    NotifierProvider<ActivatedAgentNameNotifier, String>(
      () => ActivatedAgentNameNotifier(),
    );
