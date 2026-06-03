import 'dart:convert';
import 'dart:io';

import 'package:phro/services/tools/core/tool.dart';

class ShellTool extends Tool {
  ShellTool._();

  static final ShellTool instance = ShellTool._();

  @override
  String get name => 'shell';

  // cmd 工具执行前必须经过用户确认
  @override
  bool get requiresConfirmation => true;

  @override
  String get description => "在本地执行 shell 命令。返回 stdout、stderr 和 exit code";

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
    String shell;
    List<String> shellArgs;

    if (Platform.isWindows) {
      // Windows 使用 PowerShell
      shell = 'powershell.exe';
      // -NoProfile: 不加载配置文件，加快启动
      // -ExecutionPolicy Bypass: 绕过执行策略，避免脚本限制
      // -Command: 执行后续命令
      shellArgs = [
        '-NoProfile',
        '-ExecutionPolicy',
        'Bypass',
        '-Command',
        command,
      ];
    } else if (Platform.isAndroid) {
      shell = '/system/bin/sh';
      shellArgs = ['-c', command];
    } else {
      // macOS, Linux 等其他类 Unix 系统
      shell = 'sh';
      shellArgs = ['-c', command];
    }

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
}
