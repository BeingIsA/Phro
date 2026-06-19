import 'dart:io';
import 'package:phro/services/tool/core/tool.dart';

class ReadFileTool extends Tool {
  ReadFileTool._();
  static final ReadFileTool instance = ReadFileTool._();

  @override
  String get name => 'read_file';

  @override
  String get description => "读取本地文件内容并返回（支持截断）";

  @override
  Map<String, dynamic> get parameters => {
    "type": "object",
    "properties": {
      "path": {"type": "string", "description": "目标文件路径"},
      "contextLength": {
        "type": "integer",
        "description": "返回的文件内容最大字符数，默认 20000",
        "default": 20000,
      },
    },
    "required": ["path"],
  };

  @override
  Future<String> execute(Map args) async {
    final path = args['path'] as String;
    final contextLength = args['contextLength'] as int? ?? 20000;

    final file = File(path);

    // 检查文件是否存在（异步方式更符合 Dart 最佳实践）
    if (!await file.exists()) {
      throw FileSystemException('文件不存在', path);
    }

    String content = await file.readAsString();

    if (content.length > contextLength) {
      content =
          '${content.substring(0, contextLength)}\n\n... (content truncated to $contextLength characters)';
    }

    return content;
  }
}
