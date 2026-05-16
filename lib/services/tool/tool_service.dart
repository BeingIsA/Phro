import 'package:phro/services/tool/core/browse_url_tool.dart';
import 'package:phro/services/tool/core/cmd_tool.dart';
import 'package:phro/services/tool/tool.dart';

// 负责管理工具，生成工具信息用于调用api、执行工具、向前台展示工具信息等
class ToolService {
  ToolService._() {
    registerTool(CmdTool.instance);
    registerTool(BrowseUrlTool.instance);
  }

  static final ToolService instance = ToolService._();

  final Map<String, Tool> _toolMap = {};

  void registerTool(Tool tool) {
    _toolMap[tool.name] = tool;
  }

  List<Map<String, dynamic>> getAllToolsInJsonSchema() {
    return _toolMap.values.map((tool) => tool.toJsonSchema()).toList();
  }

  List<Tool> getAllTools() {
    return _toolMap.values.toList();
  }

  Future<String> execute(String name, Map<String, dynamic> args) async {
    final tool = _toolMap[name];
    if (tool == null) return 'Unknown tool: $name';

    try {
      return await tool.execute(args);
    } catch (e, s) {
      return 'Tool "$name" failed: $e\n$s';
    }
  }
}
