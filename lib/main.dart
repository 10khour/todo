import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:todo/task.dart';
import 'package:todo/todo_list.dart';
import 'package:todo/window.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  String? home = Platform.environment['HOME'];
  String todoPath = ".todo/todo.json";
  String finishPath = ".todo/done.json";

  // 桌面端逻辑
  if ((!kIsWeb) &&
      (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
    WidgetsFlutterBinding.ensureInitialized();
    if (Platform.isWindows) {
      home = Platform.environment['UserProfile'];
    }
    await windowManager.ensureInitialized();
    // 允许最小化
    await windowManager.setMinimizable(true);
    // 拦截程序关闭按键
    await windowManager.setPreventClose(true);
    // 状态托盘
    await initSystemTray();
    // 添加窗口事件监听者
    windowManager.addListener(AppWindowLisenter());

    WindowOptions windowOptions = const WindowOptions(
      size: Size(800, 580),
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
  runApp(MyApp(
    driver: TaskDriver(
        todoPath: "$home/$todoPath", finishPath: "$home/$finishPath"),
  ));
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  TaskDriver driver;
  MyApp({super.key, required this.driver});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoList(
        driver: driver,
      ),
    );
  }
}
