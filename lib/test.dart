import 'package:phro/infrastructures/tool/common_tools.dart';

Future<void> main(List<String> args) async {
  String md = await cmd('flutter doctor');
  print(md);
}