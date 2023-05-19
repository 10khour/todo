import 'dart:io';

import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

class AppWindowLisenter extends WindowListener {
  // 监听程序关闭事件
  @override
  void onWindowClose() {
    super.onWindowClose();
    windowManager.minimize();
  }
}

Future<void> initSystemTray() async {
  String path = 'assets/images/todo.png';

  final AppWindow appWindow = AppWindow();
  final SystemTray systemTray = SystemTray();

  // We first init the systray menu
  await systemTray.initSystemTray(
    iconPath: path,
  );

  // create context menu
  final Menu menu = Menu();
  await menu.buildFrom([
    MenuItemLabel(label: 'Exit', onClicked: (menuItem) => exit(0)),
  ]);

  // set context menu
  await systemTray.setContextMenu(menu);

  // handle system tray event
  systemTray.registerSystemTrayEventHandler((eventName) async {
    // debugPrint("eventName: $eventName");
    if (eventName == kSystemTrayEventClick) {
      if (await windowManager.isMinimized()) {
        Platform.isWindows ? systemTray.popUpContextMenu() : appWindow.show();
      } else {
        Platform.isWindows ? systemTray.popUpContextMenu() : appWindow.close();
      }
    } else {
      if (eventName == kSystemTrayEventRightClick) {
        Platform.isWindows ? appWindow.show() : systemTray.popUpContextMenu();
      }
    }
  });
}
