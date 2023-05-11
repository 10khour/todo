import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:todo/todo_list.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  // 桌面端逻辑
  if ((!kIsWeb) &&
      (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();
    // 允许最小化
    await windowManager.setMinimizable(true);
    // 拦截程序关闭按键
    await windowManager.setPreventClose(true);
    // 状态托盘
    // await initSystemTray();
    // 添加窗口事件监听者
    // windowManager.addListener(AppWindowLisenter());

    WindowOptions windowOptions = const WindowOptions(
      size: Size(1350, 850),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
      windowButtonVisibility: true,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoList(),
    );
  }
}
