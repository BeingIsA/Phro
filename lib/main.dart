import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:phro/pages/home_page.dart';
import 'package:phro/services/chat_service.dart';

Future<void> main() async {
  await Hive.initFlutter(); // 必须第一步！
  await ChatService.instance.initHiveBox();
  runApp(
    MaterialApp(
      title: 'Flutter Internal Send Button',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue, // ← 全局 AppBar 颜色
          foregroundColor: Colors.white, // 全局文字和图标颜色
          elevation: 2,
          centerTitle: true,
          // systemOverlayStyle: SystemUiOverlayStyle.light, // 状态栏颜色
        ),
      ),
      home: const HomePage(),
    ),
  );
}
