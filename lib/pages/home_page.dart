import 'package:flutter/material.dart';
import 'package:phro/pages/message_input.dart';
import 'package:phro/pages/settings/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.sizeOf(context).shortestSide < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phro'), // 可自定义标题
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Phro',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('设置'),
              onTap: () {
                if (isSmallScreen) {
                  // 手机：跳转新页面
                  Navigator.push(
                    context,
                    PageRouteBuilder(// 保留 route settings（重要）
                      transitionDuration: Duration.zero, // 正向切换无动画
                      reverseTransitionDuration: Duration.zero, // 返回时也无动画
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const SettingsPage(),
                    ),
                  );
                } else {
                  // 平板/大屏：弹出对话框
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return Dialog(
                        backgroundColor: Theme.of(
                          context,
                        ).scaffoldBackgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 560, // 控制弹窗最大宽度
                            maxHeight: 680, // 可选，根据内容调整或去掉
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: SettingsPage(),
                          ), // 直接复用
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Expanded(child: SizedBox.shrink()), // 将输入框推至底部
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: MessageInput(
              onSend: (text) {
              },
            ),
          ),
        ],
      ),
    );
  }
}
