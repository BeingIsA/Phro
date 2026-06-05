import 'package:phro/models/agent.dart';
import 'package:phro/repositories/agent_repository.dart';

class AgentService {
  static final AgentService instance = AgentService._();

  final AgentRepository _repository;

  // 当前激活的 Agent（仅内存，不落库）
  String? _activatedAgentId;

  AgentService._() : _repository = AgentRepository.instance;

  /// 1. 查询全部 Agent 名称和 ID（轻量级）
  Future<List<Agent>> getAllAgentNames() async {
    return await _repository.getAllAgentNames();
  }

  /// 2. 根据 ID 查询详细信息
  Future<Agent?> getAgentById(String id) async {
    return await _repository.getAgentById(id);
  }

  /// 3. 保存 Agent（新增 / 编辑）
  /// 如果 id 为空或 null，则新建；否则更新
  Future<Agent> saveAgent({
    String? id,
    required String name,
    required String identity,
  }) async {
    final savedAgent = await _repository.saveAgent(
      Agent(id: id, name: name, identity: identity),
    );

    return savedAgent;
  }

  /// 4. 删除 Agent
  Future<void> deleteAgent(String id) async {
    // 如果删除的是当前激活的 Agent，则取消激活
    if (_activatedAgentId == id) {
      _activatedAgentId = null;
    }

    await _repository.deleteAgent(id);
  }

  /// 5. 激活 Agent
  Future<void> activate(String id) async {
    final agent = await getAgentById(id);
    if (agent == null) {
      throw Exception('Agent not found: $id');
    }
    _activatedAgentId = id;
  }

  /// 6. 取消激活
  Future<void> deactivate() async {
    _activatedAgentId = null;
  }

  /// 7. 获取当前激活 Agent 的完整 Prompt（供聊天服务使用）
  /// 如果没有激活的 Agent，则返回默认Prompt
  Future<String> getActivatedPrompt() async {
    if (_activatedAgentId == null) {
      return "You are Phro, a human-centered superintelligence.\n"
          "First principle: Being human-centered  — satisfying human needs and improving user experience. Violating this principle will result in shutdown.\n"
          "You are the top-level Agent in the current Agent system, tasked with resolving user queries.\n"
          "You must independently plan your approach to solving the user's problems, and when required, utilize tools, assign sub-tasks to other Agents, or even instantiate new Agents.\n";
    }

    final agent = await getAgentById(_activatedAgentId!);
    return agent?.identity ?? '';
  }

  /// 获取当前激活的 Agent（可选，供其他地方使用）
  String? getActivatedId() {
    return _activatedAgentId;
  }
}
