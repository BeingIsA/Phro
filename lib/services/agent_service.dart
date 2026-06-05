import 'package:phro/models/agent.dart';
import 'package:phro/repositories/agent_repository.dart';

class AgentService {
  static const String kChiefAgentName = 'Phro';
  static const String kChiefAgentPrompt =
      "You are Phro, a human-centered superintelligence.\n"
      "First principle: Being human-centered  — satisfying human needs and improving user experience. Violating this principle will result in shutdown.\n"
      "You are the top-level Agent in the current Agent system, tasked with resolving user queries.\n"
      "You must independently plan your approach to solving the user's problems, and when required, utilize tools, assign sub-tasks to other Agents, or even instantiate new Agents.\n";
  static final AgentService instance = AgentService._();

  final AgentRepository _agentRepository;

  // 当前激活的 Agent（仅内存，不落库）
  Agent? _activatedAgent;

  AgentService._() : _agentRepository = AgentRepository.instance;

  /// 1. 查询全部 Agent 名称和 ID（轻量级）
  Future<List<Agent>> getAllAgentNames() async {
    return await _agentRepository.getAllAgentNames();
  }

  /// 判断id是否正确属于业务逻辑，在Service层做
  Future<Agent> getAgentById(String id) async {
    final Agent? agent = await _agentRepository.getAgentById(id);
    if (agent == null) {
      throw Exception('AgentId $id does not Exist');
    }
    return agent;
  }

  /// 3. 保存 Agent（新增 / 编辑）
  /// 如果 id 为空或 null，则新建；否则更新
  Future<Agent> saveAgent({
    String? id,
    required String name,
    required String identity,
  }) async {
    final savedAgent = await _agentRepository.saveAgent(
      Agent(id: id, name: name, identity: identity),
    );

    return savedAgent;
  }

  /// 4. 删除 Agent
  Future<void> deleteAgent(String id) async {
    // 如果删除的是当前激活的 Agent，则取消激活
    if (_activatedAgent != null && _activatedAgent!.id == id) {
      _activatedAgent = null;
    }

    await _agentRepository.deleteAgent(id);
  }

  /// 5. 激活 Agent
  Future<void> activate(String id) async {
    final agent = await getAgentById(id);
    _activatedAgent = agent;
  }

  /// 6. 取消激活
  Future<void> deactivate() async {
    _activatedAgent = null;
  }

  /// 7. 获取当前激活 Agent 的完整 Prompt（供聊天服务使用）
  /// 如果没有激活的 Agent，则返回默认Prompt
  Future<String> getActivatedPrompt() async {
    if (_activatedAgent == null) {
      return kChiefAgentPrompt;
    }

    return _activatedAgent!.getFullPrompt();
  }

  Agent? getActivateAgent() {
    if (_activatedAgent == null) {
      return null;
    }
    return _activatedAgent;
  }

  String getActivatedName() {
    if (_activatedAgent == null) {
      return kChiefAgentName;
    }

    return _activatedAgent!.name;
  }

  /// 获取当前激活的 Agent（可选，供其他地方使用）
  String? getActivatedId() {
    if (_activatedAgent == null) {
      return null;
    }
    return _activatedAgent!.id;
  }
}
