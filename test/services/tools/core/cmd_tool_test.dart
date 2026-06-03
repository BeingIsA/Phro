import 'package:flutter_test/flutter_test.dart';
import 'package:phro/services/tools/core/shell_tool.dart';

void main() {
  group('CmdTool', () {
    final tool = ShellTool.instance;

    test('能正常执行 echo 命令（跨平台）', () async {
      final result = await tool.execute({
        'command': 'cd \"E:\\projects\\phro\" && dir /s',
      });
      print(result);
    });
  });
}
