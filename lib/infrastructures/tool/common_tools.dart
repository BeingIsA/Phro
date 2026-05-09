import 'dart:io';
import 'dart:convert';
import 'package:html2md/html2md.dart' as html2md;
import 'package:http/http.dart' as http;

// TODO 怎么返回确认消息方便前端交互？？？是否新建一个变量判断请求安全级别由上层来控制确认消息？
// TODO 所有调用都要catch住异常，变成String

Future<String> cmd(String command) async {
  // String? comment = stdin.readLineSync();
  // // 用户取消执行
  // if (comment != null && comment.trim().toUpperCase() != '') {
  //   return '用户拒绝操作:$comment';
  // }

  final result = await Process.run(
    Platform.isWindows ? 'cmd.exe' : 'sh',
    Platform.isWindows ? ['/c', command] : ['-c', command],
    runInShell: true,
    stdoutEncoding: utf8,
    stderrEncoding: utf8,
  ).timeout(const Duration(seconds: 30));

  return 'stdout: ${result.stdout}\n'
      'stderr: ${result.stderr}\n'
      'returncode: ${result.exitCode}';
}

Future<String> browseUrl(
  String url, {
  int timeout = 30,
  int contextLength = 30000,
}) async {
  final uri = Uri.parse(url);

  final response = await http.get(uri).timeout(Duration(seconds: timeout));

  // 非 200 也统一抛异常，统一走下面的 catch
  if (response.statusCode != 200) {
    throw http.ClientException(
      'HTTP ${response.statusCode} ${response.reasonPhrase ?? ""}',
      uri,
    );
  }

  String markdown = html2md.convert(
    response.body,
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
