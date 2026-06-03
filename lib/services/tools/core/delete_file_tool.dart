import 'dart:io';
import 'package:phro/services/tools/core/tool.dart';

class DeleteFileTool extends Tool {
  DeleteFileTool._();
  static final DeleteFileTool instance = DeleteFileTool._();

  @override
  String get name => 'delete_file';

  @override
  bool get requiresConfirmation => true;

  @override
  String get description => "删除本地文件或目录（目录为递归删除，慎用）";

  @override
  Map<String, dynamic> get parameters => {
    "type": "object",
    "properties": {
      "path": {"type": "string", "description": "目标文件或目录路径"},
    },
    "required": ["path"],
  };

  @override
  Future<String> execute(Map args) async {
    final path = args['path'] as String;

    final file = File(path);
    final directory = Directory(path);

    // 检查是文件还是目录
    if (await file.exists()) {
      await file.delete();
      return '文件删除成功！\n路径: $path';
    } else if (await directory.exists()) {
      await directory.delete(recursive: true);
      return '目录删除成功！\n路径: $path\n';
    } else {
      throw FileSystemException('文件或目录不存在', path);
    }
  }
}
