import 'dart:convert';

import 'package:phro/services/tools/core/browse_url_tool.dart';
import 'package:phro/services/tools/core/cmd_tool.dart';
import 'package:phro/services/tools/core/read_file_tool.dart';
import 'package:phro/services/tools/core/web_search_tool.dart';
import 'package:phro/services/tools/core/tool.dart';

// 负责管理工具，生成工具信息用于调用api、执行工具、向前台展示工具信息等
class ToolService {
  ToolService._() {
    registerTool(CmdTool.instance);
    registerTool(BrowseUrlTool.instance);
    registerTool(WebSearchTool.instance);
    registerTool(ReadFileTool.instance);
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

  Future<String> execute(String name, String argsString) async {
    final tool = _toolMap[name];
    if (tool == null) return 'Unknown tool: $name';
    Map<String, dynamic> args = {};
    if (argsString.isNotEmpty) {
      args = jsonDecode(argsString);
    }
    try {
      return await tool.execute(args);
    } catch (e, s) {
      return 'Tool "$name" failed: $e\n$s';
    }
  }
}
