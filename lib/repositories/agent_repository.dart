import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:phro/models/agent.dart';

// Agent的激活状态不落库
class AgentRepository {
  static final AgentRepository instance = AgentRepository._();

  AgentRepository._();

  String? _baseDirPath;
  bool _loaded = false;
  // (prompt 不在内存中保存，实时查询)
  Map<String, Agent> _agents = {};

  Future<String> _initAgentsDir() async {
    if (_baseDirPath != null) return _baseDirPath!;
    final dir = await getApplicationSupportDirectory();
    _baseDirPath = '${dir.path}/agents';
    final baseDir = Directory(_baseDirPath!);
    if (!await baseDir.exists()) {
      await baseDir.create(recursive: true);
    }
    return _baseDirPath!;
  }

  Future<void> _ensureLoaded() async {
    if (_loaded) return;

    await _initAgentsDir();
    _agents.clear();

    final baseDir = Directory(_baseDirPath!);
    final entities = await baseDir.list().toList();

    for (final entity in entities) {
      if (entity is Directory) {
        final folderName = entity.uri.pathSegments.lastWhere(
          (e) => e.isNotEmpty,
        );
        final parts = folderName.split('_');
        if (parts.length >= 2) {
          final id = parts.last;
          final name = parts.sublist(0, parts.length - 1).join('_');

          if (id.isNotEmpty && name.isNotEmpty) {
            _agents[id] = Agent(id: id, name: name, identity: '');
          }
        }
      }
    }

    _loaded = true;
  }

  Future<String> _concatAgentDirPath(String id, String name) async {
    await _initAgentsDir();

    // 防御性处理：name 绝对不允许为空
    final safeName = name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');

    return '$_baseDirPath/${safeName}_$id';
  }

  Future<String> _readIdentityFromFile(String folderPath) async {
    final identityFile = File('$folderPath/IDENTITY.md');
    if (await identityFile.exists()) {
      try {
        return await identityFile.readAsString();
      } catch (_) {
        return '';
      }
    }
    return '';
  }

  Future<void> _writeIdentityToFile(String folderPath, String prompt) async {
    final dir = Directory(folderPath);
    await dir.create(recursive: true);

    final identityFile = File('$folderPath/IDENTITY.md');
    await identityFile.writeAsString(prompt.trim(), flush: true);
  }

  Future<List<Agent>> getAllAgentNames() async {
    await _ensureLoaded();
    final list = _agents.values.toList();
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  Future<Agent?> getAgentById(String id) async {
    await _ensureLoaded();
    final cached = _agents[id];
    if (cached == null) return null;

    final folderPath = await _concatAgentDirPath(id, cached.name);
    final fullPrompt = await _readIdentityFromFile(folderPath);

    return Agent(id: cached.id, name: cached.name, identity: fullPrompt);
  }

  Future<Agent> saveAgent(Agent agent) async {
    await _ensureLoaded();

    final oldAgent = _agents[agent.id];
    String? oldFolderPath;

    if (oldAgent != null) {
      oldFolderPath = await _concatAgentDirPath(agent.id, oldAgent.name);
    }

    final newFolderPath = await _concatAgentDirPath(agent.id, agent.name);

    // 名称变化时重命名文件夹
    if (oldFolderPath != null && oldAgent!.name != agent.name) {
      final oldDir = Directory(oldFolderPath);
      if (await oldDir.exists()) {
        await oldDir.rename(newFolderPath);
      }
    }

    // 更新 prompt
    await _writeIdentityToFile(newFolderPath, agent.identity);

    // 更新缓存
    _agents[agent.id] = Agent(id: agent.id, name: agent.name, identity: '');

    return agent;
  }

  Future<void> deleteAgent(String id) async {
    await _ensureLoaded();
    final agent = _agents[id];
    if (agent == null) return;

    final folderPath = await _concatAgentDirPath(id, agent.name);
    final dir = Directory(folderPath);

    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }

    _agents.remove(id);
  }
}
