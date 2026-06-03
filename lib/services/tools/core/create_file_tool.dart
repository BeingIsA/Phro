import 'dart:io';
import 'package:phro/services/tools/core/tool.dart';

class CreateFileTool extends Tool {
  CreateFileTool._();
  static final CreateFileTool instance = CreateFileTool._();

  @override
  String get name => 'write_file';

  @override
  bool get requiresConfirmation => true;

  @override
  String get description => "创建文件（支持自动创建父目录）";

  @override
  Map<String, dynamic> get parameters => {
    "type": "object",
    "properties": {
      "path": {"type": "string", "description": "目标文件路径"},
      "content": {"type": "string", "description": "要写入的文件内容"},
    },
    "required": ["path", "content"],
  };

  @override
  Future<String> execute(Map args) async {
    final path = args['path'] as String;
    final content = args['content'] as String;

    final file = File(path);
    if (await file.exists()) {
      throw FileSystemException('文件 $path 已经存在');
    }
    // 确保目录存在
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }

    await file.writeAsString(content, mode: FileMode.write);

    return '文件操作成功！\n路径: $path\n内容长度: ${content.length} 字符';
  }
}
