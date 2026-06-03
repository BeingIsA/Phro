// base_shell_tool.dart
import 'dart:convert';
import 'dart:io';
import 'package:phro/services/tools/core/tool.dart';

abstract class BaseShellTool extends Tool {
  @override
  String get name => 'shell';

  @override
  bool get requiresConfirmation => true;

  @override
  String get description => "在本地执行 shell 命令。优先使用其他工具，必要时再使用此方式。";

  @override
  Map<String, dynamic> get parameters => {
    "type": "object",
    "properties": {
      "command": {"type": "string", "description": "要执行的命令"},
    },
    "required": ["command"],
  };

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    final command = args['command'];
    if (command == null || command.toString().isEmpty) {
      return "missing argument: command";
    }
    final shell = getShellExecutable();
    final shellArgs = getShellArguments(command);
    final result = await Process.run(
      shell,
      shellArgs,
      stdoutEncoding: utf8,
    ).timeout(const Duration(seconds: 30));
    return [
      if (result.stdout.toString().trim().isNotEmpty)
        'stdout: ${result.stdout}',
      if (result.stderr.toString().trim().isNotEmpty)
        'stderr: ${result.stderr}',
      'returncode: ${result.exitCode}',
    ].join('\n');
  }

  String getShellExecutable();
  List<String> getShellArguments(String command);
}
