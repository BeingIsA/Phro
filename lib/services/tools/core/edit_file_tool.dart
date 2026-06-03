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
    final oldString = args['oldString'] as String;
    final newString = args['newString'] as String;
    final replaceAll = args['replaceAll'] as bool? ?? false;

    final file = File(path);

    // 检查文件是否存在
    if (!await file.exists()) {
      throw FileSystemException('文件不存在', path);
    }

    String content = await file.readAsString();

    if (replaceAll) {
      content = content.replaceAll(oldString, newString);
    } else {
      content = content.replaceFirst(oldString, newString);
    }

    // 写回文件
    await file.writeAsString(content);

    return '文件修改成功！\n路径: $path\n替换方式: ${replaceAll ? "全部替换" : "替换第一个匹配项"}';
  }
}
