import 'package:flutter/material.dart';
import 'package:phro/models/agent.dart';
import 'package:phro/pages/sidebar/config_agent_card.dart';
import 'package:phro/services/agent_service.dart';

class AgentSelector extends StatefulWidget {
  final VoidCallback onAgentChanged; // Agent 变化后通知父组件刷新

  const AgentSelector({super.key, required this.onAgentChanged});

  @override
  State<AgentSelector> createState() => _AgentSelectorState();
}

class _AgentSelectorState extends State<AgentSelector> {
  final AgentService _agentService = AgentService.instance;
  List<Agent> _agents = [];
  String? _activatedAgentName;
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _loadAgents();
  }

  Future<void> _loadAgents() async {
    final agents = await _agentService.getAllAgentNames();
    final activatedId = _agentService.getActivatedId();
    String? activatedName = '默认Agent';

    if (activatedId != null) {
      final activatedAgent = await _agentService.getAgentById(activatedId);
      activatedName = activatedAgent?.name;
    }

    if (mounted) {
      setState(() {
        _agents = agents;
        _activatedAgentName = activatedName;
      });
    }
  }

  Future<void> _createNewAgent() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const ConfigAgentCard(),
    );

    if (result != null) {
      await _agentService.saveAgent(
        name: result['name']!,
        identity: result['identity']!,
      );
      await _loadAgents();
      widget.onAgentChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
          child: Row(
            children: [
              const Text(
                '当前 Agent：',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
              ),
              Expanded(
                child: Text(
                  _activatedAgentName ?? '未激活',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _activatedAgentName != null
                        ? Colors.blue
                        : Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
                icon: Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                ),
              ),
              IconButton(
                onPressed: _createNewAgent,
                icon: const Icon(Icons.add, size: 20),
                tooltip: '新建 Agent',
              ),
            ],
          ),
        ),

        // 可展开的 Agent 列表
        if (_isExpanded)
          Container(
            constraints: const BoxConstraints(maxHeight: 260),
            child: _agents.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        '暂无 Agent',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _agents.length,
                    itemBuilder: (context, index) {
                      final agent = _agents[index];
                      final isActive = agent.name == _activatedAgentName;

                      return ListTile(
                        dense: true,
                        leading: Icon(
                          Icons.smart_toy_outlined,
                          color: isActive ? Colors.blue : null,
                        ),
                        title: Text(
                          agent.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: isActive
                            ? const Icon(
                                Icons.check,
                                color: Colors.blue,
                                size: 18,
                              )
                            : null,
                        onTap: () async {
                          await _agentService.activate(agent.id);
                          await _loadAgents();
                          widget.onAgentChanged();
                        },
                      );
                    },
                  ),
          ),

        const Divider(height: 1),
      ],
    );
  }
}
