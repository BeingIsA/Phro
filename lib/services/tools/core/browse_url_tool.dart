import 'dart:convert';

import 'package:html2md/html2md.dart' as html2md;
import 'package:http/http.dart' as http;
import 'package:phro/services/tools/core/tool.dart';

class BrowseUrlTool extends Tool {
  BrowseUrlTool._();

  static final BrowseUrlTool instance = BrowseUrlTool._();

  @override
  String get name => 'browse_url';

  @override
  String get description => "访问网页并将 HTML 转换为 Markdown 返回（已过滤无关标签，支持截断）";

  @override
  Map<String, dynamic> get parameters => {
    "type": "object",
    "properties": {
      "url": {"type": "string", "description": "目标网页 URL"},
      "timeout": {
        "type": "integer",
        "description": "请求超时时间（秒），默认 30",
        "default": 30,
      },
      "contextLength": {
        "type": "integer",
        "description": "返回的 Markdown 最大字符数，默认 30000",
        "default": 30000,
      },
    },
    "required": ["url"],
  };

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    final url = args['url'] as String;
    final timeout = args['timeout'] as int? ?? 30;
    final contextLength = args['contextLength'] as int? ?? 30000;

    final uri = Uri.parse(url);
    final response = await http.get(uri).timeout(Duration(seconds: timeout));

    // 非 200 也统一抛异常，统一走下面的 catch
    if (response.statusCode != 200) {
      throw http.ClientException(
        'HTTP ${response.statusCode} ${response.reasonPhrase ?? ""}',
        uri,
      );
    }
    final rawHtml = utf8.decode(response.bodyBytes);
    String markdown = html2md.convert(
      rawHtml,
      styleOptions: {
        'headingStyle': 'atx', // # 标题，更简洁
        'codeBlockStyle': 'fenced', // ``` 代码块
        'linkStyle': 'inlined',
      },
      ignore: [
        'script',
        'style',
        'nav',
        'footer',
        'header',
        'aside',
        'comment',
        'iframe',
      ],
    );

    if (markdown.length > contextLength) {
      markdown =
          '${markdown.substring(0, contextLength)}\n\n... (content truncated to $contextLength characters)';
    }

    return markdown;
  }
}
