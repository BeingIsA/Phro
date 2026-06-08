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
        colorScheme: ColorScheme.light(
          primary: Colors.blue,
          onPrimary: Colors.white,
          primaryContainer: Colors.blue.shade50,
          onPrimaryContainer: Colors.blue.shade900,

          secondary: Colors.blue.shade700,
          onSecondary: Colors.white,

          surface: Colors.white,
          onSurface: Colors.black87,

          surfaceContainerHighest: Colors.grey.shade100, // 替代 surfaceVariant
          onSurfaceVariant: Colors.grey.shade700,
          outlineVariant: Colors.grey.shade200, // 表格边框
          outline: Colors.grey[400]!,

          error: Colors.red,
          onError: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 1,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        scaffoldBackgroundColor: Colors.white,
        cardColor: Colors.white,
      ),
      home: const HomePage(),
    ),
  );
}
