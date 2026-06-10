import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phro/models/agent.dart';
import 'package:phro/services/agent_service.dart';

/// 管理当前激活的完整 Agent 对象
class ActivatedAgentNotifier extends Notifier<Agent?> {
  final AgentService _agentService = AgentService.instance;

  @override
  Agent? build() {
    return _agentService.getActivateAgent();
  }

  /// 激活某个 Agent
  Future<void> activate(String id) async {
    await _agentService.activate(id);
    state = _agentService.getActivateAgent();
  }

  /// 取消激活
  Future<void> deactivate() async {
    await _agentService.deactivate();
    state = null;
  }
}

// Provider
final activatedAgentNotifierProvider =
    NotifierProvider<ActivatedAgentNotifier, Agent?>(
      () => ActivatedAgentNotifier(),
    );
