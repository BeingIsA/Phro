import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phro/models/agent.dart';
import 'package:phro/services/agent_service.dart';

/// 管理当前激活的完整 Agent 对象
class ActivatedAgentNotifier extends Notifier<Agent?> {
  final AgentService _agentService = AgentService.instance;

  @override
  Agent? build() {
    // 初始化时从 Service 获取当前激活的 Agent
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

  /// 刷新（用于新建/编辑后同步）
  void refresh() {
    state = _agentService.getActivateAgent();
  }

  /// 获取当前激活 Agent 的名称（兼容原有显示）
  String get currentName => state?.name ?? AgentService.kChiefAgentName;
}

// Provider
final activatedAgentProvider = NotifierProvider<ActivatedAgentNotifier, Agent?>(
  () => ActivatedAgentNotifier(),
);
