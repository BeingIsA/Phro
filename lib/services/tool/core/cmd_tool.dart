import 'dart:convert';
import 'dart:io';

import 'package:phro/services/tool/tool.dart';

class CmdTool extends Tool {
  CmdTool._();

  static final CmdTool instance = CmdTool._();

  @override
  String get name => 'cmd';

  @override
  String get description =>
      "在本地执行 shell 命令（Windows 下用 cmd.exe，Linux/Mac 用 sh），返回 stdout、stderr 和 exit code";

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
    if (command == null || command!.isEmpty) {
      return "missing argument: command";
    }
    final result = await Process.run(
      Platform.isWindows ? 'cmd.exe' : 'sh',
      Platform.isWindows ? ['/c', command] : ['-c', command],
      runInShell: true,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    ).timeout(const Duration(seconds: 30));

    return [
      if (result.stdout.toString().trim().isNotEmpty)
        'stdout: ${result.stdout}',
      if (result.stderr.toString().trim().isNotEmpty)
        'stderr: ${result.stderr}',
      'returncode: ${result.exitCode}',
    ].join('\n');
  }
}
