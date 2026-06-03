import 'dart:convert';
import 'dart:io';

import 'package:phro/services/tools/core/browse_web_url_tool.dart';
import 'package:phro/services/tools/core/shell_tool.dart';
import 'package:phro/services/tools/core/create_directory_tool.dart';
import 'package:phro/services/tools/core/create_file_tool.dart';
import 'package:phro/services/tools/core/delete_file_tool.dart';
import 'package:phro/services/tools/core/edit_file_tool.dart';
import 'package:phro/services/tools/core/read_file_tool.dart';
import 'package:phro/services/tools/core/shell_tool/android_shell_tool.dart';
import 'package:phro/services/tools/core/shell_tool/mac_shell_tool.dart';
import 'package:phro/services/tools/core/shell_tool/windows_shell_tool.dart';
import 'package:phro/services/tools/core/web_search_tool.dart';
import 'package:phro/services/tools/core/tool.dart';

// 负责管理工具，生成工具信息用于调用api、执行工具、向前台展示工具信息等
class ToolService {
  ToolService._() {
    registerShellTool();
    registerTool(BrowseWebUrlTool.instance);
    registerTool(WebSearchTool.instance);
    registerTool(ReadFileTool.instance);
    registerTool(EditFileTool.instance);
    registerTool(CreateDirectoryTool.instance);
    registerTool(CreateFileTool.instance);
    registerTool(DeleteFileTool.instance);
  }

  void registerShellTool() {
    if (Platform.isWindows) {
      registerTool(WindowsShellTool.instance);
    } else if (Platform.isAndroid) {
      registerTool(AndroidShellTool.instance);
    } else if (Platform.isMacOS) {
      // macOS, Linux 等其他类 Unix 系统
      registerTool(MacShellTool.instance);
    }
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

  // 判断某个工具名是否需要确认
  bool requiresConfirmation(String name) {
    return _toolMap[name]?.requiresConfirmation ?? false;
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
