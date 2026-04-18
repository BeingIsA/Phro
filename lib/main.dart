import 'package:flutter/material.dart';
import 'package:phro/pages/home_page.dart';

Future<void> main() async {

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
