import 'package:get/get.dart';
import 'package:adwaita/adwaita.dart';
import 'package:flutter/material.dart';
import 'package:notifydb/utils/logger.dart';
import 'package:nativeshell/nativeshell.dart';
import 'package:notifydb/windows/main_view.dart';

import 'controllers/data_controller.dart';
import 'controllers/logging_controller.dart';
import 'controllers/table_controller.dart';
import 'controllers/main_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  disableShaderWarmUp();
  Get.put(LoggingController());
  Get.put(DataController()..Initialization());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Get.put(MainController()..initialize(context));
    Get.put(TableController());

    return WindowWidget(onCreateState: (initData) {
      WindowState? state;
      state ??= MainWindowState();
      Get.find<MainController>().windowState = state;
      return state;
    });
  }
}

class MainWindowState extends WindowState {
  @override
  Future<void> initializeWindow(Size intrinsicContentSize) async {
    var defaultSize = Size(1000, 550);
    var dataController = Get.find<DataController>();
    dataController.localWindow = window;

    var windowSize = dataController.windowSize;
    await window.setStyle(WindowStyle(canResize: true, frame: WindowFrame.noTitle));

    // --| Restore prior window size -----------------
    if (windowSize.isNotEmpty) {
      await window.restorePositionFromString(windowSize);
      return super.initializeWindow(intrinsicContentSize);
    }

    return super.initializeWindow(defaultSize);
  }

  @override
  Future<void> windowCloseRequested() async {
    var windowStr = await window.savePositionToString();
    Get.find<DataController>().saveWindowSize(windowStr);
    return super.windowCloseRequested();
  }

  @override
  WindowSizingMode get windowSizingMode => WindowSizingMode.manual;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      enableLog: true,
      logWriterCallback: Logger.write,
      theme: AdwaitaThemeData.dark(),
      home: DefaultTextStyle(
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        child: Container(color: Colors.black, child: WindowLayoutProbe(child: MainView())),
      ),
    );
  }
}
