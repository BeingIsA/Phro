import 'dart:io';
import 'package:phro/services/tools/core/tool.dart';

class EditFileTool extends Tool {
  EditFileTool._();
  static final EditFileTool instance = EditFileTool._();

  @override
  String get name => 'edit_file';

  @override
  bool get requiresConfirmation => true;

  @override
  String get description => "修改本地文件内容（支持文本替换）";

  @override
  Map<String, dynamic> get parameters => {
    "type": "object",
    "properties": {
      "path": {"type": "string", "description": "目标文件路径"},
      "oldString": {"type": "string", "description": "要被替换的旧文本"},
      "newString": {"type": "string", "description": "替换后的新文本"},
      "replaceAll": {
        "type": "boolean",
        "description": "是否替换所有匹配项，默认为 false（仅替换第一个匹配项）",
        "default": false,
      },
    },
    "required": ["path", "oldString", "newString"],
  };

  @override
  Future<String> execute(Map args) async {
    final path = args['path'] as String;
    final oldString = args['oldString'].replaceAll('\r\n', '\n') as String;
    final newString = args['newString'].replaceAll('\r\n', '\n') as String;
    final replaceAll = args['replaceAll'] as bool? ?? false;

    // 参数校验：空的 oldString 会导致 replaceFirst/replaceAll 在每处插入，需拦截
    if (oldString.isEmpty) {
      throw ArgumentError('oldString 不能为空');
    }
    if (oldString == newString) {
      throw ArgumentError('oldString 与 newString 相同，无需替换');
    }

    final file = File(path);

    // 检查文件是否存在
    if (!await file.exists()) {
      throw FileSystemException('文件不存在', path);
    }
    final content = await file.readAsString();

    // 统计匹配次数，避免静默失败（无匹配）或改错位置（多匹配但未启用 replaceAll）
    final matchCount = oldString.allMatches(content).length;
    if (matchCount == 0) {
      throw StateError('未找到要替换的文本（oldString），文件未做任何修改');
    }
    if (matchCount > 1 && !replaceAll) {
      throw StateError(
        'oldString 在文件中出现了 $matchCount 次，无法确定替换哪一处。'
        '请提供更长、唯一的上下文，或设置 replaceAll=true 以替换全部。',
      );
    }

    final newContent = replaceAll
        ? content.replaceAll(oldString, newString)
        : content.replaceFirst(oldString, newString);

    // 写回文件
    await file.writeAsString(newContent);

    final replacedCount = replaceAll ? matchCount : 1;
    return '文件修改成功！\n路径: $path\n替换处数: $replacedCount';
  }
}
