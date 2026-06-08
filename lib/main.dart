import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:phro/pages/home_page.dart';
import 'package:phro/repositories/chat_repository.dart';

Future<void> main() async {
  await Hive.initFlutter();
  await ChatRepository.instance.initHiveBox();

  runApp(
    MaterialApp(
      title: 'Phro',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue, // 主色调：蓝色
          brightness: Brightness.light, // 亮色模式（蓝白干净）
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white, // AppBar 白色
          foregroundColor: Colors.black87, // 标题和图标用深色
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomePage(),
    ),
  );
}
