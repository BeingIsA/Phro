// unix_shell_tool.dart
import 'base_shell_tool.dart';

class MacShellTool extends BaseShellTool {
  MacShellTool._();
  static final MacShellTool instance = MacShellTool._();

  @override
  String getShellExecutable() => 'sh';

  @override
  List<String> getShellArguments(String command) => ['-c', command];
}
