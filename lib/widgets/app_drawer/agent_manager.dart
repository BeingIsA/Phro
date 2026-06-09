import 'package:flutter/material.dart';
import 'package:phro/models/agent.dart';
import 'package:phro/widgets/app_drawer/config_agent_card.dart';
import 'package:phro/services/agent_service.dart';

class AgentManager extends StatefulWidget {
  final TextStyle? titleStyle;

  const AgentManager({super.key, this.titleStyle});
  @override
  State<AgentManager> createState() => _AgentManagerState();
}

class _AgentManagerState extends State<AgentManager> {
  final AgentService _agentService = AgentService.instance;
  List<Agent> _agents = [];
  String? _activatedAgentId;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadAgents();
  }

  Future<void> _loadAgents() async {
    final agents = await _agentService.getAllAgentNames();
    final activatedAgent = _agentService.getActivatedId();

    if (mounted) {
      setState(() {
        _agents = agents;
        _activatedAgentId = activatedAgent;
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
    }
  }

  Future<void> _editAgent(Agent agent) async {
    agent = await _agentService.getAgentById(agent.id);

    final result = await showDialog<Map<String, String>>(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (context) => ConfigAgentCard(
        initialName: agent.name,
        initialIdentity: agent.identity,
      ),
    );

    if (result != null) {
      await _agentService.saveAgent(
        id: agent.id,
        name: result['name']!,
        identity: result['identity']!,
      );
      await _loadAgents();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        ListTile(
          title: Text('Agent管理', style: widget.titleStyle),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                size: 22,
                color: colorScheme.onSurface,
              ),
              // const SizedBox(width: 8),
              IconButton(
                onPressed: _createNewAgent,
                icon: Icon(Icons.add, size: 22, color: colorScheme.onSurface),
                tooltip: '新建 Agent',
              ),
            ],
          ),
          onTap: () => setState(() => _isExpanded = !_isExpanded),
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
                      final isActive = agent.id == _activatedAgentId;

                      return ListTile(
                        dense: true,
                        leading: Icon(
                          Icons.smart_toy_outlined,
                          color: isActive
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                        title: Text(
                          agent.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                size: 18,
                                color: colorScheme.primary,
                              ),
                              onPressed: () => _editAgent(agent),
                              tooltip: '编辑 Agent',
                            ),
                          ],
                        ),
                        onTap: () async {
                          if (isActive) {
                            await _agentService.deactivate();
                          } else {
                            await _agentService.activate(agent.id);
                          }
                          await _loadAgents();
                        },
                      );
                    },
                  ),
          ),
      ],
    );
  }
}
