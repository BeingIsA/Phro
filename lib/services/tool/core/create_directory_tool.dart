import 'dart:io';
import 'package:phro/services/tool/core/tool.dart';

class CreateDirectoryTool extends Tool {
  CreateDirectoryTool._();
  static final CreateDirectoryTool instance = CreateDirectoryTool._();

  @override
  String get name => 'create_directory';

  @override
  bool get requiresConfirmation => true;

  @override
  String get description => "创建目录（支持递归创建）";

  @override
  Map<String, dynamic> get parameters => {
    "type": "object",
    "properties": {
      "path": {"type": "string", "description": "要创建的目录路径"},
    },
    "required": ["path"],
  };

  @override
  Future<String> execute(Map args) async {
    final path = args['path'] as String;

    final directory = Directory(path);

    // 如果目录已存在
    if (await directory.exists()) {
      return '目录已存在，无需创建。\n路径: $path';
    }

    await directory.create(recursive: true);

    return '目录创建成功！\n路径: $path\n';
  }
}
