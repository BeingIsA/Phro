// windows_shell_tool.dart
import 'base_shell_tool.dart';

class WindowsShellTool extends BaseShellTool {
  WindowsShellTool._();
  static final WindowsShellTool instance = WindowsShellTool._();

  @override
  String getShellExecutable() => 'powershell.exe';

  @override
  String get description =>
      "使用 PowerShell 执行命令，返回 stdout、stderr 和 exit code。优先使用其他工具，必要时再使用此方式。";

  @override
  List<String> getShellArguments(String command) => [
    '-NoProfile',
    '-ExecutionPolicy',
    'Bypass',
    '-Command',
    command,
  ];
}
