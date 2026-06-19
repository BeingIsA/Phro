// android_shell_tool.dart
import 'base_shell_tool.dart';

class AndroidShellTool extends BaseShellTool {
  AndroidShellTool._();
  static final AndroidShellTool instance = AndroidShellTool._();

  @override
  String getShellExecutable() => '/system/bin/sh';

  @override
  List<String> getShellArguments(String command) => ['-c', command];
}
